// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import Foundation

/************************************************************/
// MARK: - AccountParamsHelper
/************************************************************/

class AccountParamsHelper {
    static var accountParamsPath: String?
    
    struct accountParamsKeys {
        static let Account = "account"
        static let KnowledgeBase = "knowledgeBase"
        static let ApiKey = "apiKey"
        static let NanorepContext = "nanorepContext"
        static let ChatContentURL = "chatContentURL"
        static let Server = "server"
    }
    
    static func getLocalParams() -> [String : [String]] {
        if let paramsPath  = getAcountParamsPath("MyAccountParams") {
            accountParamsPath = paramsPath
        } else {
            accountParamsPath = getAcountParamsPath("AccountParams")
            
            if !checkAccountParamsExist() {
                assertionFailure("Your 'AccountParams.plist' is Empty! Please open file and fill all fields.")
            }
        }
       
        return contentsOfFileDict()
    }
    
    static func getAcountParamsPath(_ fileName: String) -> String? {
        return Bundle.main.path(forResource: fileName, ofType: "plist")
    }
    
    private static func contentsOfFileDict() -> [String : [String]] {
        return NSDictionary(contentsOfFile: accountParamsPath!)! as! [String : [String]]
    }
    
    private static func checkAccountParamsExist() -> Bool {
        if (contentsOfFileDict()[accountParamsKeys.Account]?.count)! > 0 {
            return true
        }
        
        return false
    }
}
