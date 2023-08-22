//
//  TaskCell.swift
//  Borrower
//
//  Created by RX Group on 29.01.2021.
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var clockIcon: UIImageView!
    @IBOutlet weak var pledgeLbl: UILabel!
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var leftStatusView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
