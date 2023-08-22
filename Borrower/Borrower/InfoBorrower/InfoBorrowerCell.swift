//
//  InfoBorrowerCell.swift
//  Borrower
//
//  Created by RX Group on 09.02.2021.
//

import UIKit

class InfoBorrowerCell: UITableViewCell {

    @IBOutlet weak var pledgelbl: UILabel!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
