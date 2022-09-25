//
//  BolusEntryViewController.swift
//  LoopFollow
//
//  Created by peng on 2022/9/25.
//  Copyright © 2022 Jon Fawcett. All rights reserved.
//

import Foundation
import Eureka
import EventKit
import EventKitUI
import LocalAuthentication


class BolusEntryViewController: FormViewController {

    var authenticate: AuthenticationChallenge = LocalAuthentication.deviceOwnerCheck
    
    var appStateController: AppStateController?
   
   override func viewDidLoad()  {
      super.viewDidLoad()
      if UserDefaultsRepository.forceDarkMode.value {
         overrideUserInterfaceStyle = .dark
      }
       form
           +++ Section("远程注入")
       
       <<< StepperRow("carbs") { row in
           
           row.title = "碳水化合物（g）"
           row.cell.stepper.stepValue = 1
           row.cell.stepper.minimumValue = 0
           row.cell.stepper.maximumValue = 50
           row.value = 0
       }.onChange { [weak self] row in
           guard row.value != nil else { return }
       }

       <<< StepperRow("absorption") { row in
           
           row.title = "吸收时长（h）"
           row.cell.stepper.stepValue = 0.5
           row.cell.stepper.minimumValue = 0.5
           row.cell.stepper.maximumValue = 5
           row.value = 2
           row.hidden = "$carbs < 1"
       }.onChange { [weak self] row in
           guard row.value != nil else { return }
       }
       
       <<< StepperRow("bolus") { row in
           
           row.title = "大剂量（U）"
           row.cell.stepper.stepValue = 0.1
           row.cell.stepper.minimumValue = 0
           row.cell.stepper.maximumValue = 6
           row.value = 0.0
       }.onChange { [weak self] row in
           guard row.value != nil else { return }
       }
       
       <<< TextRow("otp") { row in
           row.title = "OTP"
           row.placeholder = "输入密码"
       }
       .cellUpdate { cell, row in
          
       }
       
//       <<< TextRow("notes") { row in
//           row.title = "备注"
//           row.placeholder = "填写备注"
//       }
//       .cellUpdate { cell, row in
//
//       }

       +++ ButtonRow() { row in
          row.title = "注入"
       }.onCellSelection { (row, arg)  in
           
           let carbsRow: StepperRow? = self.form.rowBy(tag: "carbs")
           let carbs = carbsRow?.value
           let carbsString = String(carbs!)
           
           let absorptionRow: StepperRow? = self.form.rowBy(tag: "absorption")
           let absorption = absorptionRow?.value
           let absorptionString = String(format: "%.1f", absorption!)
           
           let bolusRow: StepperRow? = self.form.rowBy(tag: "bolus")
           let bolus = bolusRow?.value
           let bolusString = String(format: "%.2f", bolus!)
           
           let otpRow: TextRow? = self.form.rowBy(tag: "otp")
           let otp = otpRow?.value
           
           //let notesRow: TextRow? = self.form.rowBy(tag: "notes")
           //let notes = notesRow?.value
           
           
           let bolusParameters: [String: String] = [
                "enteredBy": "pandy",
                "eventType": "Remote Bolus Entry",
                "remoteBolus": bolusString,
                "units": "mmol",
                "opt": otp ?? "",
                "notes": carbsString + "|" + absorptionString
           ]
           
           let carbsParameters: [String: String] = [
                "enteredBy":"pandy",
                "eventType":"Remote Carbs Entry",
                "units": "mmol",
                "opt": otp ?? "",
                "remoteCarbs": carbsString,
                "remoteAbsorption": absorptionString
           ]
           
           var message: String = "请验证输入的数据是否正确： \r\n"
           
           if carbs! > 0 {
               message += "碳水化合物：" + carbsString + "g \r\n"
               message += "吸收时长：" + absorptionString + "h \r\n"
           }
           
           message += "大剂量：" + bolusString + "U \r\n"
           
           let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
           
           /// 确认
           let sureAction = UIAlertAction(title: "确认", style: UIAlertAction.Style.default) {(_) in

               if carbs! > 0 && bolus! <= 0 {
                   doEntry(parameters: carbsParameters, app: self.appStateController)
               }

               if bolus! > 0 {
                   doEntry(parameters: bolusParameters, app: self.appStateController)
               }
               self.dismiss(animated:true, completion: nil)
           }
           sureAction.setValue(UIColor.init(named: "#FF9E3E"), forKey: "_titleTextColor")
           alert.addAction(sureAction)
           
           //取消操作
           let cancleAction = UIAlertAction(title: "取 消", style: .cancel, handler: nil)
           cancleAction.setValue(UIColor.init(named: "#424242"), forKey: "_titleTextColor")
           alert.addAction(cancleAction)
           
           self.present(alert, animated: true, completion: nil)
           
       }
       
       <<< ButtonRow() { row in
          row.title = "取消"
       }.onCellSelection { (row, arg)  in
           self.dismiss(animated:true, completion: nil)
       }
   }
}


func doEntry(parameters: [String: Any], app: AppStateController?){
    
    let nsBaseUrl = UserDefaultsRepository.url.value
    
    let nsToken = UserDefaultsRepository.token.value
    
    if nsBaseUrl == "" || nsToken == "" { return }
    
    let urlRemotePath: String = nsBaseUrl + "/api/v2/notifications/loop"
    
    let url = URL(string: urlRemotePath)!
    
    var request = URLRequest(url: url)
    
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
    
    request.httpMethod = "POST"
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.addValue(nsToken.SHA1(), forHTTPHeaderField: "api-secret")
    
    request.httpBody = parameters.percentEncoded()
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                alertMessage(title: "失败", message: "Unknown error")
                return
        }

        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            print("response = \(response)")
            alertMessage(title: "失败", message: String(response.statusCode))
            return
            
        }
        
        let responseString = String(data: data, encoding: .utf8)
        
        print("responseString = \(String(describing: responseString))")
        
        DispatchQueue.main.async{
            
            UserDefaultsRepository.highRefreshRateTimes.value = 5
            
            app?.Execute(time: 0.1)
            
            alertMessage(title: "成功", message: "远程指令完成")
        }
    }

    task.resume()
}

func alertMessage(title: String, message: String){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "确定", style: .cancel))
    
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    
}
