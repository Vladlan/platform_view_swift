// Copyright 2018, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import UIKit
import Flutter
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

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PlatformViewControllerDelegate
{
  var flutterResult: FlutterResult?

  var track: Track? {
    didSet {
      updateNowPlaying(with: track)
    }
  }

  // Singleton ref to pla¡¡yer
  let player: FRadioPlayer = FRadioPlayer.shared

  // List of stations
  let stations = [Station(name: "Newport Folk Radio",
          detail: "Are you ready to Folk?",
          url: URL(string: "https://s2.radio.co/se91d38a33/listen")!,
          image: URL(string: "http://xata44.by/sites/default/files/logo-radio.png")!),
  ]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel.init(name: "samples.flutter.io/platform_view_swift", binaryMessenger: controller)

    player.delegate = self

    player.radioURL = URL(string: "https://s2.radio.co/se91d38a33/listen")
    player.isAutoPlay = true
    player.enableArtwork = true
    player.artworkSize = 600
    player.togglePlaying()

    setupRemoteTransportControls()

    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if ("switchView" == call.method) {
        self.flutterResult = result
        print("switchView")
//        let platformViewController = controller.storyboard?.instantiateViewController(withIdentifier: "PlatformView") as! PlatformViewController
//        platformViewController.counter = call.arguments as! Int
//        platformViewController.delegate = self
//
//        let navigationController = UINavigationController(rootViewController: platformViewController)
//        navigationController.navigationBar.topItem?.title = "Platform View1"
//        controller.present(navigationController, animated: true, completion: nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    });

    let radioChannel = FlutterMethodChannel(name:"samples.flutter.io/platform_view_swift_toggle_play", binaryMessenger: controller)
    radioChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "toggle_play" else {
        result(FlutterMethodNotImplemented)
        return
      }
      print("togglePlaying()")
      self?.player.togglePlaying()
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didUpdateCounter(counter: Int) {
    flutterResult?(counter)
  }
}

// MARK: - FRadioPlayerDelegate
extension AppDelegate: FRadioPlayerDelegate {
  func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
    print("0")
    print(state)
  }

  func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
//    playButton.isSelected = player.isPlaying
    print(state)
    print("1")
  }

  func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
    print("2")
    print("artistName:")
    print(artistName)
    print("trackName:")
    print(trackName)
    track = Track(artist: artistName, name: trackName)
  }

  func radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?) {
    print("3")
    print("url:")
    print(url)
    track = nil
  }

  func radioPlayer(_ player: FRadioPlayer, metadataDidChange rawValue: String?) {
    print("4")
    print("rawValue:")
    print(rawValue)
//      infoContainer.isHidden = (rawValue == nil)
  }

  func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
    print("5")
    print("artworkURL:")
    print(artworkURL)
    // Please note that the following example is for demonstration purposes only, consider using asynchronous network calls to set the image from a URL.
    guard let artworkURL = artworkURL, let data = try? Data(contentsOf: artworkURL) else {
//      artworkImageView.image = stations[selectedIndex].image
      return
    }
    track?.image = UIImage(data: data)
//    artworkImageView.image = track?.image
    updateNowPlaying(with: track)
  }
}

// MARK: - Remote Controls / Lock screen

extension AppDelegate {

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

    if #available(iOS 10.0, *) {
      if let image = track?.image {
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
          return image
        })
      }
    } else {

    }

    // Set the metadata
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
}

// MARK: - UINavigationController

extension UINavigationController {
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
