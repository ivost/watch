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

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var answerCollection: UICollectionView!
  fileprivate let reuseIdentifier = "answerCell"
  
  let data = BabelData()
  var questionType: QuestionType = .number
  var questionNumber = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    showQuestion()
  }
  
  func showQuestion() {
    if let questionType = QuestionType(rawValue: QuestionType.count.random()) {
      self.questionType = questionType
      switch questionType {
      case .number: pickQuestion(from: data.numberQuestions)
      case .color: pickQuestion(from: data.colorQuestions)
      case .emoji: pickQuestion(from: data.emojiQuestions)
      }
      answerCollection.reloadData()
    }
  }
  
  func pickQuestion(from questions: [String]) {
    questionNumber = questions.count.random()
    questionLabel.text = questions[questionNumber]
  }
  
}

extension ViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch questionType {
    // exclude non-answer from count
    case .number: return data.numberAnswers.count - 1
    case .color: return data.colorAnswers.count - 1
    case .emoji: return data.emojiAnswers.count - 1
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: reuseIdentifier, for: indexPath) as! AnswerCell
    // exclude non-answer from collection view
    let row = indexPath.row + 1
    
    switch questionType {
    case .number:
      cell.label.text = data.numberAnswers[row]
      cell.label.font = UIFont(name: ".SF UI Text", size: 28)
      cell.image.image = nil
    case .color:
      cell.image.image = UIImage(named: data.colorAnswers[row])
    case .emoji:
      cell.label.text = data.emojiAnswers[row]
      cell.label.font = UIFont(name: ".SF UI Text", size: 36)
      cell.image.image = nil
    }
    return cell
  }
  
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let row = indexPath.row
    let nextQuestionAction = UIAlertAction(title: "OK", style: .default) { action in
      self.showQuestion()
    }
    
    if row == questionNumber {
      let alert = UIAlertController(title: "Correct!", message: "New question?", preferredStyle: .alert)
      alert.addAction(nextQuestionAction)
      present(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertController(title: "Not quite...", message: "Please try again", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default) { action in })
      present(alert, animated: true, completion: nil)
    }
  }
  
}
