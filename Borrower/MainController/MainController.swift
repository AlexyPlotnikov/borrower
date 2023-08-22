//
//  MainController.swift
//  Borrower
//
//  Created by RX Group on 14.01.2021.
//

import UIKit


struct Investor:Codable{
    var id:String?
    var title:String?
    var isOwnFunds:Bool?
    var investorPhones:[String]?
    var nextPaymentDate:String?
    var nextPaymenAmount:Int?
    var debtBalance:Int?
   
    var investments:[Investments]?
}

struct Investments:Codable{
    var id:String?
    var borrowerTitle:String?
    var investorTitle:String?
    var investmentAmount:Int?
    var investmentDate:String?
    var investmentPercent:Double?
    var nextPaymentDate:String?
    var nextPaymenAmount:Int?
    var debtPaymentsAmount:Int?
    var accrualPeriod:Int?
}

extension Notification.Name {
    public static let openProfile = Notification.Name(rawValue: "openProfile")
    public static let chooseRow = Notification.Name(rawValue: "chooseRow")
    public static let updateBorrowers = Notification.Name(rawValue: "updateBorrowers")
}

enum ChosenRow:Int{
    case tasks = 1 //вкладка Клиенты
    case investor = 2 //вкладка Инвестор
    case pledge = 3 //вкладка Имущество
}

struct PledgeModel:Codable {
    var description:String = ""
    var id:String = ""
    var loanId:String = ""
    var pledgeAmount:Int = 0
    var pledgeFiles:[String]? = []
    var pledgeTitle:String = ""
}

class MainController: UIViewController {
    enum TaskDay:Int{
        case today = 0 //Сегодня
        case tomorrow = 1 //Завтра
    }
    
    
    
    struct InvestorModel:Codable{
        var isPaid:Bool = false
        var paymentAmount:Int = 0
    }
    
    struct TaskModel:Codable {
        var loanId:String = ""
        var borrowerId:String = ""
        var borrowerTitle:String = ""
        var borrowerPhones:[String] = []
        var pledges:[String] = []
        var paymentScheduleId:String = ""
        var paymentType:Int = 0
        var paymentMethod:Int = 0
        var status:Int = 0
        var paymentDate:String = ""
        var paymentAmount:Int = 0
        var comment:String? = ""
        var isPaid:Bool = false
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
    }
    
    var chosenRow = ChosenRow(rawValue: 1)
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var plusInvest: UIButton!
    
    var currentTextField:UITextField!
    

    var borrowersArray:Array<Any> = []
    var currentDayBorrower:Array<Any> = []
    
    var investorsArray:[Investor]=[]
    
    var taskArray:[TaskModel]=[]
    var tomorrowTaskArray:[TaskModel]=[]
    
    var investorTaskArray:[InvestorModel] = []
    
