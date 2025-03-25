//
//  ViewController.swift
//  lab1v2
//
//  Created by Ablaikhan Nusypakhin on 3/6/25.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
    }
    @IBAction func interestsButtonTapped(_ sender: UIButton) {
        let interestsVC = storyboard?.instantiateViewController(withIdentifier: "InterestsViewController") as! InterestsViewController
        navigationController?.pushViewController(interestsVC, animated: true)
    }

    @IBAction func goalsButtonTapped(_ sender: UIButton) {
        let goalsVC = storyboard?.instantiateViewController(withIdentifier: "GoalsViewController") as! GoalsViewController
        navigationController?.pushViewController(goalsVC, animated: true)
    }

}

