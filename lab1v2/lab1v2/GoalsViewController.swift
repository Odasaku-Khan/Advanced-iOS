import UIKit

class GoalsViewController: UIViewController {
    @IBOutlet weak var goalsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        goalsTextView.text = "1. Become an iOS Developer\n2. Travel the world\n3. Learn SwiftUI\n4. Get second degree in Europe or Canada in 2027-28";
        goalsTextView.backgroundColor = UIColor.lightGray
        goalsTextView.textColor = UIColor.blue
        goalsTextView.font = UIFont.systemFont(ofSize: 18)
        view.backgroundColor=UIColor.cyan
    }
}