    var pledgeArray:[PledgeModel] = []
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    var investorID:String = ""
    var currentDay = TaskDay(rawValue: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.openProfile), name: .openProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.chooseRow(notification:)), name: .chooseRow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        segment.setTitleColor(UIColor.init(displayP3Red: 40/255, green: 214/255, blue: 204/255, alpha: 1))
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        self.table.tableFooterView = UIView()
        self.reloadDataTable()
       
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    func reloadDataTable(){
        refreshToken(controller: self, completion: {
            //запрос тасков
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd"
            getRequest(URLString: mainDomen + "/api/tasks/loan/with_previous/\(formatter1.string(from: Date()))", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.taskArray = try! JSONDecoder().decode([TaskModel].self, from: jsonData)
                        
                        if(self.chosenRow == .tasks){
                            self.emptyImg.isHidden = self.taskArray.count > 0
                            self.emptyLbl.isHidden = self.taskArray.count > 0
                            self.table.isHidden = self.taskArray.count < 1
                           self.table.reloadData()
                        }
                       


                    }catch{

                    }
                }

            })
            getRequest(URLString: mainDomen + "/api/tasks/investment/\(formatter1.string(from: Date()))", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.investorTaskArray = try! JSONDecoder().decode([InvestorModel].self, from: jsonData)
                    }catch{

                    }
                }
            })
            var dayComponent    = DateComponents()
            dayComponent.day    = 1
            let theCalendar     = Calendar.current
            let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
            getRequest(URLString: mainDomen + "/api/tasks/loan/\(formatter1.string(from: nextDate!))", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.tomorrowTaskArray = try! JSONDecoder().decode([TaskModel].self, from: jsonData)
                        
                    }catch{

                    }
                }
                
            })
            
            getRequest(URLString: mainDomen + "/api/pledges/all/true", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.pledgeArray = try! JSONDecoder().decode([PledgeModel].self, from: jsonData)
                     //   print(self.pledgeArray)
                    }catch{

                    }
                }
            })
                //запрос инвесторов
                getRequest(URLString: mainDomen + "/api/investors/all/false", completion: {
                    result in
                    DispatchQueue.main.async {
                        do {
                            //сериализация справочника в Data, чтобы декодировать ее в структуру
                           let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                           self.investorsArray = try! JSONDecoder().decode([Investor].self, from: jsonData)
                            for investor in self.investorsArray{
                                if(investor.isOwnFunds!){
                                    self.investorID = investor.id!
                                }
                            }
                           self.investorsArray = self.investorsArray.filter({$0.isOwnFunds == false})
                           
                           self.table.reloadData()
                            
                          
                        }catch{

                        }
                    }

                })
        })
    }
    
    func getCountDays(date:String) -> DateComponents{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if(dateFormatter.date(from:date) == nil){
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        }
        
        let date = dateFormatter.date(from:date)!
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components
    }
    
    @objc func chooseRow(notification:Notification){
        
        DispatchQueue.main.async {
            self.reloadDataTable()
            self.chosenRow = ChosenRow(rawValue: notification.userInfo!["row"] as! Int)
            switch self.chosenRow {
            case .tasks:
                self.setupView(title: "Заемщики", topImageName: "borrowerIcon", array: self.currentDay == .today ? self.taskArray:self.tomorrowTaskArray, emptyImageName: "clients", emptyTitle: "Список заемщиков пуст", needHiddeBlur: false, buttonImage: "clientsIcon")
            case .investor:
                self.setupView(title: "Инвесторы", topImageName: "investorIcon", array: self.investorsArray, emptyImageName: "investor", emptyTitle: "Список инвесторов пуст", needHiddeBlur: true, buttonImage: "plus_add")
            case .pledge:
                self.setupView(title: "Имущество", topImageName: "propertyIcon", array: self.pledgeArray, emptyImageName: "property", emptyTitle: "Список имущества пуст", needHiddeBlur: true, buttonImage: "plus_add")
            case .none:
                break
            }
            self.table.reloadData()
        }
        
        
    }
    
    func setupView(title:String,topImageName:String,array:Array<Any>,emptyImageName:String,emptyTitle:String,needHiddeBlur:Bool,buttonImage:String){
        DispatchQueue.main.async {
            self.topTitle.text = title
            self.topImage.image = UIImage(named: topImageName)
            self.emptyImg.isHidden = array.count > 0
            self.emptyImg.image = UIImage(named: emptyImageName)
            self.emptyLbl.isHidden = array.count > 0
            self.emptyLbl.text = emptyTitle
            
            self.table.isHidden = array.count < 1
          //  self.blurView.isHidden = needHiddeBlur
            self.plusBtn.setImage(UIImage(named: buttonImage), for: .normal)
            self.plusBtn.isHidden = title != "Заемщики"
            self.plusInvest.isHidden = title != "Инвесторы"
            if(title == "Инвесторы"){
                self.plusInvest.isHidden = !mainUser.isAdmin
            }
        }
        
    }
    
    @objc func openProfile(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileController
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }

   
    
    func getDate(date:String)->String{
        if(date != ""){
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            if dateFormatterGet.date(from: date) == nil {
                dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            }
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MMM YYYY"
           // dateFormatterPrint.dateStyle = DateFormatter.Style.short
            dateFormatterPrint.locale = NSLocale(localeIdentifier: "ru") as Locale

            return dateFormatterPrint.string(from: dateFormatterGet.date(from: date)!)
            
        }else{
            return date
        }
    }
    
    @IBAction func showMenu(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuVC") as! ViewController
        let tempTask = taskArray.filter({!$0.isPaid})
        let tempInvestor = self.investorTaskArray.filter({!$0.isPaid})
        let summ = tempTask.map({$0.paymentAmount}).reduce(0, +)
        let summInvestor = tempInvestor.map({$0.paymentAmount}).reduce(0, +)
        let summPledges = pledgeArray.map({$0.pledgeAmount}).reduce(0, +)
        viewController.todayBorrower.todaySumm = summ != 0 ? "\(summ.formattedWithSeparator) руб":"-"
        viewController.todayBorrower.todayCount = tempTask.count != 0 ? "\(tempTask.count)":"-"
        viewController.todayInvestor.todaySumm = summInvestor != 0 ? "\(summInvestor.formattedWithSeparator) руб":"-"
        viewController.todayInvestor.todayCount = tempInvestor.count != 0 ? "\(tempInvestor.count)":"-"
        viewController.pledges.summ = summPledges != 0 ? "\(summPledges.formattedWithSeparator) руб":"-"
        viewController.pledges.count = pledgeArray.count != 0 ? "\(pledgeArray.count)":"-"
        
        
        let menu = SideMenuNavigationController(rootViewController: viewController)
        menu.leftSide = true
        menu.isNavigationBarHidden = true
        menu.menuWidth = self.view.frame.size.width * 0.9
        self.present(menu, animated: true, completion: nil)
    }
    
    @IBAction func addNew(_ sender: Any) {
        switch self.chosenRow {
        case .investor:
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "addInvestorVC") as! AddInvestorController
            self.navigationController?.pushViewController(viewController, animated: true)
        case .tasks:
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailController
            viewController.investorID = investorID
            self.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
    
    func configStatus(status:Int) -> (UIColor,String){
        switch status {
        case 0:
            return (UIColor.init(displayP3Red: 222/255, green: 222/255, blue: 222/255, alpha: 0.5),"Звонка не было")
        case 1:
            return (UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 0.5),"Оплачено")
        case 2:
            return (UIColor.init(displayP3Red: 52/255, green: 163/255, blue: 231/255, alpha: 0.5),"Оплата сегодня")
        case 3:
            return (UIColor.init(displayP3Red: 57/255, green: 68/255, blue: 255/255, alpha: 0.5),"Оплата завтра")
        case 4:
            return (UIColor.init(displayP3Red: 237/255, green: 170/255, blue: 59/255, alpha: 0.5),"Перенос платежа")
        case 5:
            return (UIColor.init(displayP3Red: 246/255, green: 90/255, blue: 59/255, alpha: 0.5),"Не дозвонились")
        default:
            return (.white,"Звонка не было")
        }
    }
    
    @IBAction func chooseSegment(_ sender: UISegmentedControl) {
        currentDay = TaskDay(rawValue: sender.selectedSegmentIndex)
        self.setupView(title: "Заемщики", topImageName: "borrowerIcon", array: self.currentDay == .today ? self.taskArray:self.tomorrowTaskArray, emptyImageName: "clients", emptyTitle: "Список заемщиков пуст", needHiddeBlur: false, buttonImage: "clientsIcon")
        table.reloadData()
    }
    
    @objc func callBorrower(button:UIButton){
        DispatchQueue.main.async{
            let number = self.currentDay == .today ? self.taskArray[button.tag].borrowerPhones[0]:self.tomorrowTaskArray[button.tag].borrowerPhones[0]
            if let url = URL(string: "tel://+\(number)") {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func setStatusForBorrower(button:UIButton){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "StatusNav") as! StatusNavigationController
        let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                              presenting: self,
                                                                              isDismissable: true)
        
        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        let rootViewController = viewController.viewControllers.first as! StatusController
        rootViewController.embededViewCntroller = self
        rootViewController.indexBorrower = button.tag
        rootViewController.isToday = currentDay == .today
        self.present(viewController, animated: true)
    }
    
    func updateBorrower(index:Int){
        let task = currentDay == .today ? taskArray[index]:tomorrowTaskArray[index]
        let object = ["id": task.paymentScheduleId,
                      "paymentDate": task.paymentDate,
                      "paymentMethod": task.paymentMethod,
                      "status": task.status,
                      "comment": task.comment ?? ""] as [String:Any]
        patchRequest(JSON: object, URLString: mainDomen + "/api/tasks/loan/update", completion: {
            result in
            DispatchQueue.main.async {
                self.reloadDataTable()
            }
            
        })
    }
    
    func paymentMethod(index:Int){
      //  /api/payments/loan/add
        let task = currentDay == .today ? taskArray[index]:tomorrowTaskArray[index]
        let object = [ "paymentType": task.paymentType,
                       "paymentDate": task.paymentDate,
                       "paymentAmount": task.paymentAmount,
        "loanId": task.loanId] as [String:Any]
        postRequest(JSON: object, URLString: mainDomen + "/api/payments/loan/add", completion: {
            result in
            DispatchQueue.main.async {
                self.reloadDataTable()
            }
        })
    }
    
    @objc func choosePaymentMethod(button:UIButton){
       
            let alert = UIAlertController(title: "", message: "Пожалуйста, укажите тип оплаты", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Наличные", style: .default , handler:{ (UIAlertAction)in
                if(self.currentDay == .today){
                    self.taskArray[button.tag].paymentMethod = 1
                }else{
                    self.tomorrowTaskArray[button.tag].paymentMethod = 1
                }
                self.updateBorrower(index: button.tag)
            }))
            
            alert.addAction(UIAlertAction(title: "На карту", style: .default , handler:{ (UIAlertAction)in
                if(self.currentDay == .today){
                    self.taskArray[button.tag].paymentMethod = 2
                }else{
                    self.tomorrowTaskArray[button.tag].paymentMethod = 2
                }
                self.updateBorrower(index: button.tag)
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))

    
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        
    }
    
    @objc func sendComment(){
        let task = currentDay == .today ? taskArray[currentTextField.tag]:tomorrowTaskArray[currentTextField.tag]
        let object = ["id": task.paymentScheduleId,
                      "paymentDate": task.paymentDate,
                      "paymentMethod": task.paymentMethod,
                      "status": task.status,
                      "comment": task.comment ?? ""] as [String:Any]
        patchRequest(JSON: object, URLString: mainDomen + "/api/tasks/loan/update", completion: {
            result in
            DispatchQueue.main.async {
                self.reloadDataTable()
            }
            
        })
        
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Отмена", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let doneButton = UIBarButtonItem(title: "Отправить", style: UIBarButtonItem.Style.done, target: self, action: #selector(sendComment))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }

    @objc func keyboardWillShow(notification: NSNotification)
       {
           let info = notification.userInfo! as! [String: AnyObject],
               kbSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
           contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 370 , right: 0)
      
           self.table.contentInset = contentInsets
           self.table.scrollIndicatorInsets = contentInsets

           var aRect = self.table.frame
           aRect.size.height -= kbSize.height
       }
    
    @objc func keyboardWillHide(notification: NSNotification)
       {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
           self.table.contentInset = contentInsets
           self.table.scrollIndicatorInsets = contentInsets
       }
}


