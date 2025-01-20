import UIKit
import Flutter

import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let listTileFactory = ListTileNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
    self, factoryId:"adFactoryExample",nativeAdFactory:listTileFactory)

    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "아이디를 입력하세요" ]

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
