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
import WatchConnectivity

class InterfaceController: WKInterfaceController {
  
  fileprivate let locationAccessUnauthorizedMessage = "Locations Disabled\n\nEnable locations for this app via the Settings in your iPhone to see meetups near you!"
  fileprivate let pendingAccessMessage = "Grant location access to Meetup Finder on your iPhone to see meetup groups in your vicinity."
  
  /// The WKInterfaceGroup that's displayed when there's no content and instead
  /// you want to display a message to user, e.g. "No Meetups found", or
  /// "Location service is disabled", etc.
  @IBOutlet fileprivate var messageContentGroup: WKInterfaceGroup!
  @IBOutlet fileprivate var messageLabel: WKInterfaceLabel!
  
  /// The WKInterfaceGroup that's displayed when there're meetups. It contains the WKInterfaceTable.
  @IBOutlet fileprivate var meetupsContentGroup: WKInterfaceGroup!
  @IBOutlet fileprivate var interfaceTable: WKInterfaceTable!
  
  fileprivate let interfaceModel = MainInterfaceModel()
  fileprivate let meetupRequestManager = MeetupRequestManager()
  fileprivate var session: WCSession?
  fileprivate var lastQueriedLocation: CLLocation?
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    startSession()
  }
  
  override func willActivate() {
    super.willActivate()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    let meetup = interfaceModel.meetups[rowIndex]
    pushController(withName: "DetailInterfaceController", context: meetup)
  }
  
  // MARK: Helper
  
  func handleLocationServicesAuthorizationStatus(
    status: CLAuthorizationStatus) {
  }
  
  func handleLocationServicesStateNotDetermined() {
  }
  
  func handleLocationServicesStateUnavailable() {
  }
  
  func handleLocationServicesStateAvailable() {
  }
  
  fileprivate func updateInterfaceWithMeetups(_ meetups: [Meetup]) {
    // Initialize, add or remove rows from the Interface Table
    // based on current number of meetups and the new count of meetups.
    let currentCount = interfaceModel.meetups.count
    let newCount = meetups.count
    let rowType = "MeetupRowController"
    
    // Not all conditions may require the following values.
    // They're here to refactor common code.
    let diff = newCount - currentCount
    let range = NSMakeRange(currentCount, diff)
    let indexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
    
    // Update row count of the table.
    performBlock { () -> Void in
      if currentCount == 0 {
        // Initialize table.
        self.interfaceTable.setNumberOfRows(newCount, withRowType: rowType)
      } else if currentCount > newCount {
        // Add new rows.
        self.interfaceTable.insertRows(at: indexSet, withRowType: rowType)
      } else if currentCount < newCount {
        // Remove extra rows.
        self.interfaceTable.removeRows(at: indexSet)
      }
      
      // Update content of rows.
      self.performBlock { () -> Void in
        for (index, meetup) in meetups.enumerated() {
          guard let rowController = self.interfaceTable.rowController(at: index) as? MeetupRowController else { continue }
          rowController.meetupGroupNameLabel.setText(meetup.group.name)
          rowController.meetupLocationLabel.setText(meetup.location.city + ", " + meetup.location.state)
          rowController.meetupMembersLabel.setText("\(meetup.group.numberOfMembers)")
          rowController.containerGroup.setBackgroundColor(meetup.group.color)
        }
      }
    }
    
    // Update interface model.
    interfaceModel.meetups = meetups
    if newCount == 0 {
      interfaceModel.state = .noContent
      messageLabel.setText("No Meetup groups\nare found ;[")
    } else {
      interfaceModel.state = .meetupContent
    }
    performBlock { () -> Void in
      self.updateVisibilityOfInterfaceGroups()
    }
  }
  
  /// Show 'Loading...' in the message label if applicable. That's there's been no
  /// content before, now the controller is loading content.
  /// Otherwise does nothing, e.g. a refresh or reload.
  fileprivate func showLoadingMessageIfApplicable() {
    switch interfaceModel.state {
    case .error: fallthrough
    case .noContent: fallthrough
    case .notAuthorized:
      messageLabel.setText("Loading...")
    default:
      break
    }
  }
  
  /// Toggles appearance of top-level interface elements
  fileprivate func updateVisibilityOfInterfaceGroups() {
    switch self.interfaceModel.state {
    case .error: fallthrough
    case .noContent:
      messageContentGroup.setHidden(false)
      meetupsContentGroup.setHidden(true)
    case .notAuthorized:
      messageContentGroup.setHidden(false)
      meetupsContentGroup.setHidden(true)
    case .meetupContent:
      messageContentGroup.setHidden(true)
      meetupsContentGroup.setHidden(false)
    }
  }
  
  fileprivate func queryMeetupsFor(_ location: CLLocation) {
    // Early termination. Don't query backend if location hasn't changed significantly.
    let isSignificantChange = isLocationChangedSignificantly(location)
    if isSignificantChange == false {
      print("New query to meetups ignored because current location hasn't changed significantly.")
      return
    }
    
    lastQueriedLocation = location
    interfaceModel.loading = true
    showLoadingMessageIfApplicable()
    
    let coordinate = location.coordinate
    let lon = Double(coordinate.longitude)
    let lat = Double(coordinate.latitude)
    let requestModel = MeetupGroupRequestModel(latitude: lat, longitude: lon, radius: MeetupQueryRadius, pages: MeetupQueryPages, searchText: "iOS")
    
    weak var weakSelf = self
    meetupRequestManager.fetchMeetupGroupsWithModel(model: requestModel) { (meetups, error) -> Void in
      var nonnilMeetups = [Meetup]()
      if let meetups = meetups {
        nonnilMeetups = meetups
      }
      weakSelf?.interfaceModel.loading = false
      weakSelf?.updateInterfaceWithMeetups(nonnilMeetups)
    }
  }
  
  func isLocationChangedSignificantly(_ updatedLocation: CLLocation) -> Bool {
    return true
  }
}

// MARK: WCSessionDelegate

extension InterfaceController: WCSessionDelegate {
  
  fileprivate func startSession() {
    session = WCSession.default()
    session?.delegate = self
    session?.activate()
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("Activation did complete: \(activationState), error: \(error)")
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    print("Received application context: (applicationContext)")
  }
}
