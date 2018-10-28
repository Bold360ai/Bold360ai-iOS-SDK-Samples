// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import Foundation
import RealmSwift
import BoldUI

class DBManager {
    
    private var database:Realm
    static let sharedInstance = DBManager()
    
    private init() {
        database = try! Realm()
    }
    
    func getDataFromDB() -> Results<Item> {
        let results: Results<Item> =  database.objects(Item.self)
        return results
    }
    
    func addData(object: Item) {
        try! database.write {
            database.add(object, update: true)
            print("Added new object")
        }
    }
    
    func deleteAllDatabase()  {
        do {
            try database.write({
                database.deleteAll()
            })
        } catch  {
            print("error")
        }
    }
    
    func deleteFromDb(object: Item) {
        try! database.write {
            database.delete(object)
        }
    }
}
