import UIKit

class InterestTableViewCell: UITableViewCell {

    @IBOutlet weak var hobbyNameLabel: UILabel!
    @IBOutlet weak var hobbyImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
