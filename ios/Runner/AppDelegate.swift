import Flutter
import UIKit
import GoogleSignIn
import GoogleMaps
import FBSDKCoreKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configuração do Google Maps
    GMSServices.provideAPIKey("AIzaSyA69sIkASD2CYFNbzNV_7XOCR-3L1Fcqps")
    
    // Configuração do Facebook SDK
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Adicione este método para processar URLs de retorno do Google Sign-In e Facebook Login
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Processa o URL para Google Sign-In
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // Processa o URL para Facebook Login
    return ApplicationDelegate.shared.application(app, open: url, options: options)
  }
}