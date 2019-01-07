// ===================================================================================================
// Copyright © 2016 bold360ai(LogMeIn).
// BoldAIEngine SDK.
// All rights reserved.
// ===================================================================================================

import UIKit
import BoldAIEngine
import BoldUI

class AccountViewController: UIViewController {
    
    var context = [["": ""]]
    var canAddContext: Bool = false
    
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var kb: UITextField!
    @IBOutlet weak var apiKey: UITextField!
    @IBOutlet weak var contextTableView: UITableView!
    @IBOutlet weak var withWelcomeMessage: UISwitch!
    @IBOutlet weak var server: UITextField!
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    let spinner = UIActivityIndicatorView()
    
    var chatController: NRChatController!
    
    var delegate: ChatHandlerDelegate!
    var chatControllerDelegate: NRChatControllerDelegate!
    var chatHandlerProvider: ChatHandlerProvider!
    var chatViewController: UIViewController!
    
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
        
        self.addReachabilityObserver()
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
        account.account = "jio"//self.accountName.text
        account.knowledgeBase = "Staging"//self.kb.text
        
        if (self.apiKey.text?.count)! > 0 {
            account.apiKey = self.apiKey.text
        } else {
//          If the APIkey is empty the app should send
//          a space instead of empty string at the request
            account.apiKey = " "
        }
        
        if (self.server.text?.count)! > 0 {
            account.perform(#selector(setter: AccountViewController.server), with:"qa07")//self.server.text)
        }
        
        
        var temp = [String: String]()
        self.context.forEach { (val) in
            temp[val.keys.first!] = val.values.first
        }
        account.nanorepContext = temp
        
        let config: NRBotConfiguration = NRBotConfiguration()
        self.chatController = NRChatController(account: account)
//        let viewConfig = ChatConfiguration();
//        viewConfig.backgroundColor = UIColor.red;
//        viewConfig.incomingBotConfig.backgroundColor = UIColor.red;
//        self.chatController.viewConiguration = viewConfig;
        config.chatContentURL = URL(string: "https://cdn-customers.nanorep.com/v3/view-default.html")
        config.withNavBar = true
        self.chatController.delegate = self
        self.chatController.handOver = self
        self.chatController.continuityProvider = self
        self.chatController.uiConfiguration = config
//        self.chatController.historyProvider = self
        self.chatController.speechReconitionDelegate = self
        self.chatController.initialize = { controller, configuration, error in
            if let vc = controller {
                self.navigationItem.rightBarButtonItem = sender
                self.chatViewController = vc
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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
    
    func didUpdate(_ state: ChatState, with agentType: AgentType) {
        if (agentType == AgentType.Live) {
            if (ChatState.started == state) {
                self.chatViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End Chat", style: .plain, target: self, action:#selector(buttonAction))
            } else if (ChatState.ended == state) {
                self.chatViewController.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func shouldPresent(_ form: BrandedForm!, handler completionHandler: (((UIViewController & BoldForm)?) -> Void)!) {
        if (completionHandler != nil) {
            if form.form?.type == BCFormTypePostChat {
                let postVC = self.storyboard?.instantiateViewController(withIdentifier: "postChat") as! PostChatViewController
                postVC.form = form
                completionHandler(postVC)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        self.chatController.endChat()
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
        let remote = RemoteChatElement(type: .IncomingLiveElement, content: "Hello from Live Agent: \(String(describing: statement?.text))")
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
