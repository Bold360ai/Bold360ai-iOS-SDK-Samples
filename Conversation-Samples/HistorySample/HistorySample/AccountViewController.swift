//
//  AccountViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 31/10/2018.
//  Copyright © 2018 bold360ai. All rights reserved.
//

import UIKit
import BoldAIEngine
import BoldUI

class AccountViewController: UIViewController {
    
    var context: [[String: String]]!
    var canAddContext: Bool = false
    
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var kb: UITextField!
    @IBOutlet weak var apiKey: UITextField!
    @IBOutlet weak var contextTableView: UITableView!
    @IBOutlet weak var withWelcomeMessage: UISwitch!
    @IBOutlet weak var server: UITextField!
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    let spinner = UIActivityIndicatorView()
    var presentButton: UIBarButtonItem!
    
    var chatController: NRChatController!
    
    var delegate: ChatHandlerDelegate!
    var chatControllerDelegate: NRChatControllerDelegate!
    var chatHandlerProvider: ChatHandlerProvider!
    
    let reachability = Reachability()
    
    // The Time Between Welcome Message Presantation
    let welcomeMsgTimeIteration = 30.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AccountViewController.updateHeight(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AccountViewController.updateHeight(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        if let accountParams = UserDefaults.standard.dictionary(forKey: "Account") as? [String: String] {
            self.accountName.text = accountParams["accountName"]
            self.kb.text = accountParams["kb"]
            self.apiKey.text = accountParams["apiKey"]
            self.server.text = accountParams["server"]
        }
        self.context = UserDefaults.standard.array(forKey: "Contexts") as? [[String: String]] ?? [["": ""]]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func stopLiveChat(sender: UIBarButtonItem) {
        self.navigationController?.viewControllers.last?.navigationItem.setRightBarButton(nil, animated: true)
        self.navigationController?.viewControllers.last?.title = "Bye .."
        self.navigationController?.viewControllers.last?.perform(#selector(setter: UIViewController.title), with: nil, afterDelay: 2)
        self.chatHandlerProvider.didEndChat(self)
    }
    
    @IBAction func presentNanorep(_ sender: UIBarButtonItem) {
        spinner.sizeToFit()
        spinner.startAnimating()
        spinner.color = UIColor.lightGray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        let account = AccountParams()
        account.account = self.accountName.text
        account.knowledgeBase = self.kb.text
        if (self.apiKey.text?.count)! > 0 {
            account.apiKey = self.apiKey.text
        }

        if (self.server.text?.count)! > 0 {
            account.perform(Selector.init("setServer:"), with:self.server.text)
        }

        var storeAccount = [String: String]()
        storeAccount["accountName"] = self.accountName.text
        storeAccount["kb"] = self.kb.text
        storeAccount["apiKey"] = self.apiKey.text
        storeAccount["server"] = self.server.text
        UserDefaults.standard.set(storeAccount, forKey: "Account")
        UserDefaults.standard.set(self.context, forKey: "Contexts")
        UserDefaults.standard.synchronize()
        var temp = [String: String]()
        self.context.forEach { (val) in
            temp[val.keys.first!] = val.values.first
        }
//        let account = BCAccount(accessKey: "2300000001700000000:2278936004449775473:sHkdAhpSpMO/cnqzemsYUuf2iFOyPUYV")
        self.chatController = NRChatController(account: account)
//        self.chatController.viewConfiguration.chatViewConfig.backgroundColor = UIColor.lightBlue()
        self.chatController.viewConfiguration.chatViewConfig.backgroundImage = UIImage(named: "ww_back_light")
        self.chatController.viewConfiguration.chatViewConfig.dateStampColor = UIColor.black
        self.chatController.viewConfiguration.outgoingConfig.dateStampColor = UIColor.black
        self.chatController.viewConfiguration.incomingBotConfig.dateStampColor = UIColor.black
//        self.chatController.viewConfiguration.outgoingConfig.avatar = UIImage(named: "icon")
//        self.chatController.viewConfiguration.incomingBotConfig.avatar = UIImage(named: "nrIcon")
//        self.chatController.viewConfiguration.incomingBotConfig.textColor = UIColor.blue
//        self.chatController.viewConfiguration.incomingBotConfig.backgroundColor = UIColor.white
//        self.chatController.viewConfiguration.outgoingConfig.backgroundColor = UIColor.purple
//        self.chatController.viewConfiguration.quickOptionConfig.backgroundColor = UIColor.cyan;
        self.chatController.delegate = self
        self.chatController.handOver = self
        self.chatController.continuityProvider = self
//        self.chatController.historyProvider = self
        self.chatController.speechReconitionDelegate = self
        self.presentButton = sender
//        self.chatController.initialize = { controller, configuration, error in
//            if let vc = controller {
//                self.navigationItem.rightBarButtonItem = sender
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }
    
    
    @objc func updateHeight(notification: Notification)  {
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            self.keyboardConstraint.constant = 0
        } else {
            let height = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
            self.keyboardConstraint.constant = height
        }
    }
    
    @objc func addContext() {
        if self.canAddContext  {
            self.canAddContext = false
            self.context.append(["" : ""])
            let indexPath = IndexPath(row: self.context.count - 1, section: 0)
            self.contextTableView.beginUpdates()
            self.contextTableView.insertRows(at: [indexPath], with: .bottom)
            self.contextTableView.endUpdates()
            self.contextTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    

}

extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.size.width, height: 44)))
        view.backgroundColor = UIColor.lightGray
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.size.width, height: 44)))
        button.setTitle("Add Context", for: .normal)
        view.addSubview(button)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(AccountViewController.addContext), for: .touchUpInside)
        return view
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && self.context.count > 1 {
            self.context.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension AccountViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        (cell as! ContextTableViewCell).context = self.context[indexPath.row]
        (cell as! ContextTableViewCell).delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.context.count
    }
    
    
}

