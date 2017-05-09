import UIKit

import MobileCenter
import MobileCenterAnalytics
import MobileCenterCrashes
import MobileCenterDistribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MSCrashesDelegate, MSDistributeDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // Customize Mobile Center SDK.
    MSDistribute.setDelegate(self);
    MSMobileCenter.setLogLevel(MSLogLevel.verbose)

    // Start Mobile Center SDK.
    #if DEBUG
      MSMobileCenter.start("0dbca56b-b9ae-4d53-856a-7c2856137d85", withServices: [MSAnalytics.self, MSCrashes.self])
    #else
      MSMobileCenter.start("0dbca56b-b9ae-4d53-856a-7c2856137d85", withServices: [MSAnalytics.self, MSCrashes.self, MSDistribute.self])
    #endif
    
    // Crashes Delegate.
    MSCrashes.setUserConfirmationHandler({ (errorReports: [MSErrorReport]) in
      
      // Your code.
      // Present your UI to the user, e.g. an UIAlertView.
      
      let alert = MSAlertController(title: "Sorry about that!",
                                    message: "Do you want to send an anonymous crash report so we can fix the issue?")
      alert?.addDefaultAction(withTitle: "Send", handler: { (alert) in
        MSCrashes.notify(with: MSUserConfirmation.send)
      })
      alert?.addDefaultAction(withTitle: "Always Send", handler: { (alert) in
        MSCrashes.notify(with: MSUserConfirmation.always)
      })
      alert?.addCancelAction(withTitle: "Don't Send", handler: { (alert) in
        MSCrashes.notify(with: MSUserConfirmation.dontSend)
      })
      alert?.show()
      return true
    })
    
    setMobileCenterDelegate()
    
    return true
  }
  
  private func setMobileCenterDelegate(){
    let sasquatchController = (window?.rootViewController as! UINavigationController).topViewController as! MSMainViewController
    sasquatchController.mobileCenter = MobileCenterDelegateSwift()
  }
  
  /**
   * (iOS 8) Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.
   *
   * @param app The singleton app object.
   * @param url The URL resource to open. This resource can be a network resource or a file.
   * @param sourceApplication The bundle ID of the app that is requesting your app to open the URL (url).
   * @param annotation A Property list supplied by the source app to communicate information to the receiving app.
   *
   * @return `YES` if the delegate successfully handled the request or `NO` if the attempt to open the URL resource
   * failed.
   */
  func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    
    // Forward the URL to MSDistribute.
    return MSDistribute.open(url as URL!)
  }
  
  /**
   * (iOS 9+) Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.
   *
   * @param app The singleton app object.
   * @param url The URL resource to open. This resource can be a network resource or a file.
   * @param options A dictionary of URL handling options.
   * For information about the possible keys in this dictionary and how to handle them, @see
   * UIApplicationOpenURLOptionsKey. By default, the value of this parameter is an empty dictionary.
   *
   * @return `YES` if the delegate successfully handled the request or `NO` if the attempt to open the URL resource
   * failed.
   */
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    // Forward the URL to MSDistribute.
    return MSDistribute.open(url as URL!)
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  // Crashes Delegate
  
  func crashes(_ crashes: MSCrashes!, shouldProcessErrorReport errorReport: MSErrorReport!) -> Bool {
    return true;
    // return true if the crash report should be processed, otherwise false.
  }
  
  func crashes(_ crashes: MSCrashes!, willSend errorReport: MSErrorReport!) {
    
  }
  
  func crashes(_ crashes: MSCrashes!, didSucceedSending errorReport: MSErrorReport!) {
    
  }
  
  func crashes(_ crashes: MSCrashes!, didFailSending errorReport: MSErrorReport!, withError error: Error!) {
    
  }

  // Distribute Delegate

  func distribute(_ distribute: MSDistribute!, releaseAvailableWith details: MSReleaseDetails!) -> Bool {
    return false;
  }
}

