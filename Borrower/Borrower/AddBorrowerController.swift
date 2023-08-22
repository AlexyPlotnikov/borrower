//
//  AddBorrowerController.swift
//  Borrower
//
//  Created by RX Group on 19.01.2021.
//

import UIKit




class AddBorrowerController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    struct BorrowerModel:Codable {
        var title:String = ""
        var borrowerPhones:[String] = [""]
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
    }
    struct BorrowerModelUpdate:Codable {
        var title:String = ""
        var borrowerPhones:[String] = [""]
        var id:String = ""
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
    }
    
    struct PledgeType:Codable{
        var id:String? = ""
        var title:String? = ""
    }
    
    struct PhotoDocument{
        var firstPagePhoto: UIImage?
        var secondPagePhoto:UIImage?
        var photoPledge:UIImage?
    }
    
    struct Loan:Codable{
        var id:String? = ""
        var borrowerId:String = ""
        var loanDate:String = ""
        var loanAmount:Int = 0
        var loanPercent:Double = 0.0
        var accrualPeriod:Int = 2
        var paymentScheduleType:Int = 1
        var monthlyPaymentAmount:Int = 0
        var earlyPaymentAmount:Int = 0
        var paymentDay:Int = 1
        var paymentMethod:Int = 1
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
      }
    

    struct Pledge:Codable {
        var id:String = ""
        var loanId:String = ""
        var pledgeTypeId:String = ""
        var description:String = ""
        var pledgeAmount:Int = 0
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
    }
    
    struct Investment:Codable{
        var id:String? = ""
        var loanId:String = ""
        var investorId:String = ""
        var investmentAmount:Int = 0
        var investmentDate:String = ""
        var investmentPercent:Double = 0.0
        var accrualPeriod:Int = 2
        var monthlyPaymentAmount:Int = 0
        var paymentDay:Int = 0
        var paymentMethod:Int = 1
        var paymentScheduleType:Int = 1
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
    }
    
    var sectionCount = 1
    var countOfBorrow = 0
    @IBOutlet weak var collectionView: UICollectionView!
    var titlesArray:[String] = ["Документы", "Заём", "Залог", "Источник займа"]
    var borrower = BorrowerModel()
    var borrowerUpdate = BorrowerModelUpdate()
    var pledgeArray: [PledgeType] = []
    var imagePicker = UIImagePickerController()
    var documents = PhotoDocument()
    var photoTag = 0
    var currentLoan = Loan()
    var currentPledge = Pledge()
    var ownInvestment = Investment()
    var investorInvestment = Investment()
    var investorID:String = ""
    var currentTextField:UITextField!
    var shownDate:String = ""
    var shownInvestorDate:String = ""
    var periodArray:[String] = ["Месяц"]
    var dayArray:[Int] = []
    var investorsArray:[Investor] = []
    @IBOutlet weak var doneBtn: UIButton!
    var investorName:String = "Не указано"
    var isUpdate = false
    var newLoan = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
      //  print()
       
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        for i in 1...31{
            dayArray.append(i)
        }
      
       
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        refreshToken(controller: self, completion: {
            getRequest(URLString: mainDomen + "/api/pledges/pledgetypes", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.pledgeArray = try! JSONDecoder().decode([PledgeType].self, from: jsonData)
                        
                    }catch{

                    }
                }
            })
            getRequest(URLString: mainDomen + "/api/investors/all/false", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.investorsArray = try! JSONDecoder().decode([Investor].self, from: jsonData)
                       self.ownInvestment.investorId = self.investorsArray.first(where: {$0.isOwnFunds == true})!.id!
                       self.investorsArray = self.investorsArray.filter({$0.isOwnFunds == false})
                       self.collectionView.reloadData()
                    }catch{

                    }
                }

            })
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
    }

   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkErrors()->Bool{
         if(self.currentLoan.loanAmount == 0){
            doneBtn.isUserInteractionEnabled = true
            setMessage(text: "Необходимо указать сумму займа", controller: self)
            return false
        }else if(self.currentLoan.loanPercent == 0.0){
            doneBtn.isUserInteractionEnabled = true
            setMessage(text: "Необходимо указать процент займа", controller: self)
            return false
        }else if(self.currentLoan.loanDate == ""){
            doneBtn.isUserInteractionEnabled = true
            setMessage(text: "Не указана дата займа", controller: self)
            return false
        }else if(self.currentLoan.monthlyPaymentAmount == 0){
            doneBtn.isUserInteractionEnabled = true
            setMessage(text: "Необходимо указать сумму ежемесячного платежа", controller: self)
            return false
        }
        return true
    }
   
    @IBAction func done(_ sender: Any) {
        doneBtn.isUserInteractionEnabled = false
        refreshToken(controller: self, completion: {
            if(self.borrower.title == ""){
                self.doneBtn.isUserInteractionEnabled = true
                setMessage(text: "Необходимо ввести ФИО заемщика", controller: self)
            }else if(self.borrower.borrowerPhones[0] == ""){
                self.doneBtn.isUserInteractionEnabled = true
                setMessage(text: "Необходимо ввести номер телефона заемщика", controller: self)
            }else if(self.countOfBorrow == 1 || self.countOfBorrow == 2){
                if(self.checkErrors()){
                    if(self.isUpdate){
                        self.updateRequest(onlyBorrower: false)
                    }else{
                        self.sendRequest(onlyBorrower: false)
                    }
                }
            }else{
                if(self.isUpdate){
                    self.updateRequest(onlyBorrower: true)
                }else{
                    self.sendRequest(onlyBorrower: true)
                }
            }
        })
       
    }
    
    func sendRequest(onlyBorrower:Bool){
        if(!newLoan){
            postRequest(JSON: self.borrower.asDictionary, URLString: mainDomen + "/api/borrowers/add", completion: {
                result in
                if(result["errors"] == nil){
                    if(result["id"] != nil){
                        DispatchQueue.main.async {
                            print(result)
                            let id = result["id"] as! String
                            //загрузка паспорт 1
                            if(!onlyBorrower){
                                    //загрузка паспорт 2
                                self.sendLoanToServer(id: id)
                 
                            }else{
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                            
                        }
                    }
                }else{
                    if((result["errors"] as! [String:Any])["Title"] != nil){
                        setMessage(text: ((result["errors"] as! [String:Any])["Title"] as! Array<Any>)[0] as! String, controller: self)
                        DispatchQueue.main.async {
                            self.doneBtn.isUserInteractionEnabled = true
                        }
                    }else if((result["errors"] as! [String:Any])["BorrowerPhones"] != nil){
                        setMessage(text: ((result["errors"] as! [String:Any])["BorrowerPhones"] as! Array<Any>)[0] as! String, controller: self)
                        DispatchQueue.main.async {
                            self.doneBtn.isUserInteractionEnabled = true
                        }
                    }else if((result["errors"] as! [String:Any])["errors"] != nil){
                        setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String, controller: self)
                        DispatchQueue.main.async {
                            self.doneBtn.isUserInteractionEnabled = true
                        }
                    }
                }
            })
        }else{
            self.sendLoanToServer(id: "")
        }
    }
    
    func sendLoanToServer(id:String){
        self.currentLoan.borrowerId = newLoan ? borrowerUpdate.id : id
        postRequest(JSON: self.currentLoan.asDictionary, URLString: mainDomen + "/api/loans/add", completion: {
            result in
            if(result["errors"] == nil){
                if(result["id"] != nil){
                    print(result)
                    let idLoan = result["id"] as! String
                    self.currentPledge.loanId = idLoan
                    if(self.currentPledge.description != ""){
                        postRequest(JSON: self.currentPledge.asDictionary, URLString: mainDomen + "/api/pledges/add", completion: {
                            result in
                            print(result)
                            let idPledge = result["id"] as! String
                            if(self.documents.photoPledge != nil){
                                self.uploadImages(url:"/api/pledges/files/add",id: idPledge, image: self.documents.photoPledge!, code: "300", completion: {
                                    
                                })
                            }
                        })
                    }
                            self.ownInvestment.loanId = idLoan
                    
                            postRequest(JSON: self.ownInvestment.asDictionary, URLString: mainDomen + "/api/investments/add", completion: {
                                result in
                                print(result)
                                if(self.documents.secondPagePhoto != nil){
                                    self.uploadImages(url: "/api/borrowers/files/add", id: self.newLoan ? self.borrowerUpdate.id : id, image: self.documents.secondPagePhoto!, code: "102", completion: {
                                        
                                    })
                                }
                                if(self.documents.firstPagePhoto != nil){
                                    self.uploadImages(url: "/api/borrowers/files/add", id: self.newLoan ? self.borrowerUpdate.id : id, image: self.documents.firstPagePhoto!, code: "101", completion: {
                                        
                                    })
                                }
                                if(self.countOfBorrow==2){
                                    self.investorInvestment.loanId = idLoan
                                    postRequest(JSON: self.investorInvestment.asDictionary, URLString: mainDomen + "/api/investments/add", completion: {
                                        result in
                                        print(result)
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
                                            self.navigationController?.popViewController(animated: true)
                                            }
                                        })
                                    
                                }else{
                                    DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
                                    self.navigationController?.popViewController(animated: true)
                                    }
                                }
                                
                            })

                        
                    
                }
            }

        })

   
    }
    
    func updateRequest(onlyBorrower:Bool){

        self.borrowerUpdate.borrowerPhones = self.borrower.borrowerPhones
        self.borrowerUpdate.title = self.borrower.title
        putRequest(JSON: self.borrowerUpdate.asDictionary, URLString: mainDomen + "/api/borrowers/update", completion: {
            result in
            print(result)
            if(result["errors"] == nil){
                    DispatchQueue.main.async {
                        if(!onlyBorrower){
                          
                                putRequest(JSON: self.currentLoan.asDictionary, URLString: mainDomen + "/api/loans/update", completion: {
                                        result in
                                    print(result)
                                        if(result["errors"] == nil){
                                                if(self.currentPledge.description != ""){
                                                    let pledge = self.pledgeArray.first(where: {$0.title == self.currentPledge.description})!
                                                    self.currentPledge.pledgeTypeId = pledge.id!
                                                    putRequest(JSON: self.currentPledge.asDictionary, URLString: mainDomen + "/api/pledges/update", completion: {
                                                        result in
                                                        print(result)
                                                        if(self.documents.photoPledge != nil){
                                                            self.uploadImages(url:"/api/pledges/files/add",id: self.currentPledge.loanId, image: self.documents.photoPledge!, code: "300", completion: {
                                                                
                                                            })
                                                        }
                                                    })
                                                }
                                           
                                            print("1111",self.ownInvestment)
                                            print("2222",self.investorInvestment)
                                                            putRequest(JSON: self.ownInvestment.asDictionary, URLString: mainDomen + "/api/investments/update", completion: {
                                                            result in
                                                                print(result)
                                                                if((result["errors"] as? [String:Any])?["errors"] != nil){
                                                                    print((result["errors"] as! [String:Any])["errors"])
                                                                    
                                                                }
                                                            if(self.documents.secondPagePhoto != nil){
                                                                self.uploadImages(url: "/api/borrowers/files/add", id: self.currentLoan.borrowerId, image: self.documents.secondPagePhoto!, code: "102", completion: {

                                                                })
                                                            }
                                                            if(self.documents.firstPagePhoto != nil){
                                                                self.uploadImages(url: "/api/borrowers/files/add", id: self.currentLoan.borrowerId, image: self.documents.firstPagePhoto!, code: "101", completion: {

                                                                })
                                                            }
                                                            if(self.countOfBorrow==2){
                                                                if(self.investorInvestment.loanId == ""){
                                                                    
                                                                    self.investorInvestment.loanId = self.ownInvestment.loanId
                                                                    postRequest(JSON: self.investorInvestment.asDictionary, URLString: mainDomen + "/api/investments/add", completion: {
                                                                        result in
                                                                        print(result)
                                                                        if((result["errors"] as? [String:Any])?["errors"] != nil){
                                                                            print((result["errors"] as! [String:Any])["errors"])
                                                                            
                                                                        }
                                                                        DispatchQueue.main.async {
                                                                            NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
                                                                            self.navigationController?.popViewController(animated: true)
                                                                            }
                                                                        })
                                                                }else{
                                                                    self.investorInvestment.loanId = self.ownInvestment.loanId
                                                                    putRequest(JSON: self.investorInvestment.asDictionary, URLString: mainDomen + "/api/investments/update", completion: {
                                                                        result in
                                                                        print(result)
                                                                        if((result["errors"] as? [String:Any])?["errors"] != nil){
                                                                            print((result["errors"] as! [String:Any])["errors"])
                                                                            
                                                                        }
                                                                        DispatchQueue.main.async {
                                                                            NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
                                                                            self.navigationController?.popViewController(animated: true)
                                                                            }
                                                                        })
                                                                }
                                                            }else{
                                                                DispatchQueue.main.async {
                                                                NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
                                                                self.navigationController?.popViewController(animated: true)
                                                                }
                                                            }

                                                        })

                                                    
                                                
                                            
                                        }

                                    })

                               
                        }else{
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .updateBorrowers, object: nil, userInfo: nil)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    }
                    
                    
            }else{
                if((result["errors"] as! [String:Any])["Title"] != nil){
                    setMessage(text: ((result["errors"] as! [String:Any])["Title"] as! Array<Any>)[0] as! String, controller: self)
                    DispatchQueue.main.async {
                        self.doneBtn.isUserInteractionEnabled = true
                    }
                }else if((result["errors"] as! [String:Any])["BorrowerPhones"] != nil){
                    setMessage(text: ((result["errors"] as! [String:Any])["BorrowerPhones"] as! Array<Any>)[0] as! String, controller: self)
                    DispatchQueue.main.async {
                        self.doneBtn.isUserInteractionEnabled = true
                    }
                }else if((result["errors"] as! [String:Any])["errors"] != nil){
                    setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String, controller: self)
                    DispatchQueue.main.async {
                        self.doneBtn.isUserInteractionEnabled = true
                    }
                }
            }
        })
                        
           
    }
    
    
    func uploadImages(url:String, id:String, image:UIImage, code:String,completion:@escaping ()->Void){
        
        let object = ["EntityId":id,
        "FileCategory":code] as [String:String]
      
        uploadImage(URLString: mainDomen + url, image: image, param: object, completion: {
            result in
            completion()
        })
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
        self.collectionView.reloadData()
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    //MARK:работа с фото
    @objc func changePhoto(button:UIButton){
        photoTag = button.tag
        var image:UIImage?
        if(photoTag==0){
            image = documents.firstPagePhoto
        }else if(photoTag == 1){
            image = documents.secondPagePhoto
        }else if(photoTag == 2){
            image = documents.photoPledge
        }
        
        if(image == nil){
            self.openPhotoChange()
        }else{
            let appImage = ViewerImage.appImage(forImage: image!)
            let viewer = AppImageViewer(photos: [appImage])
            self.navigationController?.present(viewer, animated: true, completion: nil)
        }
        
       
    }
    
    func openPhotoChange(){
        let alertController = UIAlertController()
               let action = UIAlertAction(title: "Камера", style: .default) { (action: UIAlertAction!) in
                   let vc = UIImagePickerController()
                   vc.sourceType = .camera
                   vc.allowsEditing = false
                   vc.delegate = self
                   self.navigationController!.present(vc, animated: true)
               }
               
               
               let galery = UIAlertAction(title: "Галерея", style: .default) { (action: UIAlertAction!) in
                   if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                       self.imagePicker.delegate = self
                       self.imagePicker.sourceType = .savedPhotosAlbum
                       self.imagePicker.allowsEditing = false
                       
                    self.navigationController!.present(self.imagePicker, animated: true, completion: nil)
                   }
               }
               let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
               
               alertController.addAction(action)
               alertController.addAction(galery)
               alertController.addAction(cancel)
               if let popoverController = alertController.popoverPresentationController {
                   popoverController.sourceView = self.view
                   popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                   popoverController.permittedArrowDirections = []
               }
               self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
            dismiss(animated: true, completion: nil)
            let pickedImage=info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if(photoTag == 0){
            documents.firstPagePhoto = pickedImage
        }else if(photoTag == 1){
            documents.secondPagePhoto = pickedImage
        }else if(photoTag == 2){
            documents.photoPledge = pickedImage
        }
            collectionView.reloadData()
    }
    //MARK:выбор даты
    @objc func tapDone() {
        if let datePicker = currentTextField.inputView as? UIDatePicker {
            if(currentTextField.tag == 4){
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd"
                currentLoan.loanDate = dateformatter.string(from: datePicker.date)
                ownInvestment.investmentDate = dateformatter.string(from: datePicker.date)
                currentLoan.paymentDay = Calendar.current.dateComponents([.day], from: datePicker.date).day!
                ownInvestment.paymentDay = Calendar.current.dateComponents([.day], from: datePicker.date).day!
                let dateformatter2 = DateFormatter()
                dateformatter2.dateStyle = .medium
                dateformatter2.locale = NSLocale.init(localeIdentifier: "ru") as Locale
                shownDate = dateformatter2.string(from: datePicker.date)
            }else if(currentTextField.tag == 12){
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd"
                investorInvestment.investmentDate = dateformatter.string(from: datePicker.date)
                investorInvestment.paymentDay = Calendar.current.dateComponents([.day], from: datePicker.date).day!
                let dateformatter2 = DateFormatter()
                dateformatter2.dateStyle = .medium
                dateformatter2.locale = NSLocale.init(localeIdentifier: "ru") as Locale
                shownInvestorDate = dateformatter2.string(from: datePicker.date)
            }
            collectionView.reloadData()
            
        }
        currentTextField.tapCancel()
        }
    //MARK:создание пикера
    func createPickerView(){
            let pickerView = UIPickerView()
            pickerView.delegate = self
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
      
            toolBar.setItems([spaceButton,doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            currentTextField.inputAccessoryView = toolBar
            currentTextField.inputView = pickerView
       
    }
    
    //MARK:делегат клавиатуры
    @objc func keyboardWillShow(notification: NSNotification)
       {
           let info = notification.userInfo! as! [String: AnyObject],
               kbSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
           contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + 110, right: 0)

           self.collectionView.contentInset = contentInsets
           self.collectionView.scrollIndicatorInsets = contentInsets

           var aRect = self.collectionView.frame
           aRect.size.height -= kbSize.height
       }
    
    @objc func keyboardWillHide(notification: NSNotification)
       {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
           self.collectionView.contentInset = contentInsets
           self.collectionView.scrollIndicatorInsets = contentInsets
       }
    @objc func chooseInvestor(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseInvestorVC") as! ChooseInwestorNavigationController
        let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                              presenting: self,
                                                                              isDismissable: true)
        
        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        let rootViewController = viewController.viewControllers.first as! ChooseInvestorController
        rootViewController.investorsArray = self.investorsArray
        rootViewController.embededController = self
        self.present(viewController, animated: true)
    }
    
    @IBAction func openContactList(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseContactVC") as! ChooseContactListController
        let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                              presenting: self,
                                                                              isDismissable: true)
        
        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        let rootViewController = viewController.viewControllers.first as! ContactController
        rootViewController.embededController = self
        self.present(viewController, animated: true)
        
    }
    
    
}

