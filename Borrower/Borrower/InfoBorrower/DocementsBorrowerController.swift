//
//  DocementsBorrowerController.swift
//  Borrower
//
//  Created by RX Group on 09.02.2021.
//

import UIKit

class DocementsBorrowerController: UIViewController {
    
    var filesArray:[String] = []
    var titlesArray:[String] = ["Паспорт (прописка)","Паспорт (главная)", "Недвижимость"]

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellSize = CGSize(width:collectionView.frame.size.width/2 - 32 , height:100)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func selectPhoto(button:UIButton){
        let indexPath = IndexPath(row: button.tag, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? DocBorrowerCell {
            let appImage = ViewerImage.appImage(forImage: cell.imageDoc.image!)
            let viewer = AppImageViewer(photos: [appImage])
            self.navigationController?.present(viewer, animated: true, completion: nil)
        }
    }
}


extension DocementsBorrowerController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:DocBorrowerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "docCell", for: indexPath) as! DocBorrowerCell
        if(indexPath.row < 2){
            cell.imageDoc.loadImageUsingCache(withUrl:mainDomen + "/api/borrowers/files/" + filesArray[indexPath.row])
        }else{
            cell.imageDoc.loadImageUsingCache(withUrl:mainDomen + "/api/pledges/files/" + filesArray[indexPath.row])
        }
        cell.nameDoc.text = titlesArray[indexPath.row]
        cell.contentView.layer.cornerRadius = 12
        cell.docBtn.tag = indexPath.row
        cell.docBtn.addTarget(self, action: #selector(self.selectPhoto(button:)), for: .touchUpInside)
        
        return cell
        
    }
    
   
    
   
}
