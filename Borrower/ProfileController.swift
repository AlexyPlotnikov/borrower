//
//  ProfileController.swift
//  Borrower
//
//  Created by RX Group on 09.12.2020.
//

import UIKit

class ProfileController: UIViewController {

    @IBOutlet weak var organizationLbl: UILabel!
    @IBOutlet weak var table1: UITableView!
    @IBOutlet weak var table2: UITableView!
    private var imagesTop = ["worker","investorIcon"]
    private var titlesTop = ["Сотрудники", "Инвесторы"]
    private var imagesDown = ["passwordEdit","phone","exit"]
    private var titlesDown = ["Изменить пароль", "Техподдержка","Выход"]
    private var oldPass = ""
    private var newPassOne = ""
    private var newPassTwo = ""
    
    @IBOutlet weak var nameLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.text = mainUser.name
        organizationLbl.text = mainUser.organizaton
        self.table1.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func exit(_ sender: Any) {
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension ProfileController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == table1){
            return 1
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if(cell == nil){
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
                cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
        if(tableView == table1){
            cell?.accessoryType = .disclosureIndicator
            cell?.imageView?.image = UIImage(named: imagesTop[indexPath.row])
            cell?.textLabel?.text = titlesTop[indexPath.row]
            cell?.textLabel?.textColor = .white
        }else{
            cell?.accessoryType = .none
            cell?.imageView?.image = UIImage(named: imagesDown[indexPath.row])
            cell?.textLabel?.text = titlesDown[indexPath.row]
            if(indexPath.row == 2){
                cell?.textLabel?.textColor = .red
            }else{
                cell?.textLabel?.textColor = .white
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == table1){
            if(indexPath.row == 0){
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "workersVC") as! WorkersController

                self.navigationController?.pushViewController(viewController, animated: true)
            }else{
                
            }
        }else{
            if(indexPath.row==0){
                self.changePassword()
            }else if(indexPath.row == 1){
                DispatchQueue.main.async{
                    if let url = URL(string: "tel://+73833194022") {
                        UIApplication.shared.openURL(url)
                    }
                }
            }else if(indexPath.row == 2){
                let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите выйти из аккаунта?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { action in
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "SavedPerson")
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "startVC") as! SwipeNavigationController
                        viewController.modalPresentationStyle = .fullScreen
                        self.present(viewController, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func changePassword() {
        let alertController = UIAlertController(title: "Изменить пароль", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Готово", style: .default, handler: { alert -> Void in
            self.oldPass = alertController.textFields![0].text ?? ""
            self.newPassOne = alertController.textFields![1].text ?? ""
            self.newPassTwo = alertController.textFields![2].text ?? ""
            
            if(self.newPassOne != self.newPassTwo){
                setMessage(text: "Ваши пароли не соответствуют", controller: self)
            }else{
                let model = ["login": mainUser.login,
                             "oldPassword": self.oldPass,
                             "newPassword": self.newPassOne]
                patchRequest(JSON: model, URLString: mainDomen + "/api/users/update/password", completion: {
                    result in
                    print(result)
                })
            }
            })
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in })
        
        alertController.addTextField(configurationHandler: {
            (textField : UITextField!) -> Void in
                    textField.placeholder = "Старый пароль"
                    textField.returnKeyType = .next
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Введите новый пароль"
                textField.returnKeyType = .next
            }
        
        alertController.addTextField(configurationHandler: {
            (textField : UITextField!) -> Void in
                    textField.placeholder = "Новый пароль еще раз"
                    textField.returnKeyType = .done
        })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
    }
}

extension ProfileController:UITextFieldDelegate{
    
}


