//
//  ChooseInvestorController.swift
//  Borrower
//
//  Created by RX Group on 11.02.2021.
//

import UIKit

class ChooseInvestorController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var embededController:AddBorrowerController!
    var investorsArray:[Investor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ChooseInvestorController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return investorsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if(cell == nil){
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
        
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = investorsArray[indexPath.row].title
            cell?.textLabel?.textColor = .white
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        embededController.investorInvestment.investorId = investorsArray[indexPath.row].id!
        embededController.investorName = investorsArray[indexPath.row].title!
        self.dismiss(animated: true, completion: {
            self.embededController.collectionView.reloadData()
        })
        
    }
    
    
}
