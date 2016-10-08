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

enum WebServiceError: Error {
  case badResponse
  case noResponse
  case other
}


class WebService {
  let session: URLSession
  let rootURL: URL
  
  init (rootURL:URL) {
    self.rootURL = rootURL;
    
    let configuration = URLSessionConfiguration.default
    
    session = URLSession(configuration: configuration)
  }
  
  
  // MARK: - ****** Request Helpers ******
  
  internal func requestWithURLString(_ string: String) -> URLRequest? {
    if let url = URL(string: string, relativeTo: rootURL) {
      return URLRequest(url: url)
    }
    return nil
  }
  
  internal func executeDictionaryRequest(_ requestPath:String, completion: @escaping (_ dictionary:NSDictionary?, _ error: NSError?) -> Void) {
    
    print("Executing Request With Path: \(requestPath)")
    if let request = requestWithURLString(requestPath) {
      // Create the task
      let task = session.dataTask(with: request) { data, response, error in
        
        if error != nil {
          completion(nil, error as NSError?)
          return
        }
        
        // Check to see if there was an HTTP Error
        let cleanResponse = self.checkResponseForErrors(response)
        if let errorCode = cleanResponse.errorCode {
          print("An error occured: \(errorCode)")
          completion(nil, error as NSError?)
          return
        }
        
        // Make sure you got a dictionary back after parsing
        guard let dataDictionary = self.jsonDictionary(withData: data!) , dataDictionary.count > 0 else {
          print("Parsing Issues")
          completion(nil, error as NSError?)
          return
        }
        
        // Things went well, call the completion handler
        completion(dataDictionary, error as NSError?)
      }
      task.resume()
      
    } else {
      // It was a bad URL, so just fire an error
      let error = NSError(domain:NSURLErrorDomain,
                          code:NSURLErrorBadURL,
                          userInfo:[ NSLocalizedDescriptionKey : "There was a problem creating the request URL:\n\(requestPath)"] )
      completion(nil, error)
    }
  }
  
  // TODO - Implement Functionality
  internal func executeArrayRequest(_ requestPath:String, completion: @escaping (_ array:NSArray?, _ error: NSError?) -> Void) {
    
    print("Executing Request With Path: \(requestPath)")
    if let request = requestWithURLString(requestPath) {
      // Create the request
      let task = session.dataTask(with: request) { data, response, error in
        
        if error != nil {
          completion(nil, error as NSError?)
          return
        }
        
        // Check to see if there was an HTTP Error
        let cleanResponse = self.checkResponseForErrors(response)
        if let errorCode = cleanResponse.errorCode {
          print("An error occured: \(errorCode)")
          completion(nil, error as NSError?)
          return
        }
        
        // Make sure you got an array back after parsing
        guard let dataArray = self.jsonArray(withData: data!) else {
          print("Parsing Issues")
          completion(nil, error as NSError?)
          return
        }
        
        // Things went well, call the completion handler
        completion(dataArray, error as NSError?)
      }
      task.resume()
      
    } else {
      // It was a bad URL, so just fire an error
      let error = NSError(domain:NSURLErrorDomain,
                          code:NSURLErrorBadURL,
                          userInfo:[ NSLocalizedDescriptionKey : "There was a problem creating the request URL:\n\(requestPath)"] )
      completion(nil, error)
    }
  }
  
  
  // MARK: - ****** Response Helpers ******
  
  /**
   Takes an `NSURLResponse` object and attempts to determine if any errors occured
   - parameter response: The `NSURLResponse` generated by the task
   - returns: Tuple (`httpResponse` - The `NSURLResponse` cast to a `NSHTTPURLResponse` and `errorCode` - An error code enum representing detecable problems.)
   */
  internal func checkResponseForErrors(_ response: URLResponse?) -> (httpResponse: HTTPURLResponse?, errorCode: WebServiceError?) {
    // Make sure there was an actual response
    guard response != nil else {
      return (nil, WebServiceError.noResponse)
    }
    
    // Convert the response to an `NSHTTPURLResponse` (You can do this because you know that you are making HTTP calls in this scenario, so the cast will work.)
    guard let httpResponse = response as? HTTPURLResponse else {
      return (nil, WebServiceError.badResponse)
    }
    
    // Check to see if the response contained and HTTP response code of something other than 200
    let statusCode = httpResponse.statusCode
    guard statusCode == 200 else {
      return (nil, WebServiceError.other)
    }
    
    return (httpResponse, nil)
  }
  
  /**
   Takes an `NSData` object and attempts to extract a dictionary from it
   - parameter data: The `NSData` object that contains a `JSON` string
   - returns: A dictionary of objects keyed with Strings
   - SeeAlso: `jsonArray(withData data: NSData)`, `stripJSONPWrapper(jsonp: NSData)`
   */
  internal func jsonDictionary(withData data: Data) -> NSDictionary? {
    do {
      
      // Extract the JSON object and check to see if its a dictionary
      return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary
      
    } catch {
      return nil
    }
  }
  
  /**
   Takes an `NSData` object and attempts to extract an array from it
   - parameter data: The `NSData` object that contains a `JSON` string
   - returns: A dictionary of objects keyed with Strings
   - SeeAlso: `jsonDictionary(withData data: NSData)`, `stripJSONPWrapper(jsonp: NSData)`
   */
  internal func jsonArray(withData data: Data) -> NSArray? {
    do {
      
      // Extract the JSON object and check to see if its an array
      return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSArray
      
    } catch {
      return nil
    }
  }
  
}