extension AccountViewController: ContextTableViewCellDelegate {
    func updateContext(forCell: ContextTableViewCell!, context: [String : String]) {
        self.canAddContext = true
        if let index = self.contextTableView.indexPath(for: forCell)?.row {
            self.context[index] = context
        }
    }
}

extension AccountViewController: ContinuityProvider {
    func updateContinuityInfo(_ params: [String : NSNumber]!) {
        print("updateContinuityInfo")
        UserDefaults.standard.setValuesForKeys(params)
        UserDefaults.standard.synchronize()
    }
    
    func fetchContinuity(forKey key: String!, handler: ((NSNumber?) -> Void)!) {
        print("fetchContinuityForKey")
        handler(UserDefaults.standard.value(forKey: key) as? NSNumber)
    }
}

extension AccountViewController: NRChatControllerDelegate {
    func shouldPresentChatViewController(_ viewController: UIViewController!) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(AccountViewController.presentNanorep(_:)))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didFailLoadChatWithError(_ error: Error!) {
        
    }
    
    
    func shouldHandleFormPresentation(_ formController: UIViewController!) -> Bool {
        return false
    }
    
    func statement(_ statement: StorableChatElement!, didFailWithError error: Error!) {
        guard let _ = statement else {
            return
        }
        print("error: \(error)")
        print("statement:: status \(statement.status.rawValue)")
        DispatchQueue.main.async {
            let element = Item(item: statement)
            DBManager.sharedInstance.addData(object: element)
        }
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
        return self.handleWelcomeMsgPresentation()
    }
    
    private func handleWelcomeMsgPresentation() -> Bool {
        if self.withWelcomeMessage.isOn {
            return true
        }
        
        let welcomeMsgTime = UserDefaults.standard.object(forKey: "WelcomeMsgTime") as? TimeInterval
        var timeDiff = 0.0;
        
        if let msgTime = welcomeMsgTime {
            timeDiff = NSDate().timeIntervalSince1970 - msgTime
        }
        
        if welcomeMsgTime == nil || timeDiff > welcomeMsgTimeIteration {
            // save current time to user defaults
            UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "WelcomeMsgTime")
            
            return true
        }
        
        return false
    }
}

