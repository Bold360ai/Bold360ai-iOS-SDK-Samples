// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import UIKit
import NanorepUI

class ViewController: UIViewController {
    
    private let accountParams = AccountParams()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.accountParams.account = ""
        self.accountParams.knowledgeBase = ""
        self.accountParams.apiKey = ""
    }
    
    var controller: NRConversationalViewController!
    
    
    @IBAction func loadNanorep(_ sender: UIButton) {
        print("bold360ai sdk is loaded")
        
        // Set config
        let config: NRBotConfiguration = NRBotConfiguration()
        config.chatContentURL = URL(string:"")
        config.withNavBar = true
        // Create NRConversationalViewController
        controller = NRConversationalViewController(accountParams: self.accountParams)
        controller.configuration = config
        
        self.present(controller, animated: true, completion: nil)
    }
}

