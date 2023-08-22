//
//  LogInController.swift
//  Borrower
//
//  Created by RX Group on 09.12.2020.
//

import UIKit

class LogInController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var login:String!
    var password:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
           let info = notification.userInfo! as! [String: AnyObject],
               kbSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
           contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)

           self.table.contentInset = contentInsets
           self.table.scrollIndicatorInsets = contentInsets

           var aRect = self.table.frame
           aRect.size.height -= kbSize.height
       }
    
    @objc func keyboardWillHide(notification: NSNotification){
            let contentInsets = UIEdgeInsets.zero
           self.table.contentInset = contentInsets
           self.table.scrollIndicatorInsets = contentInsets
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }

    @IBAction func enter(_ sender: Any) {
        if(login == nil || login.count==0){
            setMessage(text: "Введите логин", controller: self)
        }else if(password == nil || password.count == 0){
            setMessage(text: "Введите пароль", controller: self)
        }else{
            let object = ["login":login!,"password":password!] as [String : Any]
            postRequest(JSON: object , URLString: mainDomen + "/api/account/tokens", completion: {
                result in
                DispatchQueue.main.async{
                    if(result["errors"] == nil){
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
                            
                        }catch{
                            
                        }
                     } catch {
                         print(error.localizedDescription)
                     }
                      
                    }else{
                        setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String , controller: self)
                    }
             }
            })
            

        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

extension LogInController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell:RegistrationCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! RegistrationCell
  
            switch indexPath.row {
            case 0:
                cell.titleLbl.text = "Логин"
                cell.textField.tag = 0
                cell.textField.autocapitalizationType = .sentences
                self.addToolBarTextfield(textField: cell.textField)
            case 1:
                cell.titleLbl.text = "Пароль"
                cell.textField.tag = 1
                cell.textField.isSecureTextEntry = true
                self.addToolBarTextfield(textField: cell.textField)
            default:
                print("")
            }
        
        cell.textField.delegate = self
        return cell
    }
    
    
}

extension LogInController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 0){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.login = currentText.replacingCharacters(in: stringRange, with: string)
        }else if(textField.tag == 1){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.password = currentText.replacingCharacters(in: stringRange, with: string)
        }
        return true
    }
}
