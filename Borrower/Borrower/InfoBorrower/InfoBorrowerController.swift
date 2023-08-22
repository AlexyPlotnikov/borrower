//
//  InfoBorrowerController.swift
//  Borrower
//
//  Created by RX Group on 09.02.2021.
//

import UIKit

class InfoBorrowerController: UIViewController {
    struct Loan:Codable{
        var id:String? = ""
        var borrowerId:String = ""
        var nextPaymentDate:String? = ""
        var loanDate:String = ""
        var loanAmount:Int = 0
        var loanPercent:Double = 0.0
        var accrualPeriod:Int = 2
        var paymentScheduleType:Int = 1
        var monthlyPaymentAmount:Int = 0
        var earlyPaymentAmount:Int = 0
        var paymentDay:Int = 1
        var paymentMethod:Int = 1
        var nextPaymenAmount:Int = 1
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
      }
    
    @IBOutlet weak var table: UITableView!
    var borrower = BorrowerItem()
    @IBOutlet weak var nameLbl: UILabel!
    var arrayLoan:[Loan]!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateBorrower()
        nameLbl.text = borrower.title
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBorrower), name: .updateBorrowers, object: nil)
    }
    
    @objc func updateBorrower(){
        refreshToken {
            getRequest(URLString: mainDomen + "/api/loans/all/\(self.borrower.id!)/false", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.arrayLoan = try! JSONDecoder().decode([Loan].self, from: jsonData)
                       self.table.reloadData()
                    }catch{

                    }
                }
            })
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editName(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "addBorrowerVC") as! AddBorrowerController
        viewController.borrower.borrowerPhones = self.borrower.borrowerPhones ?? []
        viewController.borrower.title = self.borrower.title ?? ""
        viewController.borrowerUpdate.id = self.borrower.id!
        viewController.newLoan = true
        if(self.borrower.borrowerFiles?.count ?? [].count > 0){
            if let url = URL(string: mainDomen + "/api/borrowers/files/" + self.borrower.borrowerFiles![0]) {
                                    self.downloadImage(from:url , success: { (image) in
                                        viewController.documents.firstPagePhoto = image
                                        viewController.collectionView.reloadData()
                                    }, failure: { (failureReason) in
                                        print(failureReason)
                                    })
                                }
            if let url = URL(string: mainDomen + "/api/borrowers/files/" + self.borrower.borrowerFiles![1]) {
                                    self.downloadImage(from:url , success: { (image) in
                                        viewController.documents.secondPagePhoto = image
                                        viewController.collectionView.reloadData()
                                    }, failure: { (failureReason) in
                                        print(failureReason)
                                    })
                                }
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
    }
    
    

}


