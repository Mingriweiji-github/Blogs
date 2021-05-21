//
//  main.swift
//  wii
//
//  Created by jichunwei on 2020/12/15.
//  Copyright © 2020 Longfor. All rights reserved.
//

import Foundation
import UIKit

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(CustomApplication.self), NSStringFromClass(AppDelegate.self))

class CustomApplication: UIApplication {
    override func sendEvent(_ event: UIEvent) {
        // 在这里处理一些统一的逻辑
        super.sendEvent(event)
    }
    
    override func sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool {
        // 在这里处理一些统一的逻辑， 例如 记录行为日志
        return super.sendAction(action, to: target, from: sender, for: event)
    }
    
    override init() {
        super.init()
        
        MALauncherManager.start(withAppkey: Config.shared.apmKey!)
        let apmConfig = MAAPMConfig.init(appKey: Config.shared.apmKey!)
        apmConfig.debug = !Env.shared.isProduction
        MAAPMService.start(with: apmConfig)
    }
}
