import Foundation
import Combine

class DataDownloadViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    
    func requestDownload() {
        isLoading = true
        
        networkService.requestDataDownload()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorAlert = true
                }
            }, receiveValue: { [weak self] _ in
                self?.showSuccessAlert = true
            })
            .store(in: &cancellables)
    }
} 