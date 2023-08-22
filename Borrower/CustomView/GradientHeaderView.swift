//
//  GradientHeaderView.swift
//  Borrower
//
//  Created by RX Group on 27.11.2020.
//

import UIKit

class GradientHeaderView: UIView {
    private lazy var rightColor = UIColor.init(displayP3Red: 52/255, green: 195/255, blue: 145/255, alpha: 1).cgColor
    private lazy var leftColor = UIColor.init(displayP3Red: 0/255, green: 137/255, blue: 170/255, alpha: 1).cgColor

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialization()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialization()
    }
    override func draw(_ rect: CGRect) {
        self.initialization()
    }
    func initialization(){
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [leftColor, rightColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.addSublayer(gradientLayer)
    }
}
