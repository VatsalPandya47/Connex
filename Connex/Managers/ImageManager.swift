import Foundation
import UIKit
import Combine

class ImageManager {
    static let shared = ImageManager()
    
    private let networkService = NetworkService.shared
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
    }
    
    func uploadImage(_ image: UIImage) -> AnyPublisher<URL, Error> {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return Fail(error: ImageError.compressionFailed).eraseToAnyPublisher()
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: NetworkService.shared.baseURL.appendingPathComponent("/media/upload"))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")
        
        request.httpBody = body
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw ImageError.uploadFailed
                }
                return data
            }
            .decode(type: ImageUploadResponse.self, decoder: JSONDecoder())
            .map { $0.url }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage, Error> {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return Just(cachedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw ImageError.invalidData
                }
                self.cache.setObject(image, forKey: url.absoluteString as NSString)
                return image
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum ImageError: LocalizedError {
    case compressionFailed
    case uploadFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .uploadFailed:
            return "Failed to upload image"
        case .invalidData:
            return "Invalid image data received"
        }
    }
}

struct ImageUploadResponse: Codable {
    let url: URL
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
} 
} 