import Foundation
import UIKit

// Part 1: Memory Management Implementation - Profile Management System

protocol ProfileUpdateDelegate: AnyObject { // Restrict to reference types to avoid retain cycles when delegate is held strongly
    func profileDidUpdate(_ profile: UserProfile)
    func profileLoadingError(_ error: Error)
}

class ProfileManager {
    private var activeProfiles: [String: UserProfile] = [:] // Dictionary for fast lookup by String ID
    weak var delegate: ProfileUpdateDelegate? // Weak reference to avoid retain cycle
    var onProfileUpdate: ((UserProfile) -> Void)?

    init(delegate: ProfileUpdateDelegate) {
        self.delegate = delegate
    }

    func loadProfile(id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        // Simulate profile loading with a delay
        DispatchQueue.global().async { [weak self] in // Capture self weakly to avoid retain cycle
            // Simulate network request or database fetch
            Thread.sleep(forTimeInterval: 1)
            let result: Result<UserProfile, Error>
            if id.isEmpty {
                result = .failure(NSError(domain: "ProfileErrorDomain", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid ID"]))
            } else {
                let profile = UserProfile(id: UUID(), username: "user_\(id)", bio: "Bio for \(id)", followers: Int.random(in: 0...1000))
                self?.activeProfiles[id] = profile // Store in active profiles
                result = .success(profile)
            }
            DispatchQueue.main.async {
                completion(result)
                switch result {
                case .success(let profile):
                    self?.delegate?.profileDidUpdate(profile) // Delegate call - weak delegate prevents cycle
                    self?.onProfileUpdate?(profile) // Closure call - no retain cycle concern here unless self is captured strongly in onProfileUpdate's implementation outside of ProfileManager
                case .failure(let error):
                    self?.delegate?.profileLoadingError(error) // Delegate error call
                }
            }
        }
    }
}

class UserProfileViewController: UIViewController, ProfileUpdateDelegate { // Conform to ProfileUpdateDelegate
    weak var profileManager: ProfileManager? // Weak reference if ViewController does not own ProfileManager
    weak var imageLoader: ImageLoader? // Weak reference if ViewController does not own ImageLoader

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileManager()
    }

    func setupProfileManager() {
        let manager = ProfileManager(delegate: self) // Pass self as delegate
        profileManager = manager // Assign weak reference
        manager.onProfileUpdate = { [weak self] profile in // Capture self weakly in closure
            print("Profile updated via closure in ViewController: \(profile.username)")
            // Update UI with profile data
        }
    }

    func updateProfile() {
        profileManager?.loadProfile(id: "123") { [weak self] result in // Capture self weakly in completion handler
            switch result {
            case .success(let profile):
                print("Profile loaded successfully in ViewController: \(profile.username)")
                // Update UI
            case .failure(let error):
                print("Profile loading failed in ViewController: \(error.localizedDescription)")
                // Handle error
            }
        }
    }

    // ProfileUpdateDelegate methods
    func profileDidUpdate(_ profile: UserProfile) {
        print("Delegate method called: Profile updated: \(profile.username)")
        // Handle profile update in ViewController
    }

    func profileLoadingError(_ error: Error) {
        print("Delegate method called: Profile loading error: \(error.localizedDescription)")
        // Handle profile loading error
    }
}
