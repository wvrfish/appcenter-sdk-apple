import AppCenter
import AppCenterAnalytics
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        MSAppCenter.setLogLevel(.verbose)
        MSAppCenter.start("a23f7c03-8b66-4225-90fc-86a7590722de", withServices: [MSAnalytics.self])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