extension MainController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch chosenRow {
        case .tasks:
            return 207
        case .investor:
            return 100
        case .pledge:
            return 70
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch chosenRow {
        case .tasks:
            if(currentDay == .today){
                return taskArray.count
            }else{
                return tomorrowTaskArray.count
            }
        case .investor:
            return investorsArray.count
        case .pledge:
            return pledgeArray.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch chosenRow {
        case .tasks:
            let cellReuseIdentifier = "TaskCell"
            let cell:TaskCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TaskCell
                table.separatorStyle = .none
            let task = currentDay == .today ? taskArray[indexPath.row]:tomorrowTaskArray[indexPath.row]
                cell.nameLbl.text = task.borrowerTitle
            if(task.pledges.count>0){
                cell.pledgeLbl.text = task.pledges[0]
            }else{
                cell.pledgeLbl.text = "Нет данных"
            }
            
            let typePay = task.paymentMethod == 1 ? "наличныйми":"на карту"
               
            let (colorStatus, titleStatus) = self.configStatus(status: task.isPaid ? 1 : task.status)
                cell.statusView.backgroundColor = colorStatus
                cell.callBtn.tag = indexPath.row
                cell.callBtn.addTarget(self, action: #selector(callBorrower), for: .touchUpInside)
                cell.statusLbl.text = titleStatus
                cell.leftStatusView.backgroundColor = colorStatus.withAlphaComponent(1)
                cell.paymentBtn.setTitle("\(task.paymentAmount.formattedWithSeparator) "+"\(typePay) ", for: .normal)
           
                if(!task.isPaid){
                    cell.statusBtn.tag = indexPath.row
                    cell.statusBtn.addTarget(self, action: #selector(setStatusForBorrower), for: .touchUpInside)
                    cell.paymentBtn.setImage(UIImage(named: "arrowBottom"), for: .normal)
                    cell.paymentBtn.semanticContentAttribute = .forceRightToLeft
                    cell.paymentBtn.addTarget(self, action: #selector(choosePaymentMethod(button:)), for: .touchUpInside)
                    cell.paymentBtn.tag = indexPath.row
                }else{
                    cell.paymentBtn.setImage(nil, for: .normal)
                }
                
                cell.clockIcon.isHidden = task.status == 4 && !task.isPaid ? false:true
                cell.commentTextField.delegate = self
                cell.commentTextField.tag = indexPath.row
                cell.commentTextField.text = task.comment ?? ""
                self.addToolBarTextfield(textField: cell.commentTextField)
            return cell
        case .investor:
            let cellReuseIdentifier = "detailCell"
            let cell:DetailCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailCell
                table.separatorStyle = .singleLine
            let investor = self.investorsArray[indexPath.row]
                cell.nameLbl.text = investor.title
                cell.colorDot.backgroundColor = UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1)
                cell.dateLbl.text = self.getDate(date: investor.nextPaymentDate ?? "")
                cell.summLbl.text = "\(investor.debtBalance?.formattedWithSeparator ?? "0") руб."
                cell.costLbl.text = "\(investor.nextPaymenAmount?.formattedWithSeparator ?? "0") руб."
            
               
               
            return cell
        case .pledge:
            let cellReuseIdentifier = "pledgeCell"
            let cell:MainCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainCell
            let pledge = pledgeArray[indexPath.row]
           
                table.separatorStyle = .singleLine
            if(pledge.pledgeFiles!.count > 0){
                cell.pledgeImage.loadImageUsingCache(withUrl:mainDomen + "/api/pledges/files/" + pledge.pledgeFiles![0])
                cell.pledgeImage.layer.cornerRadius = 8
            }else{
                cell.pledgeImage.image = UIImage(named: "emptyPledge")
            }
                cell.pledgeTitle.text = pledge.pledgeTitle
                cell.pledgeCost.text = "\(pledge.pledgeAmount.formattedWithSeparator) руб"
            
            return cell
        default:
            let cellReuseIdentifier = "pledgeCell"
            let cell:MainCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainCell
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(chosenRow == .pledge && self.pledgeArray[indexPath.row].pledgeFiles?.count ?? 0 > 0){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "pledgeVC") as! PledgeViewController
            viewController.currentPledge = self.pledgeArray[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)

        }else if(chosenRow == .investor){
            if((self.investorsArray[indexPath.row].investments ?? []).count > 0){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InvestorVC") as! InvestorController
//            print(self.investorsArray[indexPath.row].investments)
            viewController.investor = self.investorsArray[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
            }else{
                setMessage(text: "У инвестора еще нет инвестиций", controller: self)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if(chosenRow == .investor){
            let deleteAction = UIContextualAction(style: .normal, title: "Удалить") { (action, view, completion) in
                deleteRequest(URLString: mainDomen+"/api/investors/delete/\(self.investorsArray[indexPath.row].id!)", completion: {
                       result in
                       if((result["errors"] as? [String:Any])?["errors"] != nil){
                           setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String , controller: self)
                       }else{
                           DispatchQueue.main.async {
                               self.investorsArray.remove(at: indexPath.row)
                               self.table.reloadData()
                           }
                       }
       
                   })
       
              }

              let muteAction = UIContextualAction(style: .normal, title: "Изменить") { (action, view, completion) in
                DispatchQueue.main.async {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "addInvestorVC") as! AddInvestorController
                    viewController.regInvestor.title = self.investorsArray[indexPath.row].title ?? ""
                    viewController.regInvestor.investorPhones = self.investorsArray[indexPath.row].investorPhones ?? []
                    viewController.regInvestor.id = self.investorsArray[indexPath.row].id
                    viewController.isUpdate = true
                    self.navigationController?.pushViewController(viewController, animated: true)
                  }
                }
                

              deleteAction.backgroundColor = UIColor.red
              return UISwipeActionsConfiguration(actions: [deleteAction, muteAction])
        }else{
            return nil
        }
        
        }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(chosenRow == .investor){
            return true
        }else{
            return false
        }
    }

   
    
    
}

extension MainController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendComment()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
        if(currentDay == .today){
            taskArray[textField.tag].comment = currentText.replacingCharacters(in: stringRange, with: string)
        }else{
            tomorrowTaskArray[textField.tag].comment = currentText.replacingCharacters(in: stringRange, with: string)
        }
         return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
   
}

extension UISegmentedControl {

    func setTitleColor(_ color: UIColor, state: UIControl.State = .selected) {
        var attributes = self.titleTextAttributes(for: state) ?? [:]
        attributes[.foregroundColor] = color
        self.setTitleTextAttributes(attributes, for: state)
    }
    
    func setTitleFont(_ font: UIFont, state: UIControl.State = .normal) {
        var attributes = self.titleTextAttributes(for: state) ?? [:]
        attributes[.font] = font
        self.setTitleTextAttributes(attributes, for: state)
    }

}

let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        if url == nil {return}
        self.image = nil

        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return
        }

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .medium)
        activityIndicator.color = .white
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = self.center
        var request = URLRequest(url: NSURL(string: urlString)! as URL)
            request.httpMethod = "GET"
        request.addValue("Bearer \(mainUser.token)", forHTTPHeaderField: "Authorization")
          
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            if error != nil {
                 print(error!)
                 return
             }

             DispatchQueue.main.async {
                 if let image = UIImage(data: data!) {
                     imageCache.setObject(image, forKey: urlString as NSString)
                     self.image = image
                     activityIndicator.removeFromSuperview()
                 }
             }
        })
        task.resume()
    }
}

