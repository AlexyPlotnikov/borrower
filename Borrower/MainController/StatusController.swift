//
//  StatusController.swift
//  Borrower
//
//  Created by RX Group on 01.02.2021.
//

import UIKit

class StatusController: UIViewController {
    
    var embededViewCntroller:MainController!
    var indexBorrower:Int = 0
    var isToday:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func configStatus(status:Int) -> (UIColor,String){
        switch status {
        case 0:
            return (UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1),"Оплачено")
        case 1:
            return (UIColor.init(displayP3Red: 52/255, green: 163/255, blue: 231/255, alpha: 1),"Оплата сегодня")
        case 2:
            return (UIColor.init(displayP3Red: 57/255, green: 68/255, blue: 255/255, alpha: 1),"Оплата завтра")
        case 3:
            return (UIColor.init(displayP3Red: 237/255, green: 170/255, blue: 59/255, alpha: 1),"Перенос платежа")
        case 4:
            return (UIColor.init(displayP3Red: 246/255, green: 90/255, blue: 59/255, alpha: 1),"Не дозвонились")
        default:
            return (.white,"Звонка не было")
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

}



extension StatusController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "statusCell"
        let cell:StatusCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! StatusCell
        
        let (bgColor, titleStatus) = self.configStatus(status: indexPath.row)
        cell.statusView.backgroundColor=bgColor.withAlphaComponent(0.1)
        cell.statusLbl.text = titleStatus
        cell.statusLbl.textColor = bgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            embededViewCntroller.paymentMethod(index: indexBorrower)
        }else{
            if(isToday){
                embededViewCntroller.taskArray[indexBorrower].status = indexPath.row + 1
            }else{
                embededViewCntroller.tomorrowTaskArray[indexBorrower].status = indexPath.row + 1
            }
            embededViewCntroller.updateBorrower(index: indexBorrower)
           
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
