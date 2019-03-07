//
//  BotTableViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 05/03/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit
import Bold360AI

class BotTableViewController: UITableViewController {
    var accountHandler: AccountHandler!
    let spinner = UIActivityIndicatorView()
    var chatController: ChatController!
    var chatViewController: UIViewController!
    
    var startChatButton: UIBarButtonItem {
        get {
            return UIBarButtonItem(title: "Start Chat", style: .plain, target: self, action: #selector(BotTableViewController.startChat(sender:)))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountHandler = AccountHandler()
        self.navigationItem.rightBarButtonItem = self.startChatButton
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    
    @objc func startChat(sender: UIBarButtonItem) {
        spinner.sizeToFit()
        spinner.startAnimating()
        spinner.color = UIColor.lightGray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        self.chatController = ChatController(account: self.accountHandler.accountParams)
        self.chatController.delegate = self
//        NanoRep.shared().chatDelegate = self
//        self.chatController.uploadProvider = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.accountHandler.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.accountHandler.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.type, for: indexPath) as! AccountDataTableViewCell

        cell.data = item
        cell.delegate = self
        // Configure the cell...

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return self.accountHandler.items[indexPath.row].type == "context"
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.accountHandler.deleteContext(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            self.perform(#selector(BotTableViewController.updateAddContextState(status:)), with: true, afterDelay: 1)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func updateAddContextState(status: NSNumber?) {
        if let stat = status {
            self.accountHandler.enableAddingContext = stat.boolValue
        }
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [IndexPath(row: self.accountHandler.items.count - 1, section: 0)], with: .none)
        self.tableView.endUpdates()
    }
    

}

extension BotTableViewController: AccountDataTableViewCellDelegate {
    func onEvent(event: DataEvent) {
        switch event {
        case .addContext:
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.updateAddContextState(status: nil)
            }
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [self.accountHandler.addContext()], with: .bottom)
            self.tableView.endUpdates()
            CATransaction.commit()
            break
        case .contextValid:
            self.updateAddContextState(status: true)
            break
        default:
            self.updateAddContextState(status: false)
        }
        
    }
}


extension BotTableViewController: ChatControllerDelegate {
    func shouldPresentChatViewController(_ viewController: UIViewController!) {
        self.chatViewController = viewController
        self.navigationItem.rightBarButtonItem = self.startChatButton
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didFailWithError(_ error: BLDError!) {
        switch error.type {
        case GeneralErrorType:
            print("GeneralErrorType")
            break
        case BLDChatErrorTypeFailedToStart:
            let alert = UIAlertController(title: "Bold load error", message: "Please check your account parameters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                self.navigationItem.rightBarButtonItem = self.startChatButton
            }
            break
        case BLDChatErrorTypeFailedToFinish:
            print("BLDChatErrorTypeFailedToFinish")
            break
        case BLDChatErrorTypeFailedToSubmitForm:
            print("BLDChatErrorTypeFailedToSubmitForm")
            break
        default:
            break
        }
    }
    
    func shouldHandleFormPresentation(_ formController: UIViewController!) -> Bool {
        return false
    }
    
    func statement(_ statement: StorableChatElement!, didFailWithError error: Error!) {
        guard let _ = statement else {
            return
        }
        
        guard let _ = error  else {
            print("error: \(error)")
            print("statement:: status \(statement.status.rawValue)")
            return
        }
        
//        DispatchQueue.main.async {
//            if (self.reachability?.isReachable)! {
//                let element = Item(item: statement)
//                DBManager.sharedInstance.addData(object: element)
//            }
//        }
    }
    
    func didClickLink(_ url: String!) {
        if let link = URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(link, options: [:], completionHandler: { (success) in
                    
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func didClick(toCall phoneNumber: String!) {
        let phoneNum = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        didClickLink("tel://" + phoneNum)
    }
    
    func presenting(_ controller: UIViewController!, shouldHandleClickedLink link: String!) -> Bool {
        return true
    }
    
    func shouldPresentWelcomeMessage() -> Bool {
        return false
    }
    
//    private func handleWelcomeMsgPresentation() -> Bool {
//        if self.withWelcomeMessage.isOn {
//            return true
//        }
//
//        let welcomeMsgTime = UserDefaults.standard.object(forKey: "WelcomeMsgTime") as? TimeInterval
//        var timeDiff = 0.0;
//
//        if let msgTime = welcomeMsgTime {
//            timeDiff = NSDate().timeIntervalSince1970 - msgTime
//        }
//
//        if welcomeMsgTime == nil || timeDiff > welcomeMsgTimeIteration {
//            // save current time to user defaults
//            UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "WelcomeMsgTime")
//
//            return true
//        }
        
//        return false
//    }
    
    func didUpdateState(_ event: ChatStateEvent!) {
        if (event.scope == StatementScope.Live) {
            if (ChatState.preparing == event.state) {
//                self.chatViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End Chat", style: .plain, target: self, action:#selector(buttonAction))
            } else if (ChatState.ended == event.state) {
                self.chatViewController.navigationItem.rightBarButtonItem = nil
            }
        }
        
        switch event.state {
        case .preparing:
            print("ChatPreparing")
        case .started:
            print("ChatStarted")
        case .accepted:
            print("ChatAccepted")
        case .ending:
            print("ChatEnding")
        case .ended:
            print("ChatEnded")
        case .unavailable:
            print("ChatUnavailable")
        }
    }
    
    func shouldPresent(_ form: BrandedForm!, handler completionHandler: (((UIViewController & BoldForm)?) -> Void)!) {
        if (completionHandler != nil) {
            if form.form?.type == BCFormTypePostChat {
                let postVC = self.storyboard?.instantiateViewController(withIdentifier: "postChat") as! PostChatViewController
                postVC.form = form
                completionHandler(postVC)
            } else if (form.form?.type == BCFormTypeUnavailable) {
                let unavailableVC = self.storyboard?.instantiateViewController(withIdentifier: "unavailable") as! UnavailableViewController
                unavailableVC.form = form
                completionHandler(unavailableVC)
            } else {
                completionHandler(nil)
            }
        }
    }
    
//    @objc func buttonAction(sender: UIButton!) {
//        self.chatController.endChat()
//    }
}
