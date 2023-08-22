//
//  AddViewController.swift
//  Borrower
//
//  Created by RX Group on 23.12.2020.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    
    private var name = ""
    private var login = ""
    private var password = ""
    private var role = ""
    private var roles:[String] = []
    private var pickerView:UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        refreshToken(controller: self, completion: {
            getRequest(URLString: mainDomen + "/api/users/roles", completion: {
                result in
                DispatchQueue.main.async {
                    self.roles = result as! [String]
                }
                
            })
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    func createPickerView(textField:UITextField){
        
            pickerView = UIPickerView()
            pickerView.delegate = self
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
      
            toolBar.setItems([spaceButton,doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
            textField.inputView = pickerView
       
    }
    
    @objc func handleTap() {
        self.view.endEditing(true)
        self.checkModel()
        self.table.reloadData()
    }
    
    func checkModel(){
        doneBtn.isHidden = name.count == 0 || login.count == 0 || role.count == 0 || password.count == 0
    }
    
    
    @IBAction func addWorker(_ sender: Any) {
        let model = ["name":name,"login":login,"role":role,"password":password] as [String:Any]
        refreshToken(controller: self, completion: {
            postRequest(JSON: model, URLString: mainDomen + "/api/account/register/user", completion: {
                result in
                DispatchQueue.main.async {
                    if(result["errors"] == nil){
                        self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: .reloadWorkers, object: nil, userInfo: nil)
                    }else{
                        if((result["errors"] as! [String:Any])["Login"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["Login"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["Password"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["Password"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["Name"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["Name"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["ContractorTitle"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["ContractorTitle"] as! Array<Any>)[0] as! String, controller: self)
                        }else if((result["errors"] as! [String:Any])["errors"] != nil){
                            setMessage(text: ((result["errors"] as! [String:Any])["errors"] as! Array<Any>)[0] as! String, controller: self)
                        }
                    }
                }
                
                
            })
        })
    }
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension AddViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell:AddCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! AddCell
        cell.textField.tag = indexPath.row
        cell.textField.delegate = self
        switch indexPath.row {
        case 0:
            cell.bottomTitle.text = "Имя сотрудника"
        case 1:
            cell.bottomTitle.text = "Логин сотрудника"
        case 2:
            cell.bottomTitle.text = "Выберите роль сотрудника"
            cell.textField.text = role
            self.createPickerView(textField: cell.textField)
        case 3:
            cell.bottomTitle.text = "Пароль сотрудника"
            cell.textField.isSecureTextEntry = true
        default:
            cell.bottomTitle.text = ""
        }
       
        return cell
    }
    
    
    
}

extension AddViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 0){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.name = currentText.replacingCharacters(in: stringRange, with: string)
        }else if(textField.tag == 1){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.login = currentText.replacingCharacters(in: stringRange, with: string)
        }else if(textField.tag == 3){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            self.password = currentText.replacingCharacters(in: stringRange, with: string)
        }
        self.checkModel()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.checkModel()
    }
}

extension AddViewController:UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.roles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.role = self.roles[row]
        return self.roles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.role = self.roles[row]
    }
    
}