extension InfoBorrowerController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            if(borrower.borrowerFiles?.count ?? 0 > 0){
                return 58
            }else{
                return 164
            }
            
        }else{
            return 164
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(borrower.borrowerFiles?.count ?? 0 > 0){
            if(self.arrayLoan != nil){
                return self.arrayLoan.count + 1
            }else{
                return 1
            }
        }else{
            if(self.arrayLoan != nil){
                return self.arrayLoan.count
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0 && borrower.borrowerFiles?.count ?? 0 > 0){
            let cellReuseIdentifier = "docCell"
            let cell:InfoBorrowerCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! InfoBorrowerCell
            
            return cell
        }else{
            let cellReuseIdentifier = "pledgeCell"
            let cell:InfoBorrowerCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! InfoBorrowerCell
            let loan = self.arrayLoan[(borrower.borrowerFiles?.count ?? 0 > 0) ? indexPath.row-1 : indexPath.row]
            cell.costLbl.text = "\(loan.loanAmount.formattedWithSeparator)"
            if(borrower.nextPaymentDate != nil){
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let date = dateFormatter.date(from:loan.nextPaymentDate!)!
                let dateFormatter1 = DateFormatter()
                dateFormatter1.locale = Locale(identifier: "ru_RU")
                dateFormatter1.dateFormat = "dd MMM"
                cell.dateLbl.text = "\(loan.nextPaymenAmount.formattedWithSeparator) руб" + " заплатит \(dateFormatter1.string(from: date))"
            }else{
                cell.dateLbl.text = "Нет данных"
            }
          //  cell.pledgelbl.text = borrower.
            
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0 && borrower.borrowerFiles?.count ?? 0 > 0){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "docBorrowerVC") as!  DocementsBorrowerController
                viewController.filesArray = borrower.borrowerFiles!
                self.navigationController?.pushViewController(viewController, animated: true)
        }else{
            let alert = UIAlertController(title: "", message: "Пожалуйста, выберите действие", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Редактировать займ", style: .default , handler:{ (UIAlertAction)in
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "addBorrowerVC") as! AddBorrowerController
                viewController.borrower.borrowerPhones = self.borrower.borrowerPhones ?? []
                viewController.borrower.title = self.borrower.title ?? ""
                viewController.borrowerUpdate.id = self.borrower.id!
                if(self.arrayLoan.count > 0){
                    getDictionaryRequest(URLString: mainDomen + "/api/loans/loan/\(self.arrayLoan[(self.borrower.borrowerFiles?.count ?? 0 > 0) ? indexPath.row-1 : indexPath.row].id!)", completion: {
                                    result in
                                    DispatchQueue.main.async {
                                        //подгрузка "Документов"
                                        if(self.borrower.borrowerFiles?.count ?? [].count > 0){
                                            if let url = URL(string: mainDomen + "/api/borrowers/files/" + self.borrower.borrowerFiles![0]) {
                                                                    self.downloadImage(from:url , success: { (image) in
                                                                        viewController.documents.firstPagePhoto = image
                                                                        viewController.collectionView.reloadData()
                                                                    }, failure: { (failureReason) in
                                                                        print(failureReason)
                                                                    })
                                                                }
                                            if let url = URL(string: mainDomen + "/api/borrowers/files/" + self.borrower.borrowerFiles![1]) {
                                                                    self.downloadImage(from:url , success: { (image) in
                                                                        viewController.documents.secondPagePhoto = image
                                                                        viewController.collectionView.reloadData()
                                                                    }, failure: { (failureReason) in
                                                                        print(failureReason)
                                                                    })
                                                                }
                                        }
                                        
                                        if((result["pledges"] as? NSArray)?.count ?? [].count > 0){
                                            if((((result["pledges"] as! NSArray)[0] as! [String:Any])["pledgeFiles"] as? NSArray)?.count ?? [].count > 0){
                                                if let pledgeID = (((result["pledges"] as! NSArray)[0] as! [String:Any])["pledgeFiles"] as! NSArray)[0] as? String{
                                                    if let url = URL(string: mainDomen + "/api/pledges/files/" + pledgeID) {
                                                                            self.downloadImage(from:url , success: { (image) in
                                                                                viewController.documents.photoPledge = image
                                                                                viewController.collectionView.reloadData()
                                                                            }, failure: { (failureReason) in
                                                                                print(failureReason)
                                                                            })
                                                                        }
                                                }
                                            }
                                           
                                        }
                                        
                                        
                                        //подгрузка займа
                                        viewController.currentLoan.id = (result["id"] as? String) ?? ""
                                        viewController.currentLoan.accrualPeriod = (result["accrualPeriod"] as? Int) ?? 0
                                        viewController.currentLoan.loanAmount = (result["loanAmount"] as? Int) ?? 0
                                        viewController.currentLoan.loanDate = (result["loanDate"] as? String) ?? ""
                                        if(viewController.currentLoan.loanDate != ""){
                                            viewController.countOfBorrow = 1
                                            viewController.sectionCount = 4
                                        }
                                        viewController.currentLoan.loanPercent = (result["loanPercent"] as? Double) ?? 0.0
                                        viewController.currentLoan.borrowerId = (result["borrowerId"] as? String) ?? ""
                                        viewController.currentLoan.earlyPaymentAmount = (result["earlyPaymentAmount"] as? Int) ?? 0
                                        viewController.currentLoan.monthlyPaymentAmount = (result["monthlyPaymentAmount"] as? Int) ?? 0
                                        viewController.currentLoan.paymentDay = (result["paymentDay"] as? Int) ?? 0
                                        viewController.currentLoan.paymentMethod = (result["paymentMethod"] as? Int) ?? 0
                                        viewController.currentLoan.paymentScheduleType = (result["paymentScheduleType"] as? Int) ?? 0
                                       
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                        if(dateFormatter.date(from:(result["loanDate"] as? String) ?? "") == nil){
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                                        }
                                        let dateformatter2 = DateFormatter()
                                        dateformatter2.dateStyle = .medium
                                        dateformatter2.locale = NSLocale.init(localeIdentifier: "ru") as Locale
                                        viewController.shownDate = dateformatter2.string(from: dateFormatter.date(from: (result["loanDate"] as? String) ?? "")!)
                                        
                                        //загрузка данных о залоге
                                        if((result["pledges"] as? NSArray)?.count ?? [].count > 0){
                                            let pledge = (result["pledges"] as! NSArray)
                                            print(pledge)
                                            viewController.currentPledge.id = (((result["pledges"] as! NSArray)[0] as! [String:Any])["id"] as! String)
                                            viewController.currentPledge.description = ((result["pledges"] as! NSArray)[0] as! [String:Any])["description"] as! String
                                            viewController.currentPledge.loanId = ((result["pledges"] as! NSArray)[0] as! [String:Any])["loanId"] as! String
                                            viewController.currentPledge.pledgeAmount = ((result["pledges"] as! NSArray)[0] as! [String:Any])["pledgeAmount"] as! Int
                                           // viewController.currentPledge.pledgeTypeId = ((result["pledges"] as! NSArray)[0] as! [String:Any])["id"] as! String
                                        }
                                        
                                        //загрузка инвестора "Собственные средства"
                                        let arrayInvestments = result["investments"] as? [[String:Any]] ?? [[:]]
                                        if arrayInvestments.contains(where: {$0["investorTitle"] as! String == "CОБСТВЕННЫЕ СРЕДСТВА"}) {
                                            viewController.countOfBorrow = 2
                                            viewController.sectionCount = 5
                                            let foo = arrayInvestments.first(where: {$0["investorTitle"] as! String == "CОБСТВЕННЫЕ СРЕДСТВА"})!
                                            viewController.ownInvestment.id = (foo["id"] as! String)
                                            viewController.ownInvestment.accrualPeriod = foo["accrualPeriod"] as! Int
                                            viewController.ownInvestment.investmentAmount = foo["investmentAmount"] as! Int
                                            viewController.ownInvestment.investmentDate = foo["investmentDate"] as! String
                                            viewController.ownInvestment.investmentPercent = foo["investmentPercent"] as! Double
                                            viewController.ownInvestment.investorId = foo["investorId"] as! String
                                            viewController.ownInvestment.loanId = foo["loanId"] as! String
                                            viewController.ownInvestment.monthlyPaymentAmount = foo["monthlyPaymentAmount"] as! Int
                                            viewController.ownInvestment.paymentDay = foo["paymentDay"] as! Int
                                            viewController.ownInvestment.paymentMethod = foo["paymentMethod"] as! Int
                                            viewController.ownInvestment.paymentScheduleType = foo["paymentScheduleType"] as! Int
                                          print(viewController.ownInvestment)
                                        }
                                    
                                        //загрузка данных об инвесторе
                                        
                                        if let foo = arrayInvestments.first(where: {$0["investorTitle"] as! String != "CОБСТВЕННЫЕ СРЕДСТВА"}){
                                            print("444444444")
                                            viewController.countOfBorrow = 2
                                            viewController.sectionCount = 5
                                            viewController.investorID = foo["investorId"] as! String
                                            viewController.investorName = foo["investorTitle"] as! String
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                            if(dateFormatter.date(from:(result["loanDate"] as? String) ?? "") == nil){
                                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                                            }
                                            let dateformatter2 = DateFormatter()
                                            dateformatter2.dateStyle = .medium
                                            dateformatter2.locale = NSLocale.init(localeIdentifier: "ru") as Locale
                                            viewController.shownInvestorDate = dateformatter2.string(from: dateFormatter.date(from: (foo["investmentDate"] as? String) ?? "")!)
                                            viewController.investorInvestment.id = (foo["id"] as! String)
                                            viewController.investorInvestment.accrualPeriod = foo["accrualPeriod"] as! Int
                                            viewController.investorInvestment.investmentAmount = foo["investmentAmount"] as! Int
                                            viewController.investorInvestment.investmentDate = foo["investmentDate"] as! String
                                            viewController.investorInvestment.investmentPercent = foo["investmentPercent"] as! Double
                                            viewController.investorInvestment.investorId = foo["investorId"] as! String
                                            viewController.investorInvestment.loanId = foo["loanId"] as! String
                                            viewController.investorInvestment.monthlyPaymentAmount = foo["monthlyPaymentAmount"] as! Int
                                            viewController.investorInvestment.paymentDay = foo["paymentDay"] as! Int
                                            viewController.investorInvestment.paymentMethod = foo["paymentMethod"] as! Int
                                            viewController.investorInvestment.paymentScheduleType = foo["paymentScheduleType"] as! Int
                                        }
                                            viewController.isUpdate = true
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        
                                        
                                    }
                                    
                                    
                                })
                                }
                           
                
            }))
            
           
            
            alert.addAction(UIAlertAction(title: "Удалить займ", style: .destructive, handler: {_ in
                deleteRequest(URLString: mainDomen + "/api/loans/delete/\(self.arrayLoan[(self.borrower.borrowerFiles?.count ?? 0 > 0) ? indexPath.row-1 : indexPath.row].id!)", completion: {
                    result in
                    if((result["errors"] as? [String:Any])?["errors"] != nil){
                        setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String , controller: self)

                    }else{
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }))
            
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))


            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        }
    }
   
    func downloadImage(from url: URL , success:@escaping((_ image:UIImage)->()),failure:@escaping ((_ msg:String)->())){
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                failure("Image cant download from G+ or fb server")
                return
            }

            DispatchQueue.main.async() {
                 if let _img = UIImage(data: data){
                      success(_img)
                }
            }
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
        request.addValue("Bearer \(mainUser.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request, completionHandler:completion).resume()
    }
    

}
