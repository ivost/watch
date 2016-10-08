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

import Foundation
import UIKit

extension Int {
  func random() -> Int {
    return Int(arc4random_uniform(UInt32(self)))
  }
}

enum QuestionType: Int {
  case number, color, emoji
  static var count: Int { return 3 }
}

struct BabelData {
  let numberQuestions = ["uno\nएक\neins\n一", "dos\nदो\nzwei\n二", "tres\nतीन\ndrei\n三", "cuatro\nचार\nvier\n四", "cinco\nपंज\nfünf\n五", "seis\nछक्का\nsechs\n六"]
  let colorQuestions = ["rojo\nलाल\nrot\n红", "azul\nनीला\nblau\n蓝", "verde\nग्रीन\ngrün\n绿", "marrón\nभूरा\nbraun\n褐", "amarillo\nपीला\ngelb\n黄", "gris\nधूसर\ngrau\n灰"]
  let emojiQuestions = ["manzana\nसेब\nApfel\n苹果", "libro\nकिताब\nBuch\n书", "rana\nमेढक\nFrosch\n青蛙", "caballo\nघोड़ा\nPferd\n马", "sol\nसूरज\nSonne\n太阳", "ratón\nमाउस\nMaus\n鼠"]
  
  let numberAnswers = ["?", "1", "2", "3", "4", "5", "6"]
  let emojiAnswers = ["?", "🍎", "📘", "🐸", "🐴", "🌞", "🐭"]
  let colorAnswers = ["neutral", "red", "blue", "green", "brown", "yellow", "gray"]
}
