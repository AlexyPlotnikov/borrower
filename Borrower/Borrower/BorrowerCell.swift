//
//  BorrowerCell.swift
//  Borrower
//
//  Created by RX Group on 21.01.2021.
//

import UIKit

class BorrowerCell: UICollectionViewCell {
    
    @IBOutlet weak var textFieldBorrower: UITextField!
    @IBOutlet weak var titleBorrower: UILabel!
    @IBOutlet weak var phoneFieldBorrower: JMMaskTextField!
    @IBOutlet weak var imageBorrower: UIImageView!
    @IBOutlet weak var widthImage: NSLayoutConstraint!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var phoneBookBtn: UIButton!
    
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var photoLbl: UILabel!
    
    @IBOutlet weak var newBorrowBtn: UIButton!
    
    @IBOutlet weak var newInvestor: UIButton!
    
    @IBOutlet weak var invesotrNameLbl: UILabel!
    @IBOutlet weak var investorBtn: UIButton!
}
