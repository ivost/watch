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
import AVKit
import AVFoundation

class BrowserViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  // MARK: Properties - private
  
  private let provider = VideoClipProvider()
  
  /// A array of AVAsset for each video clip in the bundle.
  private let videoAssets: [AVAsset]
  
  // MARK: Life Cycle
  
  required init?(coder aDecoder: NSCoder) {
    var assets: [AVAsset] = []
    for clip in provider.clips {
      let asset = AVAsset.init(url: clip)
      assets.append(asset)
    }
    videoAssets = assets
    super.init(coder: aDecoder)
  }
  
  override var prefersStatusBarHidden: Bool {
    get {
      return true
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext) in
      self.collectionView?.reloadData()
      }, completion: nil)
  }
  
  // MARK: UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let count = videoAssets.count
    return count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCell.IBIdentifier, for: indexPath) as! PreviewCell
    cell.asset = videoAssets[indexPath.item]
    cell.footnote = provider.quotes[indexPath.row]
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = videoAssets[indexPath.item]
    presentVideoPlayer(withAsset: asset)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let collectionViewWidth = collectionView.bounds.size.width
    let collectionViewHeight = collectionView.bounds.size.height
    
    let size: CGSize
    if collectionViewWidth >= collectionViewHeight {
      size = CGSize(width: 328, height: 249)
    } else {
      size = CGSize(width: 375, height: 275)
    }
    return size
  }
  
  // MARK: Private
  
  /// Presents a video player view controller to playback a given AVAsset.
  private func presentVideoPlayer(withAsset asset: AVAsset) {
    let item = AVPlayerItem(asset: asset)
    let player = AVPlayer(playerItem: item)
    let controller = AVPlayerViewController()
    controller.player = player
    controller.modalPresentationStyle = .formSheet
    present(controller, animated: true) {
      player.play()
    }
  }
  
}
