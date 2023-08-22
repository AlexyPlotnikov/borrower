//
//  AddInvestorController.swift
//  Borrower
//
//  Created by RX Group on 18.01.2021.
//

import UIKit



class AddInvestorController: UIViewController {
    
    var countRows = 2
    @IBOutlet weak var table: UITableView!
    
    struct InvestorReg:Codable{
        var title:String = ""
        var investorPhones:[String] = [""]
        var id:String? = ""
        
        var asDictionary : [String:Any] {
            let mirror = Mirror(reflecting: self)
            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
              guard let label = label else { return nil }
              return (label, value)
            }).compactMap { $0 })
            return dict
          }
    }
    var regInvestor = InvestorReg()
    var isUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    @IBAction func doneBtn(_ sender: Any) {

        if(isUpdate){
            putRequest(JSON: regInvestor.asDictionary, URLString: mainDomen + "/api/investors/update", completion: {
                result in
                print(result)
                if(result["errors"] == nil){
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        NotificationCenter.default.post(name: .chooseRow, object: nil, userInfo: ["row":2])
                    }
                }else{
                    if((result["errors"] as! [String:Any])["Title"] != nil){
                        setMessage(text: ((result["errors"] as! [String:Any])["Title"] as! Array<Any>)[0] as! String, controller: self)
                    }else if((result["errors"] as! [String:Any])["InvestorPhones"] != nil){
                        setMessage(text: ((result["errors"] as! [String:Any])["InvestorPhones"] as! Array<Any>)[0] as! String, controller: self)
                    }else if((result["errors"] as! [String:Any])["errors"] != nil){
                        setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String, controller: self)
                    }
                }
            })
        }else{
            do{
              
                postRequest(JSON: regInvestor.asDictionary, URLString: mainDomen + "/api/investors/add", completion: {
                    result in
                    if(result["errors"] == nil){
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: .chooseRow, object: nil, userInfo: ["row":2])
                        }
                    }else{
                        if((result["errors"] as! [String:Any])["Title"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["Title"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["InvestorPhones"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["InvestorPhones"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["errors"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String, controller: self)
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openContactList(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseContactVC") as! ChooseContactListController
        let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                              presenting: self,
                                                                              isDismissable: true)
        
        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        let rootViewController = viewController.viewControllers.first as! ContactController
        rootViewController.embededInvestor = self
        rootViewController.isInvestor = true
        self.present(viewController, animated: true)
        
    }
    
}

extension AddInvestorController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cellReuseIdentifier = "cell"
            let cell:RegistrationCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! RegistrationCell
            cell.titleLbl.text = "ФИО"
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row
            cell.textField.text = regInvestor.title
            self.addToolBarTextfield(textField: cell.textField)
            
            return cell
        }else{
            let cellReuseIdentifier = "cellPhone"
            let cell:RegistrationCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! RegistrationCell
            cell.titleLbl.text = "Номер телефона"
            cell.phoneField.delegate = self
            cell.phoneField.tag = indexPath.row
            cell.phoneField.keyboardType = .phonePad
            let mask = JMStringMask(mask: "+0 (000) 000 00 00")
            let maskedString = mask.mask(string: regInvestor.investorPhones[0])
            
            cell.phoneField.text = maskedString
            cell.phoneField.addPadding(padding: .left(48))
            self.addToolBarTextfield(textField: cell.phoneField)
            return cell
        }
        
        
    }
    
    
    
    
}

extension AddInvestorController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 0){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            regInvestor.title = currentText.replacingCharacters(in: stringRange, with: string)
        }else{
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
            regInvestor.investorPhones[textField.tag-1] = phoneInsurance
        }
        return true
    }
}
