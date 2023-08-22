//
//  InvestorController.swift
//  Borrower
//
//  Created by RX Group on 15.12.2020.
//

import UIKit

class InvestorController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var allSummLbl: UILabel!
    var investor = Investor()
    var dictionaryByMonth:[[Investments]] = [[]]
    
//    var investors1 = [Investor(summ: "100 000 руб.", date: "09.02", color: UIColor.init(displayP3Red: 246/255, green: 90/255, blue: 59/255, alpha: 1), allSumm: "120 000 руб.", name: "Мишин Э.Н.", profit: "20 000 руб."),
//                      Investor(summ: "40 000 руб.", date: "10.02", color: UIColor.init(displayP3Red: 237/255, green: 170/255, blue: 59/255, alpha: 1), allSumm: "55 000 руб.", name: "Николаев В.А.", profit: "15 000 руб."),
//                      Investor(summ: "10 000 руб.", date: "21.02", color: UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1), allSumm: "15 000 руб.", name: "Васильев К.В.", profit: "5 000 руб.")]
//
//    var investors2 = [Investor(summ: "150 000 руб.", date: "16.03", color: UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1), allSumm: "170 000 руб.", name: "Краков И.В.", profit: "20 000 руб.")]
//
//    var investors3 = [Investor(summ: "40 000 руб.", date: "22.03", color: UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1), allSumm: "46 000 руб.", name: "Иванов Н.Н.", profit: "6 000 руб."),
//                      Investor(summ: "25 000 руб.", date: "23.03", color: UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1), allSumm: "35 000 руб.", name: "Славин В.А.", profit: "10 000 руб."),
//                      Investor(summ: "70 000 руб.", date: "24.03", color: UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1), allSumm: "15 000 руб.", name: "Рычков К.В.", profit: "5 000 руб."),
//                      Investor(summ: "65 000 руб.", date: "24.03", color: UIColor.init(displayP3Red: 39/255, green: 190/255, blue: 130/255, alpha: 1), allSumm: "170 000 руб.", name: "Станиславин И.В.", profit: "20 000 руб.")]
    
    var name:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTitle.text = investor.title
        allSummLbl.text = "Инвестиций на сумму \(investor.debtBalance!) руб."
        
        dictionaryByMonth = (investor.investments?.groupSort(byDate:{ Date($0.nextPaymentDate ?? "") ?? Date()}))!
        
        self.table.reloadData()
        
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getDateByFormat(format:String, date:String)->String{
        if(date != ""){
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            if dateFormatterGet.date(from: date) == nil {
                dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            }
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = format
           // dateFormatterPrint.dateStyle = DateFormatter.Style.short
            dateFormatterPrint.locale = NSLocale(localeIdentifier: "ru") as Locale

            return dateFormatterPrint.string(from: dateFormatterGet.date(from: date)!)
            
        }else{
            return date
        }
    }

}

extension InvestorController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 164
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for i in 0..<dictionaryByMonth.count{
            if(i == section){
                return dictionaryByMonth[i].count
            }
        }
        return 0
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionaryByMonth.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell:InvestorCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! InvestorCell
         //   cell.separator.isHidden = indexPath.row == 0
        let investment = dictionaryByMonth[indexPath.section][indexPath.row]

        cell.dateLbl.text = "Ежемесячный платеж " + self.getDateByFormat(format: "dd MMMM", date: investment.nextPaymentDate ?? "")
    //    cell.dateLbl.textColor = investor.color
   //     cell.shield.backgroundColor = investor.color.withAlphaComponent(0.3)
      //  cell.allSummLbl.text = "\(investment.investmentAmount ?? 0) руб."
        cell.nameLbl.text = investment.borrowerTitle
//        cell.profitLbl.text = investor.profit
        cell.summLbl.text = "\(investment.nextPaymenAmount ?? 0)"
        //cell.summLbl.textColor = investor.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.table.frame.size.width, height: 20))
                view.backgroundColor = .clear
            let label = UILabel(frame: CGRect(x: 0, y: 5, width: 100, height: 20))
                label.text = self.getDateByFormat(format: "dd MMMM", date: dictionaryByMonth[section][0].nextPaymentDate ?? "")
                label.font = UIFont.systemFont(ofSize: 15)
                label.textColor = UIColor.init(displayP3Red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
                label.textAlignment = .center
                label.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                label.layer.cornerRadius = 10
                label.layer.masksToBounds = true
                view.addSubview(label)
            return view
        
    }
    
    
    
    
}

extension Date {

    init?(_ string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss") {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: string) else { return nil }
        self = date
    }
}

extension Sequence {
    func groupSort(ascending: Bool = false, byDate dateKey: (Iterator.Element) -> Date) -> [[Iterator.Element]] {
        var categories: [[Iterator.Element]] = []
        for element in self {
            let key = dateKey(element)
            guard let dayIndex = categories.firstIndex(where: { $0.contains(where: { Calendar.current.isDate(dateKey($0), inSameDayAs: key) }) }) else {
                guard let nextIndex = categories.firstIndex(where: { $0.contains(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) }) else {
                    categories.append([element])
                    continue
                }
                categories.insert([element], at: nextIndex)
                continue
            }
            
            guard let nextIndex = categories[dayIndex].firstIndex(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) else {
                categories[dayIndex].append(element)
                continue
            }
            categories[dayIndex].insert(element, at: nextIndex)
        }
        return categories
    }
}
