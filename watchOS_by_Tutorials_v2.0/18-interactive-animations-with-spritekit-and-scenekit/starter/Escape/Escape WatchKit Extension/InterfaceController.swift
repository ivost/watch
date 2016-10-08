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

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
  
  @IBOutlet var skInterface: WKInterfaceSKScene!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    // Configure interface objects here.
    
    // Load the SKScene from 'GameScene.sks'
    if let scene = GameScene(fileNamed: "GameScene") {
      
      // Set the scale mode to scale to fit the window
      scene.scaleMode = .aspectFill
      
      // Present the scene
      self.skInterface.presentScene(scene)
      
      // Use a value that will maintain a consistent frame rate
      self.skInterface.preferredFramesPerSecond = 30
    }
  }
  
  @IBAction func tapRecognized(_ sender: AnyObject) {
  }
  
  @IBAction func gestureRecognized(_ sender: AnyObject) {
  }
}
