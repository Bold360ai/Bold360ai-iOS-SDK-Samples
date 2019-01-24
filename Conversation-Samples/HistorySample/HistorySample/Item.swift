// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import Foundation
import RealmSwift
import Bold360AI
import Realm

class Item: Object, StorableChatElement {
    convenience init(item: StorableChatElement) {
        self.init()
        self.elementId = item.elementId
        self.storageKey = item.storageKey
        self.agentType = item.agentType
        self.status = item.status
        self.timestamp = item.timestamp
        self.text = item.text
        self.source = item.source
        self.elementId = item.elementId
        self.ID = item.elementId.intValue
    }

//    required init() {
//        self.agentType = .None
//        self.status = .Pending
//        self.type = .LocalElement
//        self.source = .history
//        super.init()
//        print("init() has not been implemented")
//    }
//
//    required init(realm: RLMRealm, schema: RLMObjectSchema) {
//        print("init(realm:schema:) has not been implemented")
//        self.agentType = .None
//        self.status = .Error
//        self.type = .LocalElement
//        self.source = .history
//        super.init(realm: realm, schema: schema)
//    }
//
//    required init(value: Any, schema: RLMSchema) {
//        print("init(value:schema:) has not been implemented")
//        self.agentType = .None
//        self.status = .Error
//        self.type = .LocalElement
//        self.source = .history
//        super.init(value: value, schema: schema)
//    }
    
    dynamic var timestamp: Date!
    dynamic var storageKey: String!
    dynamic var agentType: AgentType = .Bot
    dynamic var status: StatementStatus = .Pending
    dynamic var type: ChatElementType = .OutgoingElement
    dynamic var text: String!
    dynamic var source: ChatElementSource = .history
    dynamic var elementId: NSNumber = 0.0
    dynamic var removable: Bool = false
    @objc dynamic var configuration: ChatElementConfiguration = ChatElementConfiguration()
    
    @objc dynamic var ID: Int = -1
//    @objc dynamic var textString: String!
    
    override static func primaryKey() -> String? {
        return "ID"
    }
}
