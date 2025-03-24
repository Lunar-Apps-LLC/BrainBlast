//
//  AppColor.swift
//  FaceSwap
//
//  Created by Andrew Garcia on 11/19/24.
//

import UIKit
import SwiftUI

struct AppUIColor {
    static let primaryText: UIColor = UIColor(named: "PrimaryText")!
    static let secondaryText: UIColor = UIColor(named: "SecondaryText")!
    static let primaryBackground: UIColor = UIColor(named: "PrimaryBackground")!
    static let primaryButtonBackground: UIColor = UIColor(named: "PrimaryButtonBackground")!
    static let secondaryButtonBackground: UIColor = UIColor(named: "SecondaryButtonBackground")!
    static let primaryButtonText: UIColor = UIColor(named: "PrimaryButtonText")!
    static let primaryAccent: UIColor = UIColor(named: "PrimaryAccent")!
    static let secondaryBackground: UIColor = UIColor(named: "SecondaryBackground")!
    static let tertiaryBackground: UIColor = UIColor(named: "TertiaryBackground")!
}

struct AppColor {
    static let primaryText = Color(AppUIColor.primaryText)
    static let secondaryText = Color(AppUIColor.secondaryText)
    static let primaryBackground = Color(AppUIColor.primaryBackground)
    static let primaryButtonBackground = Color(AppUIColor.primaryButtonBackground)
    static let secondaryButtonBackground = Color(AppUIColor.secondaryButtonBackground)
    static let primaryButtonText = Color(AppUIColor.primaryButtonText)
    static let primaryAccent = Color(AppUIColor.primaryAccent)
    static let secondaryBackground = Color(AppUIColor.secondaryBackground)
    static let tertiaryBackground = Color(AppUIColor.tertiaryBackground)
}

extension AppColor {
    struct Gradient {
        static func linear(
            colors: [Color],
            startPoint: UnitPoint = .topLeading,
            endPoint: UnitPoint = .bottomTrailing
        ) -> LinearGradient {
            return LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        }
        
        // Predefined gradients
        static func orangePink(startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> LinearGradient {
            linear(
                colors: [Color(hex: "E1A810"), Color(hex: "EB3FF3")],
                startPoint: startPoint,
                endPoint: endPoint
            )
        }
    }
}
