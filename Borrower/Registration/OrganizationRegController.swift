//
//  OrganizationRegController.swift
//  Borrower
//
//  Created by RX Group on 03.12.2020.
//

import UIKit

struct User:Codable {
    var name:String
    var login:String
    var organizaton:String
    var token:String
    var refreshToken:String
    var isAdmin:Bool
}

struct Person:Codable {
    var refreshToken:String? = ""
    var accessToken:String? = ""
}

class OrganizationRegController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var organization:String = ""
    var login:String = ""
    var name:String = ""
    var firstPass:String = ""
    var secondPass:String = ""
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var topconstraint: NSLayoutConstraint!
    var isDone = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 80, right: 0)
        let tapGestureRecognizer    = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
      
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
       {
           let info = notification.userInfo! as! [String: AnyObject],
               kbSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
           contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)

           self.table.contentInset = contentInsets
           self.table.scrollIndicatorInsets = contentInsets

           var aRect = self.table.frame
           aRect.size.height -= kbSize.height
       }
    @objc func keyboardWillHide(notification: NSNotification)
       {
            let contentInsets = UIEdgeInsets(top: -1, left: 0, bottom: 80, right: 0)
           self.table.contentInset = contentInsets
           self.table.scrollIndicatorInsets = contentInsets
       }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        if(!isDone){
            if(organization.count == 0){
                setMessage(text: "Укажите название организации", controller: self)
                return
            }else if(login.count == 0){
                setMessage(text: "Укажите логин", controller: self)
                return
            }else if(name.count == 0){
                setMessage(text: "Укажите имя сотрудника", controller: self)
                return
            }else if(firstPass.count == 0){
                setMessage(text: "Укажите пароль", controller: self)
                return
            }else if(secondPass.count == 0){
                setMessage(text: "Укажите пароль еще раз", controller: self)
                return
            }else if(firstPass != secondPass){
                setMessage(text: "Пароли не соответсвуют", controller: self)
                return
            }else{
                
                let object = ["login":login,"name":name,"password":firstPass,"contractorTitle":organization] as [String:Any]
                postRequest(JSON: object, URLString: mainDomen + "/api/account/register/admin", completion: {
                    result in
                    DispatchQueue.main.async{
                    if(result["errors"] == nil){
                        self.topImage.image = UIImage(named: "doneImage")
                        self.doneBtn.setImage(UIImage(named: "startBtn"), for: .normal)
                        self.table.isHidden = true
                        self.topconstraint.constant = 120
                        self.isDone = true
                       
                         do {
                             //сериализация справочника в Data, чтобы декодировать ее в структуру
                             let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                             let review = try! JSONDecoder().decode(Person.self, from: jsonData)
                             let encoder = JSONEncoder()
                             if let encoded = try? encoder.encode(review) {
                                let defaults = UserDefaults.standard
                                defaults.set(encoded, forKey: "SavedPerson")
                             }
                            do{
                                let jwt = try decode(jwt: review.accessToken!)
                                let fullName = jwt.body["fullname"] as! String
                                let organization = jwt.body["contractortitle"] as! String
                                let login = jwt.body["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"] as! String
                                let admin = jwt.body["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"] as! String == "Administrator"
                                mainUser = User(name: fullName, login: login, organizaton: organization, token: review.accessToken!, refreshToken: review.refreshToken!, isAdmin: admin)
                                
                            }catch{
                                
                            }
                         } catch {
                             print(error.localizedDescription)
                         }
                          
                      
                     }else {
                        if((result["errors"] as! [String:Any])["Login"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["Login"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["Password"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["Password"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["Name"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["Name"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["ContractorTitle"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["ContractorTitle"] as! Array<Any>)[0] as! String, controller: self)
                        }
                        
                    }
                    }
                
                })
                
            }
        }else{
            if(codeSaved(key: "CodePass")){
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SwipeVC") as! SwipeNavigationController
                    viewController.modalPresentationStyle = .fullScreen
                 self.present(viewController, animated: true, completion: nil)
            }else{
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FaceID") as! FaceIDController
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.isInit = true
                    self.present(viewController, animated: true, completion: nil)
                
            }
            
        }
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
}

func setMessage(text:String, controller:UIViewController) {
    DispatchQueue.main.async{
        let alertController = UIAlertController(title: "Внимание!", message:
            text , preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}

extension OrganizationRegController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return 5
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell:RegistrationCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! RegistrationCell
        
            switch indexPath.row {
            case 0:
                cell.titleLbl.text = "Название организации"
                cell.textField.tag = 0
                cell.textField.autocapitalizationType = .sentences
                self.addToolBarTextfield(textField: cell.textField)
            case 1:
                cell.titleLbl.text = "Имя сотрудника"
                cell.textField.tag = 1
                cell.textField.autocapitalizationType = .sentences
                self.addToolBarTextfield(textField: cell.textField)
                
            case 2:
                cell.titleLbl.text = "Логин (без пробелов)"
                cell.textField.tag = 2
                cell.textField.autocapitalizationType = .sentences
                self.addToolBarTextfield(textField: cell.textField)
            case 3:
                cell.titleLbl.text = "Пароль"
                cell.textField.tag = 3
                cell.textField.isSecureTextEntry = true
                self.addToolBarTextfield(textField: cell.textField)
            case 4:
                cell.titleLbl.text = "Повторите пароль"
                cell.textField.tag = 4
                cell.textField.isSecureTextEntry = true
                self.addToolBarTextfield(textField: cell.textField)
            default:
                print("")
            }
        
        cell.textField.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    
}

extension OrganizationRegController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 0){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.organization = currentText.replacingCharacters(in: stringRange, with: string)
        }else if(textField.tag == 1){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.name = currentText.replacingCharacters(in: stringRange, with: string)
        }else if(textField.tag == 2){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.login = currentText.replacingCharacters(in: stringRange, with: string)
        }else if(textField.tag == 3){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.firstPass = currentText.replacingCharacters(in: stringRange, with: string)
        }else{
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.secondPass = currentText.replacingCharacters(in: stringRange, with: string)
        }
        return true
    }
}
