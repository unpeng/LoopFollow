//
//  AutomaticDosingStrategyViewController.swift
//  LoopFollow
//
//  Created by 王鹏 on 2022/10/12.
//  Copyright © 2022 Jon Fawcett. All rights reserved.
//

import Foundation
import Eureka
import EventKit
import EventKitUI
import LocalAuthentication

class AutomaticDosingStrategyViewController: FormViewController {
    
    var appStateController: AppStateController?
    override func viewDidLoad()  {
        super.viewDidLoad()
        if UserDefaultsRepository.forceDarkMode.value {
            overrideUserInterfaceStyle = .dark
        }
        form

        +++ Section("远程剂量策略")
            <<< ActionSheetRow<String>("strategy") { row in
                row.title = "请选择调整后的策略"
                row.selectorTitle = "请选择变更的策略"
                row.options = ["仅基础率","自动推注"]
            }.onChange { row in
                guard row.value != nil else { return }
            }
        
        <<< ButtonRow() { row in
            row.title = "确定"
        }.onCellSelection { (row, arg)  in
            
            if self.form.validate().count > 0 { return }
            
            let strategyRow: ActionSheetRow<String>? = self.form.rowBy(tag: "strategy")
            
            let strategy = strategyRow?.value
            
            guard strategy != nil else { return }
            
            let strategyString = String(strategy!)
            
            let strategyParameters: [String: String] = [
                "enteredBy": "pandy",
                "eventType": "Remote Bolus Entry",
                "remoteBolus": "0.1",
                "units": "mmol",
                "notes": strategyString == "自动推注" ? "automaticBolus" : "tempBasalOnly"
            ]
            
            var message: String = "请确认变更的策略是否正确： \r\n"
            message += "推注策略：" + strategyString + " \r\n"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            
            /// 确认
            let sureAction = UIAlertAction(title: "确认", style: UIAlertAction.Style.default) {(_) in

                doEntry(parameters: strategyParameters, app: self.appStateController)
                
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
