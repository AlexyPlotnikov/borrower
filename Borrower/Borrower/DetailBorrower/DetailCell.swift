//
//  DetailCell.swift
//  Borrower
//
//  Created by RX Group on 30.11.2020.
//

import UIKit

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var colorDot: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var summLbl: UILabel!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        colorDot.layer.cornerRadius = colorDot.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
