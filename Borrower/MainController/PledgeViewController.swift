//
//  PledgeViewController.swift
//  Borrower
//
//  Created by RX Group on 07.04.2021.
//

import UIKit

class PledgeViewController: UIViewController {

    @IBOutlet weak var pledgeTitle: UILabel!
    var currentPledge = PledgeModel()
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pledgeTitle.text = currentPledge.pledgeTitle
        costTextField.text = "\(currentPledge.pledgeAmount.formattedWithSeparator) руб"
        if(currentPledge.pledgeFiles?.count ?? 0 > 0){
            mainImage.loadImageUsingCache(withUrl:mainDomen + "/api/pledges/files/" + currentPledge.pledgeFiles![0])
        }else{
            mainImage.image = UIImage(named: "emptyPledge")
        }
        
        let cellSize = CGSize(width:collectionView.frame.size.width/3 - 32 , height:75)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}


extension PledgeViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPledge.pledgeFiles?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PledgeViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PledgeViewCell
        
        if(currentPledge.pledgeFiles!.count > 0){
            cell.pledgeImage.loadImageUsingCache(withUrl:mainDomen + "/api/pledges/files/" + currentPledge.pledgeFiles![indexPath.row])
            cell.pledgeImage.layer.cornerRadius = 8
        }else{
            cell.pledgeImage.image = UIImage(named: "emptyPledge")
        }
        cell.pledgeImage.layer.cornerRadius = 8
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainImage.loadImageUsingCache(withUrl:mainDomen + "/api/pledges/files/" + currentPledge.pledgeFiles![indexPath.row])
    }
}
