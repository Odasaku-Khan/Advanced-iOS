import Foundation

// Part 2: Collections Optimization - Feed System Implementation

class FeedSystem {
    private var userCache: [UUID: UserProfile] = [:] // Dictionary for O(1) lookup by UserID (UUID)
    private var feedPosts: [Post] = [] // Array for ordered posts, efficient insertion at beginning
    private var hashtags: Set<String> = [] // Set for unique hashtags and fast lookup

    func addPost(_ post: Post) {
        feedPosts.insert(post, at: 0) // Insert at the beginning for new posts in feed
        extractHashtags(from: post.content).forEach { hashtags.insert($0) } // Add unique hashtags
    }

    func removePost(_ post: Post) {
        if let index = feedPosts.firstIndex(where: { $0 == post }) { // Equatable conformance on Post is used here
            feedPosts.remove(at: index) // Remove post from feed
            // Hashtags are not automatically removed upon post removal in this simplified example.
            // In a real app, you might want to update hashtags based on remaining posts.
        }
    }

    func getUserProfile(userID: UUID) -> UserProfile? {
        return userCache[userID] // O(1) lookup in dictionary
    }

    func cacheUserProfile(_ profile: UserProfile) {
        userCache[profile.id] = profile // Store profile in cache with UserID as key
    }

    private func extractHashtags(from text: String) -> [String] {
        let hashtagRegex = try! NSRegularExpression(pattern: "#\\w+", options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = hashtagRegex.matches(in: text, options: [], range: range)
        return matches.map { (text as NSString).substring(with: $0.range) }
    }
}
