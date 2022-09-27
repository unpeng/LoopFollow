//
//  RemoteOverrideViewController.swift
//  LoopFollow
//
//  Created by 王鹏 on 2022/9/26.
//  Copyright © 2022 Jon Fawcett. All rights reserved.
//

import Foundation
import Eureka
import EventKit
import EventKitUI
import LocalAuthentication


class RemoteOverrideViewController: FormViewController {

    var authenticate: AuthenticationChallenge = LocalAuthentication.deviceOwnerCheck
    
    var appStateController: AppStateController?
   
   override func viewDidLoad()  {
      super.viewDidLoad()
      if UserDefaultsRepository.forceDarkMode.value {
         overrideUserInterfaceStyle = .dark
      }
       form

       +++ Section("远程覆盖指令")
           <<< SegmentedRow<String>("func") { row in
               row.options = ["远程覆盖", "取消覆盖"]
               row.value = "远程覆盖"
           }.onChange { row in
               guard row.value != nil else { return }
           }
       
       +++ Section() {
           $0.hidden = "$func = '取消覆盖'"
       }
           <<< ActionSheetRow<String>("overridePresets") { row in
               row.title = "覆盖计划"
               row.selectorTitle = "请选择覆盖的计划"
               row.options = UserDefaultsRepository.overridePresets.value
           }.onChange { row in
               guard row.value != nil else { return }
           }
        
           <<< StepperRow("duration") { row in
               row.title = "持续时长（分钟）"
               row.cell.stepper.stepValue = 5
               row.cell.stepper.minimumValue = 5
               row.cell.stepper.maximumValue = 300
               row.cell.valueLabel.textColor = .red
               row.value = 5
           }.onChange { row in
               guard row.value != nil else { return }
           }

           <<< ButtonRow() { row in
               row.title = "临时覆盖"
           }.onCellSelection { (row, arg)  in
               
               if self.form.validate().count > 0 { return }
               
               let overrideRow: ActionSheetRow<String>? = self.form.rowBy(tag: "overridePresets")
               
               let override = overrideRow?.value
               
               guard override != nil else { return }
               
               let overrideString = String(override!)

               let durationRow: StepperRow? = self.form.rowBy(tag: "duration")
               let duration = durationRow?.value
               let durationString = String(duration!)
               
               let overrideParameters: [String: String] = [
                    "enteredBy": "pandy",
                    "eventType": "Temporary Override",
                    "reason": overrideString,
                    "reasonDisplay": overrideString,
                    "duration": durationString
               ]
               
               var message: String = "请验证输入的数据是否正确： \r\n"
               message += "覆盖计划：" + overrideString + " \r\n"
               message += "覆盖时长：" + durationString + "分钟 \r\n"
               
               let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
               
               /// 确认
               let sureAction = UIAlertAction(title: "确认", style: UIAlertAction.Style.default) {(_) in

                   doEntry(parameters: overrideParameters, app: self.appStateController)
                   
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
       +++ Section() {
           $0.hidden = "$func = '远程覆盖'"
       }
           <<< ButtonRow() { row in
              row.title = "取消当前临时覆盖"
           }.onCellSelection { (row, arg)  in
               
               let overrideParameters: [String: String] = [
                    "enteredBy": "pandy",
                    "eventType": "Temporary Override Cancel"
               ]
               
               var message: String = "请确认是否取消当前临时覆盖？"
               
               let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
               
               /// 确认
               let sureAction = UIAlertAction(title: "确认", style: UIAlertAction.Style.default) {(_) in

                   
                doEntry(parameters: overrideParameters, app: self.appStateController)
                   
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
       
       +++ ButtonRow() { row in
          row.title = "取消"
       }.onCellSelection { (row, arg)  in
           self.dismiss(animated:true, completion: nil)
       }
   }
}


