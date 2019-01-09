//
//  BoldViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 07/01/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit
import Bold360AI

class BoldViewController: UIViewController {
    var chatController: ChatController!

    @IBOutlet weak var accessKey: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentBold(_ sender: UIBarButtonItem) {
        let account = BCAccount(accessKey: self.accessKey.text)
        self.chatController = ChatController(account: account)
        self.chatController.delegate = self
    }

}

extension BoldViewController: ChatControllerDelegate {
    func shouldPresentChatViewController(_ viewController: UIViewController!) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didFailLoadChatWithError(_ error: Error!) {
        
    }
}
