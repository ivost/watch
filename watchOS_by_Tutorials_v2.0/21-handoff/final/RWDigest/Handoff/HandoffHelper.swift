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

struct Version {
  let key: String
  let number: Int
}

struct Handoff {
  
  /// The registered user activity types in the application's Info.plist.
  enum ActivityType: String {
    
    /// Viewing news page.
    case viewNews   = "com.razeware.rwdigest.news"
    
    /// Reading a story.
    case readStory  = "com.razeware.rwdigest.story"
  }
  
  /// Key to an associated value for an activity type in userInfo.
  /// For .ViewNews, the value of this key is empty string.
  /// For .ViewTopics, the value is the title of the Topic.
  /// For .ReadStory, the value is storyID of the story.
  let activityValueKey = "activityValue"
  
  /// Current version of Handoff. It indicates the assumed structure of Handoff and it's userInfo structure.
  let version = Version(key: "version", number: 1)
}
