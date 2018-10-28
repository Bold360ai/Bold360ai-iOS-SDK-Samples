// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import UIKit
import BoldUI
import RealmSwift

/************************************************************/
// MARK: - ViewController
/************************************************************/

// The Time Between Welcome Message Presantation
let welcomeMsgTimeIteration = 30.0

class ViewController: UIViewController {
    /************************************************************/
    // MARK: - Properties
    /************************************************************/
    
    var delegate: ChatHandlerDelegate!
    var chatControllerDelegate: NRChatControllerDelegate!
    var chatHandlerProvider: ChatHandlerProvider!
    var historyElements = [String: Array<StorableChatElement>]()
    let historyStatementsDB = DBManager.sharedInstance
    let localAccountParams = AccountParamsHelper.getLocalParams()
    let userDefaults = UserDefaults.standard
    
    private var accountParams: AccountParams?
    var chatController: NRChatController!
    // Every bot controller that is created should own Reachability instance
    let reachability = Reachability()
    
    @IBOutlet weak var accountPickerView: UIPickerView!
    @IBOutlet weak var welcomeMsgSwitch: UISwitch!
    
    /************************************************************/
    // MARK: - Functions
    /************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addReachabilityObserver()
        self.accountPickerView.delegate = self
        self.accountPickerView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAccountParams() -> AccountParams {
        let params = AccountParams()
        let index = accountPickerView.selectedRow(inComponent: 0)
        
        params.account = localAccountParams[AccountParamsHelper.accountParamsKeys.Account]?[index]
        params.knowledgeBase = localAccountParams[AccountParamsHelper.accountParamsKeys.KnowledgeBase]?[index]
        params.apiKey = localAccountParams[AccountParamsHelper.accountParamsKeys.ApiKey]?[index]
        params.nanorepContext = ["UserRole": localAccountParams[AccountParamsHelper.accountParamsKeys.NanorepContext]?[index]] as! [String : String]
        params.perform(Selector.init(("setServer:")), with: localAccountParams[AccountParamsHelper.accountParamsKeys.Server]?[index])
        
        return params
    }
    
    @objc func stopLiveChat(sender: UIBarButtonItem) {
        self.navigationController?.viewControllers.last?.navigationItem.setRightBarButton(nil, animated: true)
        self.navigationController?.viewControllers.last?.title = "Bye .."
        self.navigationController?.viewControllers.last?.perform(#selector(setter: UIViewController.title), with: nil, afterDelay: 2)
        self.chatHandlerProvider.didEndChat(self)
    }
    
    /************************************************************/
    // MARK: - Actions
    /************************************************************/
    
    @IBAction func loadNanorep(_ sender: UIButton) {
        let index = accountPickerView.selectedRow(inComponent: 0)
        let config: NRBotConfiguration = NRBotConfiguration()
        self.accountParams = self.setupAccountParams()
        self.chatController = NRChatController(account: self.accountParams)
        config.chatContentURL = URL.init(string:(AccountParamsHelper.getLocalParams()[AccountParamsHelper.accountParamsKeys.ChatContentURL]?[index])!)
        config.withNavBar = true
        self.chatController.delegate = self
        self.chatController.handOver = self
        self.chatController.uiConfiguration = config
        self.chatController.historyProvider = self
        self.chatController.speechReconitionDelegate = self
        self.chatController.initialize = { controller, configuration, error in
            if let vc = controller {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func deleteHistory(_ sender: Any) {
        self.historyStatementsDB.deleteAllDatabase()
    }
    
    
    @IBAction func welcomeMsgStateChanged(_ sender: Any) {
        
    }
}

/************************************************************/
// MARK: - Reachability & Application States Handling
/************************************************************/

extension ViewController {
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
                if(self.historyStatementsDB.getDataFromDB().count > 0) {
                    let items = self.historyStatementsDB.getDataFromDB()
                    var elements = [StorableChatElement]()
                    
                    for item in items {
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
// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
/************************************************************/

extension ViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let localAccountParams = AccountParamsHelper.getLocalParams()
        return (localAccountParams[AccountParamsHelper.accountParamsKeys.Account]?.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return localAccountParams[AccountParamsHelper.accountParamsKeys.Account]?[row]
    }
}

/************************************************************/
// MARK: - ChatHandler
/************************************************************/

extension ViewController: ChatHandler {
    func startChat(_ chatInfo: [AnyHashable : Any]!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.navigationController?.viewControllers.last?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ViewController.stopLiveChat(sender:))), animated: true)
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
        let remote = RemoteChatElement(type: .RemoteElement, content: "Hello from Live Agent: \(String(describing: statement?.text))")
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
// MARK: - NRChatControllerDelegate
/************************************************************/

extension ViewController: NRChatControllerDelegate {
    
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
            self.historyStatementsDB.addData(object: element)
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
        if self.welcomeMsgSwitch.isOn {
            return false
        }
        
        let welcomeMsgTime = UserDefaults.standard.object(forKey: "WelcomeMsgTime") as? TimeInterval
        var timeDiff = 0.0;
        
        if let msgTime = welcomeMsgTime {
            timeDiff = NSDate().timeIntervalSince1970 - msgTime
        }
        
        if welcomeMsgTime == nil || timeDiff > welcomeMsgTimeIteration {
            // save current time to user defaults
            self.userDefaults.set(NSDate().timeIntervalSince1970, forKey: "WelcomeMsgTime")
            
            return true
        }
        
        return false
    }
}

/************************************************************/
// MARK: - HistoryProvider
/************************************************************/

extension ViewController: HistoryProvider {
    func fetch(_ from: Int, handler: (([Any]?) -> Void)!) {
        print("fetch")

        DispatchQueue.main.async {
            var elements: Array<StorableChatElement>!
            
            if(self.historyStatementsDB.getDataFromDB().count > 0) {
                let items = self.historyStatementsDB.getDataFromDB()                
                elements = Array(items)
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
            self.historyStatementsDB.addData(object: element)
        }
    }
    
    func remove(_ timestampId: TimeInterval) {
        print("remove")
        
        DispatchQueue.main.async {
            self.historyStatementsDB.deleteAllDatabase()
        }
    }
    
    func update(_ timestampId: TimeInterval, newTimestamp: TimeInterval, status: StatementStatus) {
        print("update")
    }
}

extension ViewController: SpeechReconitionDelegate {
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