//MARK: Делегат для Коллекции
extension AddBorrowerController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }
    //MARK: Количество ячеек в колекции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(section == 0){
            //основная инфа
            if(countOfBorrow>0){
                return 2
            }else{
                return 3
            }
            
        }else if(section == 1){
            //фото документов
            return 2
        }else if(section == 2){
            //данные о займе
            return 6
        }else if(section == 3){
            // залог
            if(countOfBorrow==2){
                return 3
            }else{
                if(self.investorsArray.count > 0){
                    return 4
                }else{
                    return 3
                }
               
            }
        }else if(section == 4){
            return 7
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        if(indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 2){
        if(indexPath.section == 0){
            //MARK: 1 блок
            if(indexPath.row == 0){
                //Поле ФИО для заемщика
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                cell.titleBorrower.text = "ФИО"
                cell.widthImage.constant = 0
                cell.textFieldBorrower.delegate = self
                cell.textFieldBorrower.tag = 0
                cell.textFieldBorrower.text = borrower.title
                cell.textFieldBorrower.keyboardType = .default
                if(!isUpdate && !newLoan){
                    cell.textFieldBorrower.becomeFirstResponder()
                }
                if(newLoan||isUpdate){
                    cell.textFieldBorrower.isUserInteractionEnabled = false
                }else{
                    cell.textFieldBorrower.isUserInteractionEnabled = true
                }
               
                self.addToolBarTextfield(textField: cell.textFieldBorrower)
                return cell
            }else if(indexPath.row == 1){
                //Поле телефон заемщика
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "phoneFieldCell", for: indexPath) as! BorrowerCell
                
                cell.titleBorrower.text = "Номер телефона"
                cell.phoneFieldBorrower.delegate = self
                cell.phoneFieldBorrower.tag = 1
                cell.phoneFieldBorrower.addPadding(padding: .left(48))
                cell.phoneFieldBorrower.keyboardType = .numberPad
                cell.phoneBookBtn.isHidden = newLoan || isUpdate
                if(newLoan||isUpdate){
                    cell.phoneFieldBorrower.isUserInteractionEnabled = false
                }else{
                    cell.phoneFieldBorrower.isUserInteractionEnabled = true
                }
                let mask = JMStringMask(mask: "+0 (000) 000 00 00")
                let maskedString = mask.mask(string: borrower.borrowerPhones[0])
                cell.phoneFieldBorrower.text = maskedString
                self.addToolBarTextfield(textField: cell.phoneFieldBorrower)
                return cell
            }else if(indexPath.row == 2){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newBorrow", for: indexPath) as! BorrowerCell
                
                cell.newBorrowBtn.addTarget(self, action: #selector(addNewBorrow), for: .touchUpInside)
                return cell
            }
        }else if(indexPath.section == 1){
            //MARK: Документы
            if(indexPath.row == 0){
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! BorrowerCell
                        cell.photoLbl.text = "Паспорт (главная)"
                        cell.photoLbl.backgroundColor = documents.firstPagePhoto != nil ? UIColor.init(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2):.clear
                        cell.photoButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
                        cell.photoButton.tag = 0
                        cell.photoView.clipsToBounds = true
                      
                        if(documents.firstPagePhoto != nil){
                            cell.photoImage.image = documents.firstPagePhoto
                        }else{
                            cell.photoImage.image = nil
                        }
                    return cell
                }else if(indexPath.row == 1){
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! BorrowerCell
                        cell.photoLbl.text = "Паспорт (прописка)"
                        cell.photoLbl.backgroundColor = documents.secondPagePhoto != nil ? UIColor.init(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2):.clear
                        cell.photoButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
                        cell.photoButton.tag = 1
                        cell.photoView.clipsToBounds = true
                        if(documents.secondPagePhoto != nil){
                            cell.photoImage.image = documents.secondPagePhoto
                        }else{
                            cell.photoImage.image = nil
                        }
                    return cell
                }
        }else if(indexPath.section == 2){
            //MARK: Заем
            if(indexPath.row == 0){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Сумма займа"
                   cell.textFieldBorrower.text = "\(self.currentLoan.loanAmount.formattedWithSeparator)"
                   cell.textFieldBorrower.tag = 2
                   cell.textFieldBorrower.keyboardType = .numberPad
                   cell.textFieldBorrower.isUserInteractionEnabled = true
                   self.addToolBarTextfield(textField: cell.textFieldBorrower)
                 //  cell.imageBorrower.image = UIImage(named: "rubBorrow")
                   cell.textFieldBorrower.delegate = self
                
                   return cell
               }else if(indexPath.row == 1){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Процентная ставка"
                   cell.textFieldBorrower.text = "\(self.currentLoan.loanPercent)"
                   cell.textFieldBorrower.tag = 3
                   cell.textFieldBorrower.keyboardType = .numbersAndPunctuation
                   cell.textFieldBorrower.isUserInteractionEnabled = true
                   self.addToolBarTextfield(textField: cell.textFieldBorrower)
                 //  cell.imageBorrower.image = UIImage(named: "percentBorrow")
                   cell.textFieldBorrower.delegate = self
    
                   return cell
               }else if(indexPath.row == 2){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                    cell.titleBorrower.text = "Дата займа"
                    cell.textFieldBorrower.text = shownDate
                    cell.textFieldBorrower.tag = 4
                    cell.textFieldBorrower.isUserInteractionEnabled = true
                //   cell.imageBorrower.image = UIImage(named: "calendarBrorrow")
                    cell.textFieldBorrower.delegate = self
                
                   return cell
               }else if(indexPath.row == 3){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Период"
                   cell.textFieldBorrower.delegate = self
                   cell.textFieldBorrower.tag = 5
                   cell.textFieldBorrower.text = "Месяц"
                   cell.textFieldBorrower.isUserInteractionEnabled = false
               //    cell.imageBorrower.image = nil
                
                   return cell
               }else if(indexPath.row == 4){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Ежемесячный платеж"
                //   cell.imageBorrower.image = UIImage(named: "rubBorrow")
                   cell.textFieldBorrower.delegate = self
                   cell.textFieldBorrower.tag = 6
                   self.addToolBarTextfield(textField: cell.textFieldBorrower)
                cell.textFieldBorrower.text = "\(self.currentLoan.monthlyPaymentAmount.formattedWithSeparator)"
                   cell.textFieldBorrower.keyboardType = .numberPad
                    cell.textFieldBorrower.isUserInteractionEnabled = true
                
                   return cell
               }else if(indexPath.row == 5){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "День платежа"
                   cell.textFieldBorrower.tag = 7
                   cell.textFieldBorrower.text = "\(self.currentLoan.paymentDay)"
                   cell.textFieldBorrower.delegate = self
                    cell.textFieldBorrower.isUserInteractionEnabled = true
                
                   return cell
               }
        } else if(indexPath.section == 3){
            //MARK: Залог
            if(indexPath.row == 0){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                cell.titleBorrower.text = "Наименование залога"
                cell.textFieldBorrower.delegate = self
                cell.textFieldBorrower.tag = 8
                cell.textFieldBorrower.text = currentPledge.description
                cell.textFieldBorrower.isUserInteractionEnabled = true
                cell.imageBorrower.image = nil
                
                return cell
            }else if(indexPath.row == 1){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                cell.titleBorrower.text = "Оценочная стоимость"
                cell.textFieldBorrower.delegate = self
                cell.textFieldBorrower.tag = 9
                cell.textFieldBorrower.text = "\(currentPledge.pledgeAmount.formattedWithSeparator)"
                cell.textFieldBorrower.isUserInteractionEnabled = true
                cell.imageBorrower.image = nil
                self.addToolBarTextfield(textField: cell.textFieldBorrower)
                cell.textFieldBorrower.keyboardType = .numberPad
                
                return cell
            }else if(indexPath.row == 2){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! BorrowerCell
                cell.photoLbl.text = "Фото №\(indexPath.row - 1)"
                cell.photoButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
                cell.photoButton.tag = 2
                cell.photoView.clipsToBounds = true
                cell.photoLbl.backgroundColor = documents.photoPledge != nil ? UIColor.init(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2):.clear
                if(documents.photoPledge != nil){
                    cell.photoImage.image = documents.photoPledge
                }else{
                    cell.photoImage.image = nil
                }
                return cell
            }else if(indexPath.row == 3){
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newInvestor", for: indexPath) as! BorrowerCell
                
                 cell.newInvestor.addTarget(self, action: #selector(addNewBorrow), for: .touchUpInside)
                return cell
            }
               
        }else if(indexPath.section == 4){
            
            //MARK: Инвестор
            if(indexPath.row == 0){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "investorCell", for: indexPath) as! BorrowerCell
                cell.invesotrNameLbl.text = investorName
                cell.investorBtn.addTarget(self, action: #selector(chooseInvestor), for: .touchUpInside)
                
                return cell
            }else if(indexPath.row == 1){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Сумма займа"
                   cell.textFieldBorrower.text = "\(self.investorInvestment.investmentAmount.formattedWithSeparator)"
                   cell.textFieldBorrower.tag = 10
                   cell.textFieldBorrower.keyboardType = .numberPad
                   cell.textFieldBorrower.isUserInteractionEnabled = true
                   self.addToolBarTextfield(textField: cell.textFieldBorrower)
                 //  cell.imageBorrower.image = UIImage(named: "rubBorrow")
                   cell.textFieldBorrower.delegate = self
                
                   return cell
               }else if(indexPath.row == 2){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Процентная ставка"
                   cell.textFieldBorrower.text = "\(self.investorInvestment.investmentPercent)"
                   cell.textFieldBorrower.tag = 11
                   cell.textFieldBorrower.keyboardType = .numbersAndPunctuation
                   cell.textFieldBorrower.isUserInteractionEnabled = true
                   self.addToolBarTextfield(textField: cell.textFieldBorrower)
                 //  cell.imageBorrower.image = UIImage(named: "percentBorrow")
                   cell.textFieldBorrower.delegate = self
    
                   return cell
               }else if(indexPath.row == 3){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                    cell.titleBorrower.text = "Дата займа"
                    cell.textFieldBorrower.text = shownInvestorDate
                    cell.textFieldBorrower.tag = 12
                    cell.textFieldBorrower.isUserInteractionEnabled = true
                //   cell.imageBorrower.image = UIImage(named: "calendarBrorrow")
                    cell.textFieldBorrower.delegate = self
                
                   return cell
               }else if(indexPath.row == 4){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Период"
                   cell.textFieldBorrower.delegate = self
                   cell.textFieldBorrower.tag = 13
                   cell.textFieldBorrower.text = "Месяц"
                   cell.textFieldBorrower.isUserInteractionEnabled = false
               //    cell.imageBorrower.image = nil
                
                   return cell
               }else if(indexPath.row == 5){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "Ежемесячный платеж"
                //   cell.imageBorrower.image = UIImage(named: "rubBorrow")
                   cell.textFieldBorrower.delegate = self
                   cell.textFieldBorrower.tag = 14
                   self.addToolBarTextfield(textField: cell.textFieldBorrower)
                cell.textFieldBorrower.text = "\(self.investorInvestment.monthlyPaymentAmount.formattedWithSeparator)"
                   cell.textFieldBorrower.keyboardType = .numberPad
                    cell.textFieldBorrower.isUserInteractionEnabled = true
                
                   return cell
               }else if(indexPath.row == 6){
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCell", for: indexPath) as! BorrowerCell
                   cell.titleBorrower.text = "День платежа"
                   cell.textFieldBorrower.tag = 15
                   cell.textFieldBorrower.text = "\(self.investorInvestment.paymentDay)"
                   cell.textFieldBorrower.delegate = self
                    cell.textFieldBorrower.isUserInteractionEnabled = true
                
                   return cell
               }
           
        }
            
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newBorrow", for: indexPath) as! BorrowerCell
        
        cell.newBorrowBtn.addTarget(self, action: #selector(addNewBorrow), for: .touchUpInside)
        return cell
    }
    //MARK: Добавление секций
    @objc func addNewBorrow(){
        countOfBorrow += 1
        if(countOfBorrow == 1){
            sectionCount = 4
        }else if(countOfBorrow == 2){
            sectionCount = 5
        }
        collectionView.reloadData()
    }
    
    @objc func removeBorrow(){
        countOfBorrow -= 1
        if(countOfBorrow == 0){
            sectionCount = 1
        }else if(countOfBorrow == 1){
            sectionCount = 4
        }
        
        collectionView.reloadData()
    }
    
    //MARK:инициализация хедера
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
                 let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! BorrowerHeaderView
                 sectionHeader.titleLbl.text = titlesArray[indexPath.section-1]
                 sectionHeader.removeBtn.addTarget(self, action: #selector(removeBorrow), for: .touchUpInside)
            sectionHeader.removeBtn.isHidden = indexPath.section == 1 || indexPath.section == 4 ? false:true
                 return sectionHeader
           
        } else {
             return UICollectionReusableView()
        }
    }
    
    //MARK:высота хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(section == 0){
            return CGSize(width: collectionView.frame.width, height: 0)
        }else{
            return CGSize(width: collectionView.frame.width, height: 40)
        }
        
    }
    
    //MARK: размеры для ячеек в CollectionView

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width : CGFloat = 0
        var height : CGFloat = 0
        if(indexPath.section == 0){
            if (indexPath.item == 0 || indexPath.item == 1){
                width = self.collectionView.frame.size.width - 16
                height = 71
            } else if(indexPath.item == 2){
                width = self.collectionView.frame.size.width - 16
                height = 40
            }
        }else if(indexPath.section == 1){
            width = self.collectionView.frame.size.width/2 - 16
            height = 100
        }else if(indexPath.section == 2){
            width = self.collectionView.frame.size.width/2 - 16
            height = 71
        }else if(indexPath.section == 3){
            if(indexPath.item < 2){
                width = self.collectionView.frame.size.width - 16
                height = 71
            }else if(indexPath.item == 2){
                width = 80
                height = 80
            }else if(indexPath.item == 3){
                width = self.collectionView.frame.size.width - 16
                height = 40
            }
        }else if(indexPath.section == 4){
            if(indexPath.item == 0){
                width = self.collectionView.frame.size.width - 16
                height = 44
            }else{
                width = self.collectionView.frame.size.width/2 - 16
                height = 71
            }
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 16, right: 8)
    }
}
//MARK: Делегат для текстфилда
extension AddBorrowerController:UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //MARK: Имя заемщика
        
        
        if(textField.tag == 0){
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            borrower.title = currentText!.replacingCharacters(in: stringRange, with: string)
        }else if(textField.tag == 1){
            //MARK: Номер телефона
            if let paste = UIPasteboard.general.string, string == paste {
                let phone = ((textField as! JMMaskTextField).unmaskedText! + string).getPhone()
                let mask = JMStringMask(mask: "+0 (000) 000 00 00")
                let maskedString = mask.mask(string: phone)
                textField.text = maskedString
                borrower.borrowerPhones[textField.tag-1] = maskedString!
                } else {
                    var phoneInsurance = (textField as! JMMaskTextField).unmaskedText! + string
                  
                    if(phoneInsurance.count == 1){
                        if(phoneInsurance == "8"){
                           return false
                        }
                    }
                    if(phoneInsurance.count>=12){
                      phoneInsurance.remove(at: phoneInsurance.index(before: phoneInsurance.endIndex))
                        return false
                    }
                    textField.text = phoneInsurance
                    borrower.borrowerPhones[textField.tag-1] = phoneInsurance
                
        
                }
                       
           
        }else if(textField.tag == 2){
            //MARK: Сумма займа
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            
            currentLoan.loanAmount = Int(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0
            ownInvestment.investmentAmount = Int(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0
            if(currentLoan.loanPercent != 0.0){
                currentLoan.monthlyPaymentAmount = Int(Double(currentLoan.loanAmount/100) * currentLoan.loanPercent)
                ownInvestment.monthlyPaymentAmount = currentLoan.monthlyPaymentAmount
            }
        }else if(textField.tag == 3){
            //MARK: Процент займа
            let aSet = NSCharacterSet(charactersIn:".0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            currentLoan.loanPercent = Double(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0.0
            ownInvestment.investmentPercent = Double(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0.0
            if(currentLoan.loanPercent != 0.0){
                currentLoan.monthlyPaymentAmount = Int(Double(currentLoan.loanAmount/100) * currentLoan.loanPercent)
                ownInvestment.monthlyPaymentAmount = currentLoan.monthlyPaymentAmount
            }
            return string == numberFiltered
          
            
        }else if(textField.tag == 6){
            //MARK: Месячный платеж
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            currentLoan.monthlyPaymentAmount = Int(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0
            ownInvestment.monthlyPaymentAmount = Int(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0
            if(currentLoan.loanAmount != 0){
                currentLoan.loanPercent = Double(currentLoan.monthlyPaymentAmount)/Double(currentLoan.loanAmount/100)
                currentLoan.loanPercent = currentLoan.loanPercent.rounded(toPlaces: 2)
                ownInvestment.investmentPercent = currentLoan.loanPercent
            }
        }else if(textField.tag == 9){
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            currentPledge.pledgeAmount = Int(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0
            
        }else if(textField.tag == 10){
            //MARK: Сумма инвестора
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            
            investorInvestment.investmentAmount = Int(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0
            
            if(investorInvestment.investmentPercent != 0.0){
                investorInvestment.monthlyPaymentAmount = Int(Double(investorInvestment.investmentAmount/100) * investorInvestment.investmentPercent)
            }
        }else if(textField.tag == 11){
            let aSet = NSCharacterSet(charactersIn:".0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            investorInvestment.investmentPercent = Double(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0.0
           
            if(investorInvestment.investmentPercent != 0.0){
                investorInvestment.monthlyPaymentAmount = Int(Double(investorInvestment.investmentAmount/100) * investorInvestment.investmentPercent)
            }
            return string == numberFiltered
        }else if(textField.tag == 14){
            let currentText = textField.text
            guard let stringRange = Range(range, in: currentText!) else { return false }
            investorInvestment.monthlyPaymentAmount = Int(currentText!.replacingCharacters(in: stringRange, with: string)) ?? 0
           
            if(investorInvestment.investmentAmount != 0){
                investorInvestment.investmentPercent = Double(investorInvestment.monthlyPaymentAmount)/Double(investorInvestment.investmentAmount/100)
                investorInvestment.investmentPercent = investorInvestment.investmentPercent.rounded(toPlaces: 2)
                
            }
        }
        
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputView = nil
        textField.reloadInputViews()
        currentTextField = nil
        currentTextField = textField
        if(textField.tag == 2 || textField.tag == 6 || textField.tag == 10 || textField.tag == 14){
            if(textField.text == "0"){
                textField.text = ""
            }else if(textField.tag == 2){
                textField.text = "\(currentLoan.loanAmount)"
            }else if(textField.tag == 6){
                textField.text = "\(currentLoan.monthlyPaymentAmount)"
            }else if(textField.tag == 10){
                textField.text = "\(investorInvestment.investmentAmount)"
            }else if(textField.tag == 14){
                textField.text = "\(investorInvestment.monthlyPaymentAmount)"
            }
        }else if(textField.tag == 3 || textField.tag == 11){
            if(textField.text == "0.0"){
                textField.text = ""
            }else if(textField.tag == 3){
                textField.text = "\(currentLoan.loanPercent)"
            }else if(textField.tag == 11){
                textField.text = "\(investorInvestment.investmentPercent)"
            }
        }else if(textField.tag == 4 || textField.tag == 12){
            textField.setInputViewDatePicker(target: self, selector: #selector(tapDone))
        }else if(textField.tag == 5 || textField.tag == 7 || textField.tag == 8 || textField.tag == 15){
            self.createPickerView()
        }else if(textField.tag == 9){
            if(textField.text == "0"){
                textField.text = ""
            }else {
                textField.text = "\(currentPledge.pledgeAmount)"
            }
        }
    }
  
}

extension AddBorrowerController:UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(currentTextField.tag == 7 || currentTextField.tag == 15){
            return dayArray.count
        }else if(currentTextField.tag == 5){
            return self.periodArray.count
        }else{
            return self.pledgeArray.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(currentTextField.tag == 7 || currentTextField.tag == 15){
            return "\(dayArray[row])"
        }else if(currentTextField.tag == 5){
            return self.periodArray[row]
        }else{
            if(currentTextField.tag == 8){
                self.currentPledge.description = self.pledgeArray[row].title!
                self.currentPledge.pledgeTypeId = self.pledgeArray[row].id!
            }
            return self.pledgeArray[row].title
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(currentTextField.tag == 7){
            self.currentLoan.paymentDay = dayArray[row]
            self.ownInvestment.paymentDay = dayArray[row]
        }
        if(currentTextField.tag == 15){
            self.investorInvestment.paymentDay = dayArray[row]
        }
        if(currentTextField.tag == 8){
            self.currentPledge.description = self.pledgeArray[row].title!
            self.currentPledge.pledgeTypeId = self.pledgeArray[row].id!
        }
    }
    
}


extension UITextField {
    func setInputViewDatePicker(target: Any, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        datePicker.date = (Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
        datePicker.maximumDate = (Calendar.current.date(byAdding: .day, value: 14, to: Date())!)
        datePicker.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        if #available(iOS 14, *) {
          datePicker.preferredDatePickerStyle = .wheels
          datePicker.sizeToFit()
        }
        self.inputView = datePicker
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: "Готово", style: .plain, target: target, action: selector)
        toolBar.setItems([flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}

extension String{
    func getPhone() -> String{
        var phone = self
        if phone.prefix(1) == "+"{
            let prefix = "+" // What ever you want may be an array and step thru it
            if (phone.hasPrefix(prefix)){
                phone  = String(phone.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }else  if phone.prefix(1) == "8"{
            let prefix = "8" // What ever you want may be an array and step thru it
            if (phone.hasPrefix(prefix)){
                phone  = String(phone.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                phone = "7"+phone
            }
        }else if(phone.prefix(1) != "7"){
            phone = "7"+phone
        }
        let vowels: Set<Character> = [" ", "(", ")", "-"]
        phone.removeAll(where: { vowels.contains($0) })
        return phone
    }
}

extension UITextField {

enum PaddingSpace {
    case left(CGFloat)
    case right(CGFloat)
    case equalSpacing(CGFloat)
}

func addPadding(padding: PaddingSpace) {

    self.leftViewMode = .always
    self.layer.masksToBounds = true

    switch padding {

    case .left(let spacing):
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
        self.leftView = leftPaddingView
        self.leftViewMode = .always

    case .right(let spacing):
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
        self.rightView = rightPaddingView
        self.rightViewMode = .always

    case .equalSpacing(let spacing):
        let equalPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
        // left
        self.leftView = equalPaddingView
        self.leftViewMode = .always
        // right
        self.rightView = equalPaddingView
        self.rightViewMode = .always
    }
}
}
