//
//  DetailController.swift
//  Borrower
//
//  Created by RX Group on 30.11.2020.
//

import UIKit

struct BorrowerItem:Codable{
    var id:String? = ""
    var contractorId:String? = ""
    var title:String? = ""
    var debtBalance:Int? = 0
    var nextPaymentDate:String? = ""
    var nextPaymenAmount:Int? = 0
    var borrowerPhones:[String]? = [""]
    var borrowerFiles:[String]? = [""]
}

class DetailController: UIViewController {
    
    @IBOutlet weak var mainTitle: UILabel!
    var detailArray:[BorrowerItem] = []
    @IBOutlet weak var table: UITableView!
    var investorID:String = ""
    @IBOutlet weak var emptyListLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.tableFooterView = UIView()
        self.updateBorrowers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBorrowers), name: .updateBorrowers, object: nil)
        
    }
    @objc func updateBorrowers(){
        refreshToken(controller: self, completion: {
            getRequest(URLString: mainDomen + "/api/borrowers/all/false", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.detailArray = try! JSONDecoder().decode([BorrowerItem].self, from: jsonData)
                       self.emptyListLbl.isHidden = self.detailArray.count != 0
                       self.table.isHidden = self.detailArray.count == 0
                       self.table.reloadData()
                       
                    }catch{

                    }
                }

            })
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .chooseRow, object: nil, userInfo: ["row":1])
    }
    @IBAction func filterAction(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "addBorrowerVC") as! AddBorrowerController
        viewController.investorID = investorID
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func getColorByFilter(filter:Int)->UIColor{
        switch filter {
        case 0:
            return UIColor.init(displayP3Red: 246/255, green: 90/255, blue: 59/255, alpha: 1)
        case 1:
            return UIColor.init(displayP3Red: 237/255, green: 170/255, blue: 59/255, alpha: 1)
        default:
            return UIColor.init(displayP3Red: 40/255, green: 190/255, blue: 130/255, alpha: 1)
        
        }
    }
    func getCountDays(date:String) -> DateComponents{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from:date)!
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailController:UITableViewDelegate,UITableViewDataSource{
    
   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
            return true
       
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            deleteRequest(URLString: mainDomen + "/api/borrowers/delete/\(detailArray[indexPath.row].id!)", completion: {
                result in
                if((result["errors"] as? [String:Any])?["errors"] != nil){
                    setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String , controller: self)

                }else{
                    DispatchQueue.main.async {
                        self.detailArray.remove(at: indexPath.row)
                        self.table.reloadData()
                    }
                }
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell:DetailCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailCell
       

            let rowDetail = detailArray[indexPath.row]
                cell.colorDot.backgroundColor = self.getColorByFilter(filter: 3)
                cell.nameLbl.text = rowDetail.title
                cell.summLbl.text = "\(rowDetail.debtBalance?.formattedWithSeparator ?? "0") руб."
                cell.costLbl.text = "\(rowDetail.nextPaymenAmount?.formattedWithSeparator ?? "0") руб."
            if(rowDetail.nextPaymentDate != nil){

                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let date = dateFormatter.date(from:rowDetail.nextPaymentDate ?? "")!
                let dateFormatter1 = DateFormatter()
                dateFormatter1.locale = Locale(identifier: "ru_RU")
                dateFormatter1.dateFormat = "dd MMM yyyy"
                if(date < Date()){
                    cell.dateLbl.text = "Просрочил"
                }else{
                    cell.dateLbl.text = "заплатит до \(dateFormatter1.string(from: date))"
                }
                
            }else{
                cell.dateLbl.text = "Нет данных"
            }
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "infoBorrowerVC") as! InfoBorrowerController
                viewController.borrower = detailArray[indexPath.row]
                self.navigationController?.pushViewController(viewController, animated: true)
        
    }
}
