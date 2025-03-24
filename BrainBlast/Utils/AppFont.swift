//
//  AppFont.swift
//  FaceSwap
//
//  Created by Andrew Garcia on 11/19/24.
//

import SwiftUI

enum AppFontType: String, Codable {
    case system
    case rounded
    case inter
    
    func fontName(weight: Font.Weight, isItalic: Bool = false) -> String {
        switch self {
        case .inter:
            return isItalic ? interItalicFontName(for: weight) : interFontName(for: weight)
        default:
            return ""
        }
    }
    
    func navigationFontBig() -> UIFont {
        switch self {
        case .rounded:
            return UIFont.rounded(ofSize: 33, weight: .bold)
        case .inter:
            return UIFont(name: "Inter24pt-Bold", size: 33) ?? UIFont.systemFont(ofSize: 33, weight: .bold)
        default:
            return UIFont.systemFont(ofSize: 33, weight: .bold)
        }
    }
    
    func navigationFontSmall() -> UIFont {
        switch self {
        case .rounded:
            return UIFont.rounded(ofSize: 18, weight: .bold)
        case .inter:
            return UIFont(name: "Inter24pt-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        default:
            return UIFont.systemFont(ofSize: 18, weight: .bold)
        }
    }
    
    private func interFontName(for weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight:
            return "Inter24pt-Thin"
        case .light:
            return "Inter24pt-ExtraLight"
        case .regular:
            return "Inter24pt-Regular"
        case .medium:
            return "Inter24pt-Medium"
        case .semibold:
            return "Inter24pt-SemiBold"
        case .bold:
            return "Inter24pt-Bold"
        case .heavy:
            return "Inter24pt-ExtraBold"
        case .black:
            return "Inter24pt-Black"
        default:
            return "Inter24pt-Regular"
        }
    }
    
    private func interItalicFontName(for weight: Font.Weight) -> String {
        return weight == .regular ? "Inter24pt-Italic" : interFontName(for: weight)
    }
}

extension Text {
    func appFont(size: CGFloat, weight: Font.Weight = .bold, color: Color = AppColor.primaryText, type: AppFontType? = nil) -> Text {
        let fontType = type ?? UserDefaults.standard.fontType
        return self.font(Font.appFont(size: size, weight: weight, type: fontType)).foregroundColor(color)
    }
    
    func appFont(size: CGFloat, weight: Font.Weight = .bold, gradient: LinearGradient, type: AppFontType? = nil) -> Text {
        let fontType = type ?? UserDefaults.standard.fontType
        return self.font(Font.appFont(size: size, weight: weight, type: fontType)).foregroundStyle(gradient)
    }
}

extension Font {
    static func appFont(size: CGFloat, weight: Font.Weight = .bold, type: AppFontType = Constants.UI.defaultFontType, isItalic: Bool = false) -> Font {
        switch type {
        case .system:
            return Font.system(size: size, weight: weight, design: .default)
        case .rounded:
            return Font.system(size: size, weight: weight, design: .rounded)
        case .inter:
            return Font.custom(type.fontName(weight: weight, isItalic: isItalic), size: size)
        }
    }
}

extension Label {
    func appFont(size: CGFloat, weight: Font.Weight = .bold, color: Color = AppColor.primaryText, type: AppFontType = .inter) -> some View {
        self
            .font(Font.appFont(size: size, weight: weight, type: type))
            .foregroundColor(color)
    }
}

import UIKit

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}

// Add this extension to handle UserDefaults
extension UserDefaults {
    var fontType: AppFontType {
        get {
            if let rawValue = string(forKey: Constants.UserDefaults.fontStyle),
               let fontType = AppFontType(rawValue: rawValue) {
                return fontType
            }
            return .rounded // Default value
        }
        set {
            set(newValue.rawValue, forKey: Constants.UserDefaults.fontStyle)
        }
    }
}
