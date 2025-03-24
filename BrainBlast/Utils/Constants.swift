//
//  Constants.swift
//  AIVideoGenerator
//
//  Created by Andrew Garcia on 3/4/25.
//

struct Constants {
    struct General {
        static let baseAPIURL = "https://aivideogenerator-7a2c8cb26ea4.herokuapp.com/api/v1"
        static let termsURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        static let privacyURL = "https://ainotes-2e0904345545.herokuapp.com/privacy_policy.html"
        static let appURL = "https://apps.apple.com/us/app/wellnoted/id6741928766"
    }
    
    struct UserDefaults {
        static let hasPremium = "AIVideoGenerator.HasPremium"
        static let hasSeenOnboarding = "AIVideoGenerator.HasSeenOnboarding"
        static let fontStyle = "AIVideoGenerator.FontStyle"
    }
    
    struct RevenueCat {
        static let apiKey = "appl_IPQgQPGiTlACYrZMoPkRdurqroW"
    }
    
    struct UI {
        static let defaultFontType: AppFontType = .system
    }
}
