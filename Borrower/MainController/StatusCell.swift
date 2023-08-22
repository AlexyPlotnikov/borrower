//
//  StatusCell.swift
//  Borrower
//
//  Created by RX Group on 01.02.2021.
//

import UIKit

class StatusCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
