/**
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

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder {

  var window: UIWindow?
  
  /// The WatchConnectivity session to send poster images if needed.
  fileprivate var session: WCSession?
  
  /// A reference map to create poster images for each video clip and
  /// send them to the watch app.
  fileprivate let references = VideoClipProvider().clipReferences
}

extension AppDelegate: UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    if WCSession.isSupported() {
      session = WCSession.default()
      session!.delegate = self
      session!.activate()
    }
    return true
  }
}

extension AppDelegate: WCSessionDelegate {
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("📱 WCSession activationDidCompleteWith: \(activationState.rawValue)")
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    print("📱 WCSession sessionDidBecomeInactive.")
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    print("📱 WCSession sessionDidDeactivate.")
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    
    print("📱 WCSession received message: \(message)")
    
    guard let value = message[VideoClipProvider.WCPosterImageRequestKey] as? String else {
      print("📱 WCSession message not handled.")
      return
    }
    
    guard let URL = references[value] else {
      print("📱 WCSession message not handled.")
      return
    }
    
    guard let directory = session.watchDirectoryURL else {
      print("📱 WCSession failed to get watch directory URL.")
      return
    }
    
    let newSize = CGSize(width: 312.0, height: 234.0)
    let file = directory.appendingPathComponent(value)
    
    VideoUtilities.snapshot(fromMovieAtURL: URL, resizeTo: newSize) { (image) in
      print("📱 WCSession sending image \(image) at \(file).")
      let data = UIImagePNGRepresentation(image)!
      try! data.write(to: file)
      session.transferFile(file, metadata: [VideoClipProvider.WCPosterImageRequestKey: value])
    }
  }
  
  func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
    print("📱 WCSession didFinish fileTransfer \(fileTransfer) - \(error)")
  }
}

