
import UIKit

class InterestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var interestsTableView: UITableView!
    let hobbies: [Hobby] = [ // struct Hobby is now referenced here
        Hobby(name: "Coding", description: "Passionate about creating software and solving problems with code."),
        Hobby(name: "Reading", description: "Love getting lost in books, especially fantasy and sci-fi."),
        Hobby(name: "Hiking", description: "Enjoy exploring nature and challenging myself with mountain trails.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        interestsTableView.dataSource = self
        interestsTableView.delegate = self
        interestsTableView.register(InterestTableViewCell.self, forCellReuseIdentifier: "interestCell")
        interestsTableView.register(UINib(nibName: "InterestTableViewCell", bundle: nil), forCellReuseIdentifier: "interestCell")
        view.backgroundColor = UIColor.white
        interestsTableView.backgroundColor = UIColor.clear
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hobbies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCell", for: indexPath) as! InterestTableViewCell

        let hobby = hobbies[indexPath.row]
        cell.hobbyNameLabel.text = hobby.name

        return cell
    }
}
