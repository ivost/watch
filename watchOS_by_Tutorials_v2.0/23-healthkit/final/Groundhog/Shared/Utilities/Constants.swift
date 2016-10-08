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

let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  
  formatter.dateStyle = .short
  formatter.timeStyle = .short
  
  formatter.doesRelativeDateFormatting = true
  
  return formatter
} ()

let dateOnlyFormatter: DateFormatter = {
  let formatter = DateFormatter()
  
  formatter.dateStyle = .short
  formatter.timeStyle = .none
  
  formatter.doesRelativeDateFormatting = true
  
  return formatter
} ()


let timeOnlyFormatter: DateFormatter = {
  let formatter = DateFormatter()
  
  formatter.dateStyle = .none
  formatter.timeStyle = .short
  
  formatter.doesRelativeDateFormatting = true
  
  return formatter
} ()


let elapsedTimeFormatter: DateComponentsFormatter = {
  let formatter = DateComponentsFormatter()
  
  formatter.unitsStyle = .abbreviated
  formatter.collapsesLargestUnit = true
  
  return formatter
} ()

let dateIntervalFormatter: DateIntervalFormatter = {
  let formatter = DateIntervalFormatter()
  
  formatter.timeStyle = .short
  
  return formatter
} ()

let numberFormatter = NumberFormatter()

let calorieFormatter: EnergyFormatter = {
  let formatter = EnergyFormatter()

  formatter.isForFoodEnergyUse = true
  formatter.numberFormatter = numberFormatter
  
  return formatter
} ()

let distanceFormatter = LengthFormatter()

