//
//  MainCell.swift
//  Borrower
//
//  Created by RX Group on 27.11.2020.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var leftSubtitle: UILabel!
    @IBOutlet weak var rightTitle: UILabel!
    @IBOutlet weak var rightSubtitle: UILabel!
    @IBOutlet weak var chartView: UIView!
   
    
    @IBOutlet weak var statRate: UILabel!
    @IBOutlet weak var statProfit: UILabel!
    @IBOutlet weak var statView: TouchableChartView!
    
    @IBOutlet weak var pledgeImage: UIImageView!
    @IBOutlet weak var pledgeTitle: UILabel!
    @IBOutlet weak var pledgeCost: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
