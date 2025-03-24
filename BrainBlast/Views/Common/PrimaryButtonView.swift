//
//  PrimaryButtonView.swift
//  AINotes
//
//  Created by Andrew Garcia on 1/10/25.
//

import SwiftUI

struct PrimaryButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var is3D: Bool
    let cornerRadius: CGFloat = 12
    var backgroundColor: Color? = nil
    var fontColor: Color? = nil
    var isDisabled: Bool = false
    var isLoading: Bool = false
    let action: () -> Void
    
    var reallyDisabled: Bool {
        return isDisabled || isLoading
    }

    var body: some View {
        Button(action: {
            if !reallyDisabled {
                action()
            }
        }) {
            if isLoading {
                ProgressView()
            } else {
                Text(title)
                    .appFont(size: 18, weight: .bold, color: fontColor != nil ? fontColor! : (isDisabled ? .gray : AppColor.primaryButtonText), type: .inter)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(is3D ? 
            AnyButtonStyle(ThreeD(isDarkMode: colorScheme == .dark, cornerRadius: cornerRadius, backgroundColor: backgroundColor, isDisabled: reallyDisabled)) :
            AnyButtonStyle(Flat(cornerRadius: cornerRadius, backgroundColor: backgroundColor, isDisabled: reallyDisabled)))
        .frame(height: 50)
    }
}

struct PrimaryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButtonView(title: "Continue", is3D: true, action: { /* No action needed for preview. */ })
            PrimaryButtonView(title: "Continue", is3D: false, action: { /* No action needed for preview. */ })
            PrimaryButtonView(title: "Continue", is3D: false, isLoading: true, action: { /* No action needed for preview. */ })
            PrimaryButtonView(title: "Continue", is3D: true, backgroundColor: .green, action: { /* No action needed for preview. */ })
            PrimaryButtonView(title: "Continue", is3D: false, backgroundColor: .green, action: { /* No action needed for preview. */ })
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.primaryBackground)
    }
}

// MARK: Button Styles

struct ThreeD: ButtonStyle {
    var isDarkMode: Bool
    var cornerRadius: CGFloat
    var backgroundColor: Color? = nil
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            let offset: CGFloat = 5
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(!isDarkMode ? (isDisabled ? .gray.opacity(0.3) : (backgroundColor != nil ? backgroundColor! : AppColor.primaryButtonBackground)) : .gray)
                .offset(y: offset)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(isDarkMode ? 
                    (isDisabled ? .gray.opacity(0.3) : (backgroundColor != nil ? backgroundColor! : AppColor.primaryButtonBackground)) : 
                    (isDisabled ? .gray.opacity(0.3) : (backgroundColor != nil ? backgroundColor! : AppColor.primaryButtonBackground).lighter(by: 15)))
                .offset(y: isDisabled ? offset : (configuration.isPressed ? offset : 0))
            
            configuration.label
                .offset(y: isDisabled ? offset : (configuration.isPressed ? offset : 0))
        }
    }
}

struct Flat: ButtonStyle {
    var cornerRadius: CGFloat
    var backgroundColor: Color? = nil
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(isDisabled ? .gray.opacity(0.3) : (backgroundColor != nil ? backgroundColor! : AppColor.primaryButtonBackground))
            .overlay(
                configuration.label
                    .foregroundColor(isDisabled ? .gray : AppColor.primaryButtonText)
            )
            .cornerRadius(cornerRadius)
    }
}

struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}


