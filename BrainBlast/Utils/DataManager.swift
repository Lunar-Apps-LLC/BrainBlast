//import Foundation
//import Combine
//
//@MainActor
//final class DataManager: ObservableObject {
//    static let shared = DataManager()
//    
//    @Published private(set) var videos: [Video] = []
//    private var cancellables = Set<AnyCancellable>()
//    
//    var hasGeneratingVideo: Bool {
//        let twentyMinutesAgo = Date().addingTimeInterval(-20 * 60)
//        return videos.contains { video in
//            video.status == .generating && video.createdAt > twentyMinutesAgo
//        }
//    }
//    
//    private init() {
//        setupVideoListener()
//    }
//    
//    private func setupVideoListener() {
//        API.Videos.startVideoListener { [weak self] videos in
//            self?.videos = videos.sorted { $0.createdAt > $1.createdAt }
//        }
//    }
//    
//    deinit {
//        API.Videos.stopVideoListener()
//    }
//} 
