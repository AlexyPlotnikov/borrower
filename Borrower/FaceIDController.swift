//
//  FaceIDController.swift
//  Borrower
//
//  Created by RX Group on 09.12.2020.
//

import UIKit
import LocalAuthentication
import AVFoundation

class FaceIDController: UIViewController {
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var circle4: UIView!
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var faceIDBtn: UIButton!
    
    lazy var grayColor = UIColor.init(displayP3Red: 178/255, green: 178/255, blue: 178/255, alpha: 0.5)
    lazy var currentColor = UIColor.init(displayP3Red: 40/255, green: 214/255, blue: 204/255, alpha: 1)
    
    lazy var circlessArray = [circle1,circle2,circle3,circle4]
    var code:String = ""
    var code2:String = ""
    var isInit:Bool = false
    var nextStep = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if(isInit){
            topTitle.text = "Укажите пароль"
            doneBtn.isHidden = false
            faceIDBtn.isEnabled = false
        }else{
            let defaults = UserDefaults.standard
            code2 = defaults.string(forKey: "CodePass")!
            topTitle.text = "Введите пароль"
            self.faceID()
            doneBtn.isHidden = true
            faceIDBtn.isEnabled = true
        }
     
        for circle in circlessArray{
            circle!.backgroundColor = grayColor
            circle!.layer.cornerRadius = 4.5
        }
        
        if(self.biometricType() == .face){
            faceIDBtn.setImage(UIImage(named: "FaceID"), for: .normal)
        }else{
            faceIDBtn.setImage(UIImage(named: "fingerprint"), for: .normal)
        }
    }

    func biometricType() -> BiometricType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            @unknown default:
                return .none
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBAction func keyboardTaped(_ sender: UIButton) {
        if(isInit){
            if(code.count <= 3){
                code = code + "\(sender.tag)"
                if(code.count == 4){
                    doneBtn.isEnabled = true
                }else{
                    doneBtn.isEnabled = false
                }
            }
        }else{
        
            if(code.count <= 3){
                code = code + "\(sender.tag)"
                AudioServicesPlaySystemSound(1519)
                if(code == code2){
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SwipeVC") as! SwipeNavigationController
                        viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true, completion: nil)
                }else{
                    AudioServicesPlaySystemSound(1520)
                }
            }
        }
        self.coloredCircle()
    }
    
    @IBAction func deleteTaped(_ sender: Any) {
        if(code.count>0){
            code = String(code.dropLast())
        }
        if(code.count == 4){
            doneBtn.isEnabled = true
        }else{
            doneBtn.isEnabled = false
        }
        self.coloredCircle()
    }
    
    func coloredCircle(){
        for i in 0..<circlessArray.count{
            if(i < code.count){
                circlessArray[i]!.backgroundColor = currentColor
            }else{
                circlessArray[i]!.backgroundColor = grayColor
            }
        }
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey: "CodePass")
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SwipeVC") as! SwipeNavigationController
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func retryFaceID(_ sender: Any) {
        self.faceID()
    }
    
    
    
    func faceID(){
        let context = LAContext()
           var error: NSError?

           if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
               let reason = "Identify yourself!"

               context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                   [weak self] success, authenticationError in

                   DispatchQueue.main.async {
                       if success {
                        let viewController = self!.storyboard?.instantiateViewController(withIdentifier: "SwipeVC") as! SwipeNavigationController
                            viewController.modalPresentationStyle = .fullScreen
                        self!.present(viewController, animated: true, completion: nil)
                       } else {
                           print("LOCKED")
                       }
                   }
               }
           } else {
               // no biometry
           }
    }

}

func codeSaved(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}
