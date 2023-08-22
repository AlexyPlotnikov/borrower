//
//  ViewController.swift
//  Borrower
//
//  Created by RX Group on 26.11.2020.
//

import UIKit



class ViewController: UIViewController {
    struct Statistic:Codable{
        var averageRate:Double = 0
        var profit:Int = 0
        var statisticByMonth:[StatisticByMonth] = []
    }
    
    struct StatisticByMonth:Codable {
        var rate:Double = 0
        var profit:Int = 0
    }
    struct BorrowerValue{
        var todaySumm:String = "–"
        var todayCount:String = "–"
    }
    
    struct InvestorValue{
        var todaySumm:String = "–"
        var todayCount:String = "–"
    }
    
    struct PledgeValue{
        var count:String = "–"
        var summ:String = "–"
    }
    
    @IBOutlet weak var table: UITableView!
   
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var organizationLbl: UILabel!
    var statByMonthArray:[Double] = []
    var todayBorrower = BorrowerValue()
    var todayInvestor = InvestorValue()
    var pledges = PledgeValue()
    
    let imagesArray = ["borrowerIcon","investorIcon","propertyIcon"]
    let titlesArray = ["Заемщики", "Инвесторы", "Имущество"]
    
    let leftTitlesArray = ["–","–","–"]
    let leftSubtitleArray = ["Вернут сегодня", "Выплатить сегодня", "Сумма"]
    
    let rightTitlesArray = ["–","–","–"]
    let rightSubtitleArray = [ "Платежей","Кол-во выплат", "Позиций"]
   
    var statistic = Statistic()
    
    lazy var mainModel = [(imagesArray[0],titlesArray[0],leftTitlesArray[0],leftSubtitleArray[0],rightTitlesArray[0],rightSubtitleArray[0]),(imagesArray[1],titlesArray[1],leftTitlesArray[1],leftSubtitleArray[1],rightTitlesArray[1],rightSubtitleArray[1]),(imagesArray[2],titlesArray[2],leftTitlesArray[2],leftSubtitleArray[2],rightTitlesArray[2],rightSubtitleArray[2])]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.tableFooterView = UIView()
        nameLbl.text = mainUser.name
        organizationLbl.text = mainUser.organizaton
        mainModel[0].2 = todayBorrower.todaySumm
        mainModel[0].4 = todayBorrower.todayCount
        mainModel[1].2 = todayInvestor.todaySumm
        mainModel[1].4 = todayInvestor.todayCount
        mainModel[2].2 = pledges.summ
        mainModel[2].4 = pledges.count
        getDictionaryRequest(URLString: mainDomen + "/api/statistics/profit/2021", completion: {
            result in
            DispatchQueue.main.async {
                do {
                    //сериализация справочника в Data, чтобы декодировать ее в структуру
                   let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    self.statistic = try! JSONDecoder().decode(Statistic.self, from: jsonData)
                    let maxValue = self.statistic.statisticByMonth.reduce(Int.min, { max($0, $1.profit) })
                    
                    for i in 0..<self.statistic.statisticByMonth.count{
                        self.statByMonthArray.append(Double(self.statistic.statisticByMonth[i].profit)/Double(maxValue)*100)
                    }
                    self.table.reloadData()


                }catch{

                }
            }
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func showProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .openProfile, object: nil, userInfo: nil)
            }
            
        })
       
    }
    
}
//MARK: Инициализация таблицы
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 222
        }else{
            return 107
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainModel.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cellReuseIdentifier = "cellRating"
            let cell:MainCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainCell
                cell.statRate.text = "\(self.statistic.averageRate.rounded(toPlaces: 2)) %"
                cell.statProfit.text = "\(self.statistic.profit.formattedWithSeparator) руб"
                cell.statView.dataArray = self.statByMonthArray
           
            return cell
        }else{
            let cellReuseIdentifier = "cell"
            let cell:MainCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainCell
                cell.imageIcon.image = UIImage(named: mainModel[indexPath.row-1].0)
                cell.mainTitle.text = mainModel[indexPath.row-1].1
                cell.leftTitle.text = mainModel[indexPath.row-1].2
                cell.leftSubtitle.text = mainModel[indexPath.row-1].3
                cell.rightTitle.text = mainModel[indexPath.row-1].4
                cell.rightSubtitle.text = mainModel[indexPath.row-1].5
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row != 0){
            self.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .chooseRow, object: nil, userInfo: ["row":indexPath.row])
                }
            })
        }
    }
}


