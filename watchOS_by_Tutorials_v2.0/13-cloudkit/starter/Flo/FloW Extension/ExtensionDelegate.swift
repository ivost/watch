/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import WatchKit
import WatchConnectivity

let NotificationDrinkDateOnWatch = "DrinkDateOnWatch"

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  
  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
  }()
  
  func applicationDidFinishLaunching() {
    setupWatchConnectivity()
    setupNotificationCenter()
  }
  
  func handleUserActivity(_ userInfo: [AnyHashable : Any]?) {
    if let date = userInfo?[CLKLaunchedTimelineEntryDateKey]
      as? Date {
      print("launched from complication with date: \(date)")
    }
  }
  
  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
    // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
    for task in backgroundTasks {
      // Use a switch statement to check the task type
      switch task {
      case let backgroundTask as WKApplicationRefreshBackgroundTask:
        // Be sure to complete the background task once you’re done.
        backgroundTask.setTaskCompleted()
      case let snapshotTask as WKSnapshotRefreshBackgroundTask:
        // Snapshot tasks have a unique completion call, make sure to set your expiration date
        snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
      case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
        // Be sure to complete the connectivity task once you’re done.
        connectivityTask.setTaskCompleted()
      case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
        // Be sure to complete the URL session task once you’re done.
        urlSessionTask.setTaskCompleted()
      default:
        // make sure to complete unhandled task types
        task.setTaskCompleted()
      }
    }
  }
  
  // MARK: - Notification Center
  private func setupNotificationCenter() {
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationDrinkDateOnWatch), object: nil, queue: nil) { (notification:Notification) -> Void in
      self.sendDrinkDateToPhone(notification)
    }
  }
  
}

extension ExtensionDelegate: WCSessionDelegate {
  
  func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session  = WCSession.default()
      session.delegate = self
      session.activate()
    }
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    let floData = FloData.sharedInstance()
    if let date = applicationContext[LocalCache.startDate.rawValue] as? Date {
      floData.startDate = date
    UserDefaults.standard.set(floData.startDate, forKey: LocalCache.startDate.rawValue)
    }
    if let count = applicationContext[LocalCache.drinkTotal.rawValue] as? Int {
      floData.drinkTotal = count
      UserDefaults.standard.set(floData.drinkTotal, forKey: LocalCache.drinkTotal.rawValue)
    }
    print(">>> didReceiveApplicationContext \(floData.drinkTotal) drinks")
//    DispatchQueue.main.async(execute: {
//      WKInterfaceController.reloadRootControllers(
//        withNames: ["FloInterfaceController"], contexts: nil)
//    })
    DispatchQueue.main.async() {
      WKInterfaceController.reloadRootControllers(
        withNames: ["FloInterfaceController"], contexts: nil)
    }
  }
  
  func sendDrinkDateToPhone(_ notification: Notification) {
    if WCSession.isSupported() {
      let floData = FloData.sharedInstance()
        do {
          let dictionary = ["watchDate": floData.lastDate]
          try WCSession.default().updateApplicationContext(dictionary)
        } catch {
          print(">>>>>>>>>> sendDrinkDate ERROR: \(error.localizedDescription)")
        }
    }
  }
  
  func session(_ session: WCSession, activationDidCompleteWith
    activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print(">>> WC Session activation failed with error: \(error.localizedDescription)")
      return
    }
    print(">>> WC Session activated with state: \(activationState.rawValue)")
  }
  
}
