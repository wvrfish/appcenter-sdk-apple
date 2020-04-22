import AppCenter
import AppCenterAnalytics

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var `switch`: UIButton!
    
    @IBAction func switchState(_ sender: Any) {
        MSAppCenter.setEnabled(!MSAppCenter.isEnabled())
        let isEnabled = MSAppCenter.isEnabled()
        self.switch.setTitle(isEnabled ? "Turn off" : "Turn on", for: UIControl.State.normal)
    }
    
    @IBAction func trackEvent(_ sender: Any) {
        MSAnalytics.trackEvent("TestEvent_SPM")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

