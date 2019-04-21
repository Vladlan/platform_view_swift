// Copyright 2018, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PlatformViewControllerDelegate
{
  var flutterResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel.init(name: "samples.flutter.io/platform_view_swift", binaryMessenger: controller)

    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if ("switchView" == call.method) {
        self.flutterResult = result
        print("switchView")
        let platformViewController = controller.storyboard?.instantiateViewController(withIdentifier: "PlatformView") as! PlatformViewController
        platformViewController.counter = call.arguments as! Int
        platformViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: platformViewController)
        navigationController.navigationBar.topItem?.title = "Platform View1"
        controller.present(navigationController, animated: true, completion: nil)
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
//      player.togglePlaying()
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didUpdateCounter(counter: Int) {
    flutterResult?(counter)
  }
}
