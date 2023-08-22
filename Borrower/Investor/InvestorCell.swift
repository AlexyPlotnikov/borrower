//
//  InvestorCell.swift
//  Borrower
//
//  Created by RX Group on 15.12.2020.
//

import UIKit

class InvestorCell: UITableViewCell {

    @IBOutlet weak var shield: UIView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var summLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var profitLbl: UILabel!
    @IBOutlet weak var allSummLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        shield.layer.cornerRadius = 7
//
//        let  p0 = CGPoint(x: 29, y: self.contentView.frame.origin.y + 16)
//        let  p1 = CGPoint(x: 29, y: self.contentView.frame.size.height)
//        self.drawDottedLine(start: p0, end: p1, view: self.contentView)
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.init(displayP3Red:47/255, green: 47/255, blue: 47/255, alpha: 1).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [8, 8] // 7 is the length of dash, 3 is length of the gap.

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.insertSublayer(shapeLayer, below: shield.layer)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
