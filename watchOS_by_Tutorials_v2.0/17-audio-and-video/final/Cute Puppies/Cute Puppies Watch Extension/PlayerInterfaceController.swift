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

import Foundation
import WatchKit

class PlayerInterfaceController: WKInterfaceController {
  
  @IBOutlet private var inlineMovie: WKInterfaceInlineMovie!
  @IBOutlet private var textLabel: WKInterfaceLabel!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    let index = context as! Int
    
    let provider = VideoClipProvider()
    let clipURL = provider.clips[index]
    let quote = provider.quotes[index]
    inlineMovie.setMovieURL(clipURL)
    textLabel.setText(quote)
    setTitle(clipURL.lastPathComponent)
    
    if let data = PosterImageProvider().imageDataForClip(withURL: clipURL) {
      let image = WKImage(imageData: data)
      inlineMovie.setPosterImage(image)
    }
  }
  
  private var isPlaying: Bool = true
  
  @IBAction func onTap(_ sender: AnyObject) {
    if isPlaying {
      inlineMovie.pause()
      isPlaying = false
    } else {
      inlineMovie.play()
      isPlaying = true
    }
  }
}
