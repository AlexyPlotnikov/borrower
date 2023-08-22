//
//  NoInternetView.swift
//  Borrower
//
//  Created by RX Group on 04.02.2021.
//

import UIKit

class NoInternetView: UIView {

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .black
            let image = UIImageView(frame: CGRect(x: self.frame.size.width/2-238/2, y: self.frame.size.height/2-238/2, width: 238, height: 238))
            image.image = UIImage(named: "noInternet")
            self.addSubview(image)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            
        }
        
    


}
