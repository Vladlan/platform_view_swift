// Copyright 2018, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import UIKit
import Foundation
import MediaPlayer
import FRadioPlayer

struct Track {
  var artist: String?
  var name: String?
  var image: UIImage?

  init(artist: String? = nil, name: String? = nil, image: UIImage? = nil) {
    self.name = name
    self.artist = artist
    self.image = image
  }
}

struct Station {
  let name: String
  let detail: String
  let url: URL
  var image: URL?

  init(name: String, detail: String, url: URL, image: URL? = nil) {
    self.name = name
    self.detail = detail
    self.url = url
    self.image = image
  }
}

protocol PlatformViewControllerDelegate {
  func didUpdateCounter(counter: Int)
}

class PlatformViewController : UIViewController {
  var delegate: PlatformViewControllerDelegate? = nil
  var counter: Int = 0

  var track: Track? {
    didSet {
      incrementLabel.text = track?.name
      updateNowPlaying(with: track)
    }
  }

  // Singleton ref to player
  let player: FRadioPlayer = FRadioPlayer.shared

  // List of stations
  let stations = [Station(name: "Newport Folk Radio",
          detail: "Are you ready to Folk?",
          url: URL(string: "http://rfcmedia.streamguys1.com/Newport.mp3")!,
          image: URL(string: "http://xata44.by/sites/default/files/logo-radio.png")!),
  ]

  @IBOutlet weak var incrementLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    setIncrementLabelText()

    player.radioURL = URL(string: "https://s2.radio.co/se91d38a33/listen")
    player.isAutoPlay = true
    player.enableArtwork = true
    player.artworkSize = 600
    player.togglePlaying()

    setupRemoteTransportControls()
  }

  func handleIncrement(_ sender: Any) {
    print("handleIncrement()")
    self.counter += 1
    self.setIncrementLabelText()
    player.togglePlaying()
  }

  func switchToFlutterView(_ sender: Any) {
    self.delegate?.didUpdateCounter(counter: self.counter)
    dismiss(animated:false, completion:nil)
  }

  func setIncrementLabelText() {
    let text = String(format: "Button tapped %d %@", self.counter, (self.counter == 1) ? "time" : "times")
    self.incrementLabel.text = text;
  }





  func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
    print("radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState)")
    incrementLabel.text = state.description
  }

//  func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
//    playButton.isSelected = player.isPlaying
//  }

  func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
    print("radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?)")
    track = Track(artist: artistName, name: trackName)
  }

  func radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?) {
    print("radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?)")
    track = nil
  }

//  func radioPlayer(_ player: FRadioPlayer, metadataDidChange rawValue: String?) {
//    infoContainer.isHidden = (rawValue == nil)
//  }

  func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
    print("radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?)")

    // Please note that the following example is for demonstration purposes only, consider using asynchronous network calls to set the image from a URL.
    guard let artworkURL = artworkURL, let data = try? Data(contentsOf: artworkURL) else {
//      artworkImageView.image = stations[selectedIndex].image
      return
    }
    track?.image = UIImage(data: data)
//    artworkImageView.image = track?.image
    updateNowPlaying(with: track)
  }











  func setupRemoteTransportControls() {
    print("setupRemoteTransportControls()")
    // Get the shared MPRemoteCommandCenter
    let commandCenter = MPRemoteCommandCenter.shared()

    // Add handler for Play Command
    commandCenter.playCommand.addTarget { [unowned self] event in
      if self.player.rate == 0.0 {
        self.player.play()
        return .success
      }
      return .commandFailed
    }

    // Add handler for Pause Command
    commandCenter.pauseCommand.addTarget { [unowned self] event in
      if self.player.rate == 1.0 {
        self.player.pause()
        return .success
      }
      return .commandFailed
    }

    // Add handler for Next Command
    commandCenter.nextTrackCommand.addTarget { [unowned self] event in
//      self.next()
      return .success
    }

    // Add handler for Previous Command
    commandCenter.previousTrackCommand.addTarget { [unowned self] event in
//      self.previous()
      return .success
    }
  }

  func updateNowPlaying(with track: Track?) {
    print("updateNowPlaying(with track: Track?)")

    // Define Now Playing Info
    var nowPlayingInfo = [String : Any]()

    if let artist = track?.artist {
      nowPlayingInfo[MPMediaItemPropertyArtist] = artist
    }

    nowPlayingInfo[MPMediaItemPropertyTitle] = track?.name ?? stations[0].name

//    if let image = track?.image ?? stations[0].image {
//      nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
//        return image
//      })
//    }

    // Set the metadata
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }


}

// MARK: - FRadioPlayerDelegate

//extension PlatformViewController: FRadioPlayerDelegate {
//
//  func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
//    incrementLabel.text = state.description
//  }
//
////  func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
////    playButton.isSelected = player.isPlaying
////  }
//
//  func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
//    track = Track(artist: artistName, name: trackName)
//  }
//
//  func radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?) {
//    track = nil
//  }
//
////  func radioPlayer(_ player: FRadioPlayer, metadataDidChange rawValue: String?) {
////    infoContainer.isHidden = (rawValue == nil)
////  }
//
//  func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
//
//    // Please note that the following example is for demonstration purposes only, consider using asynchronous network calls to set the image from a URL.
//    guard let artworkURL = artworkURL, let data = try? Data(contentsOf: artworkURL) else {
////      artworkImageView.image = stations[selectedIndex].image
//      return
//    }
//    track?.image = UIImage(data: data)
////    artworkImageView.image = track?.image
//    updateNowPlaying(with: track)
//  }
//}

// MARK: - Remote Controls / Lock screen

extension PlatformViewController {


}