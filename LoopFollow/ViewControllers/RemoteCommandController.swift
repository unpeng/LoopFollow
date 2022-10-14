//
//  RemoteCommandController.swift
//  LoopFollow
//
//  Created by peng on 2022/9/25.
//  Copyright © 2022 Jon Fawcett. All rights reserved.
//

import UIKit
import Eureka
import EventKit
import EventKitUI

class RemoteCommandController: FormViewController {
    
    var appStateController: AppStateController?

    override func viewDidLoad() {
         super.viewDidLoad()
         if UserDefaultsRepository.forceDarkMode.value {
             overrideUserInterfaceStyle = .dark
         }
        
        if let main = tabBarController!.viewControllers?[0] as? MainViewController {
            appStateController?.delegateFunc = main.startTreatmentsTimer
        }
        
        form
        +++ Section("Loop 远程指令")
        <<< ButtonRow() {
            $0.title = "远程输注"
            $0.presentationMode = .show(
                controllerProvider: .callback(builder: {
                   let controller = BolusEntryViewController()
                   controller.appStateController = self.appStateController
                   return controller
                }
            ), onDismiss: nil)
         }
        
        <<< ButtonRow() {
            $0.title = "远程覆盖"
            $0.presentationMode = .show(
                controllerProvider: .callback(builder: {
                   let controller = RemoteOverrideViewController()
                   controller.appStateController = self.appStateController
                   return controller
                }
            ), onDismiss: nil)
         }

        <<< ButtonRow() {
            $0.title = "剂量策略"
            $0.presentationMode = .show(
                controllerProvider: .callback(builder: {
                   let controller = AutomaticDosingStrategyViewController()
                   controller.appStateController = self.appStateController
                   return controller
                }
            ), onDismiss: nil)
         }
        
        +++ Section(header: "v1.3.1", footer: "Important Disclaimer \n\rYou take full responsiblility for running this system and do so at your own risk.")
    }
    
}
