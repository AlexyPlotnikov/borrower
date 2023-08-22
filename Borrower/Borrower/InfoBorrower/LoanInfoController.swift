//
//  LoanInfoController.swift
//  Borrower
//
//  Created by Иван Зубарев on 13.04.2021.
//

import UIKit

class LoanInfoController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

   

}


extension LoanInfoController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "moneyCell"
        let cell:LoanInfoCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! LoanInfoCell
        
        
        return cell
    }
    
    
    
}
