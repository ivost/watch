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
import Foundation

class InterfaceController: WKInterfaceController {
  
  @IBOutlet var graphImage: WKInterfaceImage!
  
  override func awake(withContext context: Any?) {
  }
  
  override func willActivate() {
    super.willActivate()
    
    generateImage()
  }
  
  // Preparing data
  
  func stringFromHighlightedIndex() -> String {
    return String()
  }
  
  func preparedData() -> [Census] {
    
    let minRange = censuses.count - measurementsPerDay
    
    let maxRange = censuses.count
    
    let data = Array(censuses[minRange..<maxRange])
    
    return data
  }
  
  func preparedDemarcations() -> [GraphDemarcation] {
    let censusesAroundMidnight = preparedData().enumerated().filter() {
      index, element in
      let date = element.timestamp
      let maxDate = date.roundedToMidnight().adding(minutes: measurementIntervalMinutes / 2)
      let minDate = date.roundedToMidnight().adding(minutes: -measurementIntervalMinutes / 2)
      return date >= minDate && date <= maxDate
    }
    let demarcations: [GraphDemarcation] = censusesAroundMidnight.map() {
        index, element in
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return GraphDemarcation(title: formatter.string(from: element.timestamp), index: index)
    }
    return demarcations
  }
  
  func generateImage() {
    
    // Avoid drawing the graph when there's no data
    guard !preparedData().isEmpty else {
      return
    }
    
    DispatchQueue.global(qos: .background).async {
      
      let graphGenerator = GraphGenerator(settings: WatchGraphGeneratorSettings())
      
      let data = self.preparedData().map{Double($0.attendance)}
      
      let demarcations = self.preparedDemarcations()
      
      let image = graphGenerator.image(self.contentFrame.size, with: data, demarcations: demarcations)
      
      DispatchQueue.main.async {
        self.graphImage.setImage(image)
      }
    }
  }
  
  // Handling interactions
  
  func handleInteraction(_ delta: Double) {
  }
}