extension AccountViewController: ChatHandler {
    func submitForm(_ form: BrandedForm!) {
        
    }
    
    func postArticle(_ articleId: String!) {
        
    }
    
    func startChat(_ chatInfo: [AnyHashable : Any]!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.navigationController?.viewControllers.last?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(AccountViewController.stopLiveChat(sender:))), animated: true)
            self.navigationController?.viewControllers.last?.title = "You're talking with Nisso"
        })
        
    }
    
    func endChat() {
        
    }
    
    func postStatement(_ statement: StorableChatElement!) {
        self.delegate.presentStatement(statement)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate.update(StatementStatus.OK, element: statement)
        }
        let remote = RemoteChatElement(type: .IncomingBotElement, content: "Hello from Live Agent: \(String(describing: statement?.text))")
        remote?.design = ChatElementDesignCustomIncoming
        remote?.agentType = .Live
        
        // Random delay value for tests
        let random = Double(arc4random_uniform(9) + 1)
        (self.delegate as! NSObject).perform(#selector(ChatHandlerDelegate.presentStatement(_:)), with: remote, afterDelay: random)
    }
    
    func handleClickedLink(_ link: URL!) {
        print(link.absoluteString)
    }
    
    func handleEvent(_ eventParams: [AnyHashable : Any]!) {
        
    }
}

/************************************************************/
// MARK: - Reachability & Application States Handling
/************************************************************/

extension AccountViewController {
    // Reachability Handling
    private func addReachabilityObserver() -> Void {
        guard let reachability = self.reachability else { return }
        reachability.startNotifier()
        
        reachability.onUnreachable = { reachability in
            print("Warning: network unreachable")
        }
        reachability.onReachable = { [unowned self] reachability in
            print("Warning: network reachable")
            
            DispatchQueue.main.async {
                if let history = DBManager.sharedInstance.getDataFromDB() {
                    var elements = [StorableChatElement]()
                    
                    for item in history {
                        print("addReachabilityObserver:: status\(item.status.rawValue)")
                        if (item.status.rawValue == StatementStatus.Error.rawValue) {
                            print("item.status: \(item.status)")
                            print("item.elementId: \(item.ID)")
                            elements.append(item)
                        }
                    }
                    
                    if elements.count > 0 {
                        self.chatController?.repostStatements(elements)
                    }
                }
            }
        }
    }
    
    private func removeReachabilityObserver() -> Void {
        self.reachability?.stopNotifier()
    }
}

/************************************************************/
// MARK: - HistoryProvider
/************************************************************/

extension AccountViewController: HistoryProvider {
    func fetch(_ from: Int, handler: (([Any]?) -> Void)!) {
        print("fetch")
        
        DispatchQueue.main.async {
            var elements: Array<StorableChatElement>!
            
            if let history = DBManager.sharedInstance.getDataFromDB() {
                elements = Array(history)
            }
            
            handler(elements)
        }
    }
    
    func store(_ item: StorableChatElement) {
        print("store")
        
        DispatchQueue.main.async {
            print("store:: status \(item.status.rawValue)")
            let element = Item(item: item)
            element.ID = item.elementId.intValue
            DBManager.sharedInstance.addData(object: element)
        }
    }
    
    func remove(_ timestampId: TimeInterval) {
        print("remove")
        
        DispatchQueue.main.async {
            DBManager.sharedInstance.deleteAllDatabase()
        }
    }
    
    func update(_ timestampId: TimeInterval, newTimestamp: TimeInterval, status: StatementStatus) {
        print("update")
    }
}

extension AccountViewController: SpeechReconitionDelegate {
    func speechRecognitionStatus(_ status: NRSpeechRecognizerAuthorizationStatus) {
        let alert = UIAlertController(title: "Speech Recognition Error", message: "Please enable speech recognition in Settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        switch status {
        case .recordingDenied:
            alert.title = "Audio Recording Error"
            alert.message = "Please enable audio recording"
            self.present(alert, animated: true, completion: nil)
        case .denied:
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}
