// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import Foundation
import RealmSwift
import NanorepUI

class Item: Object, StorableChatElement {
   
    convenience init(item: StorableChatElement) {
        self.init()
        self.storageKey = item.storageKey
        self.agentType = item.agentType
        self.status = item.status
        self.timestamp = item.timestamp
        self.content = item.content
    }
    
    var storageKey: String! = ""
    
    var agentType: AgentType = AgentType.Bot
    
    var status: StatementStatus = StatementStatus.Pending
    
    var type: ChatElementType = ChatElementType.LocalElement
    
    var timestamp: TimeInterval = 0.0
    
    var content: String! = ""
    
    
    @objc dynamic var ID = -1
    @objc dynamic var textString = ""
    
    override static func primaryKey() -> String? {
        return "ID"
    }
    
}
