// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import UIKit
import NanorepUI
//import RealmSwift

class ViewController: UIViewController, HistoryProvider {
    private let accountParams = AccountParams()
    
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
        config.chatContentURL = URL.init(string:"https://cdn-customers.nanorep.com/v3/view-rbs.html")
        config.withNavBar = true
        // TODO: under config pass id
        let controller: NRConversationalViewController =
            NRConversationalViewController(accountParams: self.accountParams)
        controller.configuration = config
        controller.historyProvider = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func deleteHistory(_ sender: Any) {
        DBManager.sharedInstance.deleteAllDatabase()
    }
    

    var historyElements = [String: Array<StorableChatElement>]()
    
    func fetch(_ from: Int, handler: (([Any]?) -> Void)!) {
        print("fetch")
        
        
        if(DBManager.sharedInstance.getDataFromDB().count > 0) {
            let items = DBManager.sharedInstance.getDataFromDB()
          //  let elements = historyElements.values.first
            
            let elements = Array(items)
            handler(elements)
        }
    }
    
    func store(_ item: StorableChatElement) {
        print("store")

        let element = Item(item: item)
        element.ID = Int(item.timestamp)
        DBManager.sharedInstance.addData(object: element)
    }
    
    func remove(_ timestampId: TimeInterval) {
        print("remove")
        
        DBManager.sharedInstance.deleteAllDatabase()
    }
    
    func update(_ timestampId: TimeInterval, newTimestamp: TimeInterval, status: StatementStatus) {
        print("update")
    }
}

