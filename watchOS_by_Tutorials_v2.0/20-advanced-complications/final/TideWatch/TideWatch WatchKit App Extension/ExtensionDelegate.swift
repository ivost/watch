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

let WatchUpdatedDataNotification = "WatchUpdatedDataNotification"
let PhoneUpdatedDataNotification = "PhoneUpdatedDataNotification"

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
  
  func applicationDidFinishLaunching() {
    setupWatchConnectivity()
    setupNotificationCenter()
  }

  func handleUserActivity(_ userInfo: [AnyHashable : Any]?) {
    if let date = userInfo?[CLKLaunchedTimelineEntryDateKey] as? Date {
      print("Launched from complication wnith date:\(date)")
    }
  }
  
  // MARK: - Notification Center
  private func setupNotificationCenter() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: WatchUpdatedDataNotification), object: nil, queue: nil) { notification in
      self.sendUpdatedDataToPhone(notification)
    }
  }
  
  
  private func sendUpdatedDataToPhone(_ notification: Notification) {
    if WCSession.isSupported() {
      let session = WCSession.default()
      if let object = notification.object as? TideConditions {
        do {
          let data = NSKeyedArchiver.archivedData(withRootObject: object)
          let dictonary = ["data": data]
          try session.updateApplicationContext(dictonary)
        } catch {
          print("ERROR: \(error)")
        }
      }
    }
  }
  
  // MARK: - Watch Connectivity
  private func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session = WCSession.default()
      session.delegate = self
      session.activate()
    }
  }

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    if let data = applicationContext["data"] as? Data {
      if let tideConditions = NSKeyedUnarchiver.unarchiveObject(with: data) as? TideConditions {
        conditionsUpdated(tideConditions)
      }
    }
  }

  func session(_ session: WCSession,
    didReceiveUserInfo userInfo: [String : Any]) {
    if let data = userInfo["data"] as? Data {
      if let tideConditions =
        NSKeyedUnarchiver.unarchiveObject(with: data) as?
        TideConditions {
        conditionsUpdated(tideConditions)
      }
    }
  }

  func conditionsUpdated(_ tideConditions:TideConditions) {
    TideConditions.saveConditions(tideConditions)
    DispatchQueue.main.async {
      let notificationCenter = NotificationCenter.default
      notificationCenter.post(name: Notification.Name(rawValue: PhoneUpdatedDataNotification), object: tideConditions)
      self.updateComplicationData()
    }
  }

  func updateComplicationData() {
    let complicationsController = ComplicationController()
    complicationsController.reloadOrExtendData()
  }
}
