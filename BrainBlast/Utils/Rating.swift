//
//  Rating.swift
//  FaceSwap
//
//  Created by Andrew Garcia on 11/19/24.
//

import Foundation
import StoreKit

struct Rating {
    static func request() {
        SKStoreReviewController.requestReviewInCurrentScene()
    }
}

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            requestReview(in: scene)
        }
    }
}
