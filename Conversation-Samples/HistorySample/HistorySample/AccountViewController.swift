//
//  AccountViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 31/10/2018.
//  Copyright © 2018 bold360ai. All rights reserved.
//

import UIKit
import BoldAIEngine
import Bold360AI

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
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    let spinner = UIActivityIndicatorView()
    var chatController: ChatController!
    @IBOutlet weak var startBtn: UIBarButtonItem!
    
    var delegate: ChatHandlerDelegate!
    var chatControllerDelegate: ChatControllerDelegate!
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
        
        if let accountParams = UserDefaults.standard.dictionary(forKey: "Account") as? [String: String] {
            self.submitButton.isEnabled = true
            self.accountName.text = accountParams["accountName"]
            self.kb.text = accountParams["kb"]
            self.apiKey.text = accountParams["apiKey"]
            self.server.text = accountParams["server"]
        }
        if let ctxt = UserDefaults.standard.array(forKey: "Contexts") as? [[String: String]] {
            self.canAddContext = true
            self.context = ctxt
            self.addContext()
        } else {
            self.context = [["": ""]]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addContext()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.context.count - 1 > 0 {
            self.context.remove(at: self.context.count - 1)
        }
        super.viewDidDisappear(animated)
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
    
    
    @IBAction func presentNanorep(_ sender: Any) {
        if !(self.reachability?.isReachable)! {
            self.presentNetorkPopup()
            return
        }
        
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
        if self.context.count > 1 {
            UserDefaults.standard.set(self.context, forKey: "Contexts")
        }
        UserDefaults.standard.synchronize()
        var temp = [String: String]()
        self.context.forEach { (val) in
            temp[val.keys.first!] = val.values.first
        }
        self.chatController = ChatController(account: account)
        self.chatController.delegate = self
        /// Example for configurations

        self.chatController.viewConfiguration.chatViewConfig.backgroundImage = UIImage(named: "ww_back_light")
        self.chatController.viewConfiguration.chatViewConfig.dateStampColor = UIColor.black
        let font = CustomFont()
        font.fontFileName = "waltographUI.ttf"
        font.font = UIFont(name: "WaltographUI-Bold", size: 15)
        let font1 = CustomFont()
        font1.fontFileName = "Monotype Sabon Italic.otf"
        font1.font = UIFont(name: "MonotypeSabonW04-Italic", size: 20)
        self.chatController.viewConfiguration.outgoingConfig.customFont = font
        self.chatController.viewConfiguration.incomingBotConfig.customFont = font1
        self.chatController.viewConfiguration.incomingLiveConfig.customFont = font
//        self.chatController.viewConfiguration.incomingBotConfig.dateStampColor = UIColor.black
//        self.chatController.viewConfiguration.outgoingConfig.avatar = UIImage(named: "icon")
//        self.chatController.viewConfiguration.incomingBotConfig.avatar = UIImage(named: "nrIcon")
//        self.chatController.viewConfiguration.incomingBotConfig.textColor = UIColor.blue
//        self.chatController.viewConfiguration.incomingBotConfig.backgroundColor = UIColor.white
//        self.chatController.viewConfiguration.outgoingConfig.backgroundColor = UIColor.purple
//        self.chatController.viewConfiguration.quickOptionConfig.backgroundColor = UIColor.cyan;

        self.chatController.handOver = self
        self.chatController.continuityProvider = self
//        self.chatController.historyProvider = self
        NanoRep.shared().chatDelegate = self
        self.chatController.speechReconitionDelegate = self
    }
    
    
    @objc func updateHeight(notification: Notification)  {
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            self.keyboardConstraint.constant = 0
        } else {
            let height = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height + 0
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

extension AccountViewController: NRChatEngineDelegate {
    func didFetchConvesationId(_ conversationId: NSNumber!) {
        
    }
    
    func shouldHandleMissingEntities(_ response: NRConversationalResponse!, missingEntitiesHandler handler: ((NRConversationMissingEntity?) -> Void)!) {
        
    }
    
    func shouldHandlePersonalInformation(_ personalInfo: NRPersonalInfo!) {
        personalInfo.personalInfoCallback!("works", nil)
    }
    
    
}

extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.size.width, height: 35)))
        view.backgroundColor = UIColor.white
        let button = OptionButton(frame: CGRect(origin: CGPoint(x: 20, y: 5), size: CGSize(width: 120, height: 30)))
        let textColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1)
        button.setTitle("Add Context", for: .normal)
        button.tintColor = textColor
        view.addSubview(button)
        button.setTitleColor(textColor, for: .normal)
        button.addTarget(self, action: #selector(AccountViewController.addContext), for: .touchUpInside)
        return view
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < self.context.count - 1
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

extension AccountViewController: ChatControllerDelegate {
    func shouldPresentChatViewController(_ viewController: UIViewController!) {
        self.chatViewController = viewController
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start Chat", style: .plain, target: self, action: #selector(AccountViewController.presentNanorep(_:))) 
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didFailWithError(_ error: BLDError!) {
        
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
        
        DispatchQueue.main.async {
            if (self.reachability?.isReachable)! {
                let element = Item(item: statement)
                DBManager.sharedInstance.addData(object: element)
            }
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
    
    func didUpdateState(_ event: ChatStateEvent!) {
        if (event.scope == StatementScope.Live) {
            if (ChatState.preparing == event.state) {
                self.chatViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End Chat", style: .plain, target: self, action:#selector(buttonAction))
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
        let remote = RemoteChatElement(type: .IncomingBotElement, content: "Hello from Live Agent: \(String(describing: statement?.text))")
        remote?.design = ChatElementDesignCustomIncoming
        remote?.statementScope = .Live
        
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
        
        reachability.onUnreachable = { [unowned self] reachability in
            print("Warning: network unreachable")
            self.presentNetorkPopup()
        }
        reachability.onReachable = { [unowned self] reachability in
            print("Warning: network reachable")
            
            DispatchQueue.main.async {
//                if let history = DBManager.sharedInstance.getDataFromDB() {
//                    var elements = [StorableChatElement]()
//
//                    for item in history {
//                        print("addReachabilityObserver:: status\(item.status.rawValue)")
//                        if (item.status.rawValue == StatementStatus.Error.rawValue) {
//                            print("item.status: \(item.status)")
//                            print("item.elementId: \(item.ID)")
//                            elements.append(item)
//                        }
//                    }
//
//                    if elements.count > 0 {
//                        self.chatController?.repostStatements(elements)
//                    }
//                }
            }
        }
    }
    
    private func presentNetorkPopup() {
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (action) in
                                            // Respond to user selection of the action
        }
        
        let alert = UIAlertController(title: "network unreachable",
                                      message: "connect to network and reload the app",
                                      preferredStyle: .actionSheet)
        alert.addAction(cancelAction)
        
        // On iPad, action sheets must be presented from a popover.
        alert.popoverPresentationController?.barButtonItem =
            self.startBtn
        
        self.present(alert, animated: true) {
            // The alert was presented
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
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    // Fallback on earlier versions
                }
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

extension AccountViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            self.submitButton.isEnabled = text.count + string.count > 1
        }
        return true
    }
}
