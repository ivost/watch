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


@IBDesignable class PageInterfaceController: WKInterfaceController {
  
  var stock: Stock!
  
  var graphHeightRatio: CGFloat = 0.875 // default also set in interface builder
  var detailsHeightRatio: CGFloat = 0.125 // default also set in interface builder
  
  var screenSize: CGSize {
    return self.contentFrame.size // for convenience
  }
  
  @IBOutlet var graphImage: WKInterfaceImage!
  @IBOutlet var detailsGroup: WKInterfaceGroup!
  @IBOutlet var changeLabel: WKInterfaceLabel!
  @IBOutlet var tickerSymbolLabel: WKInterfaceLabel!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    if let context = context as? Stock {
      self.stock = context
    }
    
  }
  
  override func willActivate() {
    super.willActivate()
    
    updateForAccessibility()
    
    changeLabel.setText("\(stock.changeCharacter) \(stock.changePercentAsString)")
    
    changeLabel.setTextColor(stock.changeColor)
    
    tickerSymbolLabel.setText(stock.tickerSymbol)
    
    generateImage()
  }
  
  func generateImage() {
	DispatchQueue.global(qos: .default).async {
    
      let graphGenerator = GraphGenerator(settings: WatchGraphGeneratorSettings())
      
      let height = self.graphHeightRatio * self.screenSize.height
      
      let graphRect = CGRect(x: 0, y: 0, width: self.screenSize.width, height: height)
      
      let image = graphGenerator.image(graphRect, with: self.stock.last5days)
      
      DispatchQueue.main.async {
        self.graphImage.setImage(image)
      }
    }
  }
  
  func updateForAccessibility() {
    if WKAccessibilityIsVoiceOverRunning() {
      makeLayoutAccessible()
      makeGraphAccessible()
      makeGroupAccessible()
    }
  }
  
  func makeLayoutAccessible() {
    graphHeightRatio = 0.6
    detailsHeightRatio = 0.4
    
    graphImage.setHeight(graphHeightRatio * screenSize.height)
    detailsGroup.setHeight(detailsHeightRatio * screenSize.height)
  }
  
  func makeGraphAccessible() {
    // 1
    var imageRegions = [WKAccessibilityImageRegion]()
    // 2
    for index in 0..<stock.last5days.count {
      // 3
      if index == 0 { continue } // skip the first day
      // 4
      let imageRegion = WKAccessibilityImageRegion()
      // 5
      imageRegion.frame = imageRegionFrameForTrailingIndex(index)
      // 6
      imageRegion.label = summaryForTrailingIndex(index)
      // 7
      imageRegions.append(imageRegion)
    }
    // 8
    graphImage.setAccessibilityImageRegions(imageRegions)
  }
  
  func makeGroupAccessible(){
    // 1
    detailsGroup.setIsAccessibilityElement(true)
    // 2
    let percentage = changePercentageForVoiceOver(
      stock.last5days.first!, current: stock.last5days.last!)
    // 3
    let label =
    "\(stock.companyName), past five days, \(percentage)"
    // 4
    detailsGroup.setAccessibilityLabel(label)
    // 5
    detailsGroup.setAccessibilityTraits(
      UIAccessibilityTraitSummaryElement)
  }
  
  func imageRegionFrameForTrailingIndex(_ trailingIndex: Int) -> CGRect {
    let height = screenSize.height * graphHeightRatio
    let width =
      screenSize.width / CGFloat(stock.last5days.count - 1)
    let x = width * (CGFloat(trailingIndex) - 1)
    return CGRect(x: x, y: 0, width: width, height: height)
  }
  
  func summaryForTrailingIndex(_ trailingIndex: Int) -> String {
    // 1
    let percentageDescription = changePercentageForVoiceOver(
      stock.last5days[trailingIndex - 1],
      current: stock.last5days[trailingIndex])
    // 2
    var timeDescription = String()
    switch trailingIndex {
    case 1:
      timeDescription = "3 days ago"
    case 2:
      timeDescription = "day before yesterday"
    case 3:
      timeDescription = "yesterday"
    case 4:
      timeDescription = "today"
    default:
      break
    }
    // 3
    return "\(percentageDescription) \(timeDescription)"
  }
  
  func changePercentageForVoiceOver(_ previous: Double, current: Double) -> String {
    // 1
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .percent
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    // 2
    let change = (current - previous) / previous
    // 3
    let direction = change > 0 ? "up" : "down"
    // 4
    let percent = numberFormatter.string(from: NSNumber(value: abs(change)))!
    // 5
    return "\(direction) \(percent)"
  }
  
}
