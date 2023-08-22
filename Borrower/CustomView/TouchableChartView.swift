//
//  TouchableChartView.swift
//  Abie Chief 2.0
//
//  Created by Иван Зубарев on 07.08.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit


class TouchableChartView: UIView {
    lazy var newHeight = (self.frame.size.height - 25)
    var dataArray:[Double] = []{
        didSet{
            setNeedsDisplay()
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.clean()
        let newX = self.frame.size.width/CGFloat(dataArray.count)
        let curvePath = CGMutablePath()
        
        for i in 0..<3{
            //отрисовка серых линий на фоне
            self.drawLineFromPoint(start: CGPoint(x: 0.0, y: newHeight/2*CGFloat(i)), toPoint: CGPoint(x: self.frame.size.width, y: newHeight/2*CGFloat(i)), ofColor: UIColor.init(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 0.08))
        }
        
        for i in 0..<dataArray.count{
            //отрисовка месяцев внизу
            let monthInt = Calendar.current.dateComponents([.month], from: Date()).month!
            let month = Calendar.current.component(.month, from: Date()) - (dataArray.count - i)
            let calendar = Calendar.current
            let lastMonthDate = Calendar.current.date(byAdding: .month, value: month-calendar.component(.month, from: Date()), to: Date())
            let monthString = lastMonthDate!.monthRus[0..<3]
            self.createlbl(point: CGPoint(x: CGFloat(i) * newX - monthString.widthSize(font: UIFont.systemFont(ofSize: 10))/2, y: newHeight+8), value:monthString )
            //задаю координаты линий для графика
            if(i == 0){
                curvePath.move(to: CGPoint(x: CGFloat(i) * newX , y: newHeight-newHeight*CGFloat(dataArray[i]/100)))
            }else{
                curvePath.addLine(to: CGPoint(x: CGFloat(i) * newX , y: newHeight-newHeight*CGFloat(dataArray[i]/100)))
            }
            
        }
        //отриосвываю линии на графике
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 1
        
        shape.path = curvePath
        self.layer.addSublayer(shape)
        
        for i in 0..<dataArray.count{
            //задаю координаты и отриосвываю точки на графике
            let dotPath = UIBezierPath(ovalIn: CGRect(x: (CGFloat(i) * newX) - 4, y: newHeight-newHeight*CGFloat(dataArray[i]/100) - 4, width: 8, height: 8))
            let layer = CAShapeLayer()
            layer.path = dotPath.cgPath
            layer.lineWidth = 2
            layer.strokeColor = UIColor.init(displayP3Red: 19/255, green: 20/255, blue: 21/255, alpha: 1).cgColor
            layer.fillColor = UIColor.white.cgColor
            self.layer.addSublayer(layer)
        }
    }
    
    func createlbl(point:CGPoint, value:String){
        let label = UILabel(frame: CGRect(x: point.x , y: point.y , width: value.widthSize(font: UIFont.systemFont(ofSize: 10)), height: value.heightSize(font: UIFont.systemFont(ofSize: 10))))
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.textColor = .white
      
        label.text = value
        self.addSubview(label)
     //   labelArray.append(label)
    
    }
    
    func clean(){
        for view in self.subviews{
            if view is UILabel{
                view.removeFromSuperview()
            }
        }
         if(self.layer.sublayers != nil){
             for layer in self.layer.sublayers!{
                 layer.removeFromSuperlayer()
             }
         }
    }
}

extension String {
    func widthSize(font:UIFont) -> CGFloat{
    let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)
    let boundingBox = self.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
    return ceil(boundingBox.width)
    }
    
    func heightSize(font:UIFont) -> CGFloat{
    let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)
    let boundingBox = self.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
    return ceil(boundingBox.height)
    }
}

extension UIView{
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor) {

        let path = UIBezierPath()
       
        path.move(to: start)
        path.addLine(to: end)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0

        self.layer.addSublayer(shapeLayer)
    }
}

extension Date {
    var monthRus: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        dateFormatter.locale = NSLocale(localeIdentifier: "ru") as Locale
        return dateFormatter.string(from: self)
    }
}
extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}
