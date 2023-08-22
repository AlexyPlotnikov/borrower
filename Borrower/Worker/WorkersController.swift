//
//  WorkersController.swift
//  Borrower
//
//  Created by RX Group on 23.12.2020.
//

import UIKit

extension Notification.Name {
    public static let reloadWorkers = Notification.Name(rawValue: "reloadWorkers")
}

class WorkersController: UIViewController {
    struct Worker:Codable {
        var id:String?
        var isActive:Bool?
        var login:String?
        var name:String?
        var role:String?
    }

    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    private var arrayWorkers:[Worker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadworkers), name: .reloadWorkers, object: nil)
        self.reloadworkers()
        self.table.tableFooterView = UIView()
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    @objc func reloadworkers(){
        refreshToken(controller: self, completion: {
            getRequest(URLString:mainDomen + "/api/users/all/true", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let review = try! JSONDecoder().decode([Worker].self, from: jsonData)
                        self.arrayWorkers = review
                        self.emptyLbl.isHidden = self.arrayWorkers.count > 0
                        self.table.reloadData()
                    }catch{
                        
                    }
                    
                }
            })
        })
    }
    

    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addWorker(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "addVC") as! AddViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension WorkersController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayWorkers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell:WorkerCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! WorkerCell
        
        cell.name.text = "\(arrayWorkers[indexPath.row].name ?? "Нет данных") (\(arrayWorkers[indexPath.row].login ?? "Нет данных"))"
        cell.role.text = arrayWorkers[indexPath.row].role ?? "Нет данных"
        
        return cell
       
    }


}
