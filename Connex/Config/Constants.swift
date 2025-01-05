import SwiftUI

enum Constants {
    enum Design {
        static let cornerRadius: CGFloat = 12
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 20
        
        static let primaryColor = Color("PrimaryColor")
        static let secondaryColor = Color("SecondaryColor")
        static let backgroundColor = Color("BackgroundColor")
        
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.1
        static let shadowOffset = CGSize(width: 0, height: 2)
    }
    
    enum Animation {
        static let defaultSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let slowSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    }
    
    enum Haptics {
        static let light = UIImpactFeedbackGenerator(style: .light)
        static let medium = UIImpactFeedbackGenerator(style: .medium)
        static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    }
} 