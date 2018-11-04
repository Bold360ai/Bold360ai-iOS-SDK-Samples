//
//  ContextTableViewCell.swift
//  HistorySample
//
//  Created by Nissim Pardo on 31/10/2018.
//  Copyright © 2018 bold360ai. All rights reserved.
//

import UIKit

protocol ContextTableViewCellDelegate {
    func updateContext(forCell: ContextTableViewCell!, context: [String: String])
}

class ContextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var val: UITextField!
    
    var delegate: ContextTableViewCellDelegate!
    var context: [String: String]! {
        willSet {
            self.name.text = newValue.keys.first
            self.val.text = newValue.values.first
        }
    }
    
    var isValid: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.name.becomeFirstResponder()
    }

    

}

extension ContextTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var name = self.name.text!
        var value = self.val.text!
        if textField == self.name {
            name += string
        } else {
            value += string
        }
        let isValid = name.count > 0 && value.count > 0
        if isValid {
//            context[name] = value
            self.delegate.updateContext(forCell: self, context: [name: value])
        }
        return true
    }
}
