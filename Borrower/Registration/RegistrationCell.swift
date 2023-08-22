//
//  RegistrationCell.swift
//  Borrower
//
//  Created by RX Group on 03.12.2020.
//

import UIKit

class RegistrationCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var phoneField: JMMaskTextField!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
