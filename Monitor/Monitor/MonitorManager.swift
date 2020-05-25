//
//  MonitorManager.swift
//  Monitor
//
//  Created by Mac123 on 2020/3/27.
//  Copyright © 2020 OC. All rights reserved.
//

import UIKit

class MonitorManager: NSObject {
    var semaphore: DispatchSemaphore?
    var observer: CFRunLoopObserver?
    var RunLoopActivity: CFRunLoopActivity?
    var start: Bool?
    
    
    static let manager: MonitorManager = {
        let instance = MonitorManager()
        return instance
    }()
    
    func startMonitor() {
        if self.observer == nil {
            self.start = true
            self.semaphore = DispatchSemaphore.init(value: 1)
            //启动一条子线程来监听卡顿
            Thread.detachNewThreadSelector(#selector(subThread), toTarget: self, with: nil)
                        
            //创建观察者
            var context = CFRunLoopObserverContext.init(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            self.observer = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0, {(observer, activity, pointer) in
                //RunLoop状态改变的回调
//                if activity == .entry {
//                    print("entry")
//                }else if activity == .beforeTimers {
//                    print("beforeTimers")
//                }else if activity == .beforeSources {
//                    print("beforeSources")
//                }else if activity == .beforeWaiting {
//                    print("beforeWaiting")
//                }else if activity == .afterWaiting {
//                    print("afterWaiting")
//                }else if activity == .exit {
//                    print("exit")
//                }
                MonitorManager.manager.RunLoopActivity = activity
                MonitorManager.manager.semaphore?.signal()
            }, &context)
            //将观察者添加在主线程RunLoop的commonModes模式下面
            CFRunLoopAddObserver(CFRunLoopGetMain(), self.observer, CFRunLoopMode.commonModes)
        }
    }
    
    func stopMonitor() {
        if self.observer != nil {
            self.start = false
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observer!, CFRunLoopMode.commonModes)
            self.observer = nil
        }
    }
    
    @objc func subThread() {
        while self.start! {
            //这里设置的阈值为500毫秒。阈值不宜设置的太小，太小会检测到一些用户无感的卡顿。也不宜设置的太大，太大了也会错过一些明显的卡顿
            let wait = self.semaphore?.wait(timeout: .now() + 0.5)
            if wait == DispatchTimeoutResult.timedOut {
                if self.observer != nil {
                    if (self.RunLoopActivity == CFRunLoopActivity.beforeSources || self.RunLoopActivity == CFRunLoopActivity.afterWaiting) && self.start == true {
                        /*
                         这里检测到卡顿，可以打印堆栈信息查看是在调用哪些方法的时候导致了卡顿。也可以利用PLCrashReporter这个第三方库来协助我们打印堆栈信息。我们需要把堆栈信息发送到服务器以便分析问题
                         */
                        print("卡顿了")
                    }
                }
            }
        }
        print("子线程销毁了")
    }
    
}
