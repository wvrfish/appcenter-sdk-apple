import AppCenter
import AppCenterAnalytics
import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var `switch`: NSButton!
    
    @IBAction func switchState(_ sender: Any) {
        MSAppCenter.setEnabled(!MSAppCenter.isEnabled())
        let isEnabled = MSAppCenter.isEnabled()
        self.switch.title = isEnabled ? "Turn off" : "Turn on"
    }
    
    @IBAction func trackEvent(_ sender: Any) {
        MSAnalytics.trackEvent("TestEvent_SPM")
    }
    
    @IBAction func crash(_ sender: Any) {
        let buf: UnsafeMutablePointer<UInt>? = nil;
        buf![1] = 1;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
}

