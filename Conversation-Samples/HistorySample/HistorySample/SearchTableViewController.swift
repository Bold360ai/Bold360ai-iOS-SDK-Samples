//
//  SearchTableViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 10/03/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit
import Bold360AI

class SearchTableViewController: AccountTableViewController {
    
    var widgetViewController: NRWidgetViewController!

    override var startButtonTitle: String {
        get {
            return "Start Search"
        }
    }
    
    override var dataFileName: String {
        get {
            return "InitObjSearch"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func startChat(sender: UIBarButtonItem) {
        super.startChat(sender: sender)
        NanoRep.shared()?.prepare(with: self.accountHandler.accountParams)
        NanoRep.shared()?.fetchConfiguration = { (configuration: NRConfiguration?, error: Error?) -> Void in
            guard let config = configuration else {
                print(error.debugDescription)
                return
            }
            config.useLabels = true
            DispatchQueue.main.async {
                self.widgetViewController = NRWidgetViewController()
                self.widgetViewController.infoHandler = self
                self.navigationController?.pushViewController(self.widgetViewController, animated: true)
                self.navigationItem.rightBarButtonItem = self.startChatButton
            }
        }
    }

}

extension SearchTableViewController: NanorepPersonalInfoHandler {
    func personalInfo(withExtraData extraData: [AnyHashable : Any]!, channel: NRChanneling!, completionHandler handler: (([AnyHashable : Any]?) -> Void)!) {
        handler(nil)
    }
    
    func didFetch(_ formData: ExtraData!) {
        
    }
    
    func didSubmitForm() {
        
    }
    
    func didCancelForm() {
        
    }
    
    func didFailSubmitFormWithError(_ error: Error!) {
        
    }
    
    func shouldOverridePhoneChannel(_ phoneChannel: NRChannelingPhoneNumber!) -> Bool {
        return false
    }
    
    func didSubmitFeedback(_ info: [AnyHashable : Any]!) {
        
    }
    
    
}
