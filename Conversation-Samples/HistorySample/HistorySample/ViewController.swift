// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import UIKit
import NanorepUI
//import RealmSwift

class ViewController: UIViewController, HistoryProvider, NRChatControllerDelegate, ChatHandler  {
    var delegate: ChatHandlerDelegate!
    
    var chatControllerDelegate: NRChatControllerDelegate!
    var chatHandlerProvider: ChatHandlerProvider!
    
    func handleClickedLink(_ link: URL!) {
        
    }
    
    func handleEvent(_ eventParams: [AnyHashable : Any]!) {
        
    }
    
    private let accountParams = AccountParams()
    var chatController: NRChatController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountParams.account = "jio"
        self.accountParams.knowledgeBase = "Staging"
        self.accountParams.apiKey = "8bad6dea-8da4-4679-a23f-b10e62c84de8"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.accountParams.account = "jio"
        self.accountParams.knowledgeBase = "Staging"
        self.accountParams.apiKey = "8bad6dea-8da4-4679-a23f-b10e62c84de8"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadNanorep(_ sender: UIButton) {
        let config: NRBotConfiguration = NRBotConfiguration()
//        config.chatContentURL = URL.init(string:"http://192.168.9.245:8000/Desktop/Repos/iOS/ConversationalWebView/v2/view-rbs.html")
        let accountParams = AccountParams()
        accountParams.account = "rbs"
        accountParams.knowledgeBase = "MyKnowledgeMobile"
        accountParams.apiKey = "2fdce18f-4e7d-4517-8f72-4db07c755939"
        accountParams.nanorepContext = ["UserRole": "Branch_Banking_NatWest"]
        accountParams.perform(Selector.init("setServer:"), with: "eu1-4")
        self.chatController = NRChatController(account: accountParams)
        config.chatContentURL = URL.init(string:"http://10.228.220.38:8000/Repos/Web/ConversationalWebView/v3/view-rbs.html")
        config.withNavBar = true
        // TODO: under config pass id
        self.chatController.delegate = self
        self.chatController.handOver = self
        self.chatController.uiConfiguration = config
        self.chatController.historyProvider = self
        self.chatController.initialize = { controller, configuration, error in
            if let vc = controller {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @IBAction func deleteHistory(_ sender: Any) {
        DBManager.sharedInstance.deleteAllDatabase()
    }
    
    @objc func stopLiveChat(sender: UIBarButtonItem) {
        self.navigationController?.viewControllers.last?.navigationItem.setRightBarButton(nil, animated: true)
        self.navigationController?.viewControllers.last?.title = "Bye .."
        self.navigationController?.viewControllers.last?.perform(#selector(setter: UIViewController.title), with: nil, afterDelay: 2)
        self.chatHandlerProvider.didEndChat(self)
    }
    

    var historyElements = [String: Array<StorableChatElement>]()
    
    func fetch(_ from: Int, handler: (([Any]?) -> Void)!) {
        print("fetch")
        
        var elements: Array<StorableChatElement>!
        
        if(DBManager.sharedInstance.getDataFromDB().count > 0) {
            let items = DBManager.sharedInstance.getDataFromDB()
          //  let elements = historyElements.values.first
            
            elements = Array(items)
        }
        handler(elements)
    }
    
    func store(_ item: StorableChatElement) {
        print("store")

        let element = Item(item: item)
        element.ID = Int(DBManager.sharedInstance.getDataFromDB().count)
        DBManager.sharedInstance.addData(object: element)
    }
    
    func remove(_ timestampId: TimeInterval) {
        print("remove")
        
        DBManager.sharedInstance.deleteAllDatabase()
    }
    
    func update(_ timestampId: TimeInterval, newTimestamp: TimeInterval, status: StatementStatus) {
        print("update")
    }
    
    //MARK: ChatHandler
    
    func startChat(_ chatInfo: [AnyHashable : Any]!) {
        self.navigationController?.viewControllers.last?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ViewController.stopLiveChat(sender:))), animated: true)
        self.navigationController?.viewControllers.last?.title = "You're talking with Nisso"
    }
    
    func endChat() {
        
    }
    
    func postStatement(_ statement: StorableChatElement!) {
        self.delegate.presentStatement(statement)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate.update(StatementStatus.Error, element: statement)
        }
        let remote = RemoteChatElement(type: .RemoteElement, content: "Hello from Live Agent")
        remote?.design = ChatElementDesignCustomIncoming
        remote?.agentType = .Live
        
        (self.delegate as! NSObject).perform(#selector(ChatHandlerDelegate.presentStatement(_:)), with: remote, afterDelay: 4)
    }
    
    //MARK: NRChatControllerDelegate
    
    func shouldHandleFormPresentation(_ formController: UIViewController!) -> Bool {
        return true
    }
    
    func didFailWithError(_ error: Error!) {
        
    }
    
    func didClickLink(_ url: String!) {
        if let link = URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!) {
            
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
}

