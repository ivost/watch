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

struct CardGraphGeneratorSettings: GraphGeneratorSettings {
  
  // elements
  var drawBackgroundGradient: Bool = true
  var drawUnderGraphGradient: Bool = true
  var drawGridlines: Bool = true
  var drawPoints: Bool = true
  
  // colors
  var graphLineColor: UIColor = UIColor.white
  var gridlineMajorColor: UIColor = UIColor.white.withAlphaComponent(0.3)
  var gridlineMinorColor: UIColor = UIColor.white.withAlphaComponent(0.11)
  var underGraphGradientTopColor: CGColor = UIColor.white.withAlphaComponent(0.6).cgColor
  var underGraphGradientBottomColor: CGColor = UIColor.clear.cgColor
  var backgroundGradientTopColor: CGColor = UIColor.black.cgColor
  var backgroundGradientBottomColor: CGColor = UIColor.black.cgColor
  
  // corners
  var backgroundGradientCornerRadius: Int = 0
  
  // line width
  var gridlineWidth: CGFloat = 1
  var graphLineWidth: CGFloat = 2
  var pointSize: CGFloat = 5
  
  // insets
  var gridlineHorizontalInsets: CGFloat = 15
  var graphHorizontalInsets: CGFloat = 65
  var topInset: CGFloat = 60
  var bottomInset:CGFloat = 20
  
}
