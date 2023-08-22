//
//  WorkerCell.swift
//  Borrower
//
//  Created by RX Group on 24.12.2020.
//

import UIKit

class WorkerCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var role: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
