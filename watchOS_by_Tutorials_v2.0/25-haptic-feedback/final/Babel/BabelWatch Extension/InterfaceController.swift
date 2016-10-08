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
  
  @IBOutlet var questionLabel: WKInterfaceLabel!
  @IBOutlet var answerPicker: WKInterfacePicker!
  
  let data = BabelData()
  var questionNumber = 0
  var answerValue = 0
  
  lazy var numberItems: [WKPickerItem] = self.pickerItems(with: .number)
  lazy var emojiItems: [WKPickerItem] = self.pickerItems(with: .emoji)
  lazy var colorItems: [WKPickerItem] = self.pickerItems(with: .color)
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    showQuestion()
  }
  
  override func didAppear() {
    answerPicker.setSelectedItemIndex(0)
    answerPicker.focus()
  }

  @IBAction func pickerValueChanged(_ value: Int) {
    answerValue = value
  }
  
  override func pickerDidSettle(_ picker: WKInterfacePicker) {
    guard answerValue > 0 else {
      return
    }
    checkAnswer()
  }
  
  @IBAction func checkAnswer() {
    // 1
    let okAction = WKAlertAction(title: "OK", style: .default) { () in }
    // 2
    if answerValue == questionNumber + 1 {
      // 3
      WKInterfaceDevice.current().play(.success)
      presentAlert(withTitle: "Correct!",
        message: "New question...", preferredStyle: .alert,
        actions: [okAction])
      showQuestion()
    } else {
      // 4
      WKInterfaceDevice.current().play(.retry)
      presentAlert(withTitle: "Sorry!",
        message: "Try again", preferredStyle: .alert,
        actions: [okAction])
    }
  }
  
  func showQuestion() {
    if let questionType = QuestionType(rawValue: QuestionType.count.random()) {
      switch questionType {
      case .number:
        pickQuestion(from: data.numberQuestions)
        answerPicker.setItems(numberItems)
      case .color:
        pickQuestion(from: data.colorQuestions)
        answerPicker.setItems(colorItems)
      case .emoji:
        pickQuestion(from: data.emojiQuestions)
        answerPicker.setItems(emojiItems)
      }
    }
  }
  
  func pickQuestion(from questions: [String]) {
    questionNumber = questions.count.random()
    questionLabel.setText(questions[questionNumber])
  }
  
  func pickerItems(with questionType: QuestionType) -> [WKPickerItem] {
    switch questionType {
    case .number:
      return pickerItems(fromTitles: data.numberAnswers)
    case .emoji:
      return pickerItems(fromTitles: data.emojiAnswers)
    case .color:
      return pickerItems(fromImageNames: data.colorAnswers)
    }
  }
  
  private func pickerItems(fromTitles titles: [String]) -> [WKPickerItem] {
    let items = titles.map {(title: String) -> WKPickerItem in
      let pickerItem = WKPickerItem()
      pickerItem.title = title
      return pickerItem
    }
    return items
  }
  
  private func pickerItems(fromImageNames imageNames: [String]) -> [WKPickerItem] {
    let items = imageNames.map {(name: String) -> WKPickerItem in
      let pickerItem = WKPickerItem()
      pickerItem.contentImage = WKImage(imageName: name)
      return pickerItem
    }
    return items
  }
}
