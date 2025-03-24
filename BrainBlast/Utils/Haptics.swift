//
//  Haptics.swift
//  FaceSwap
//
//  Created by Andrew Garcia on 11/19/24.
//

import UIKit

struct Haptics {
    static func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    static func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
