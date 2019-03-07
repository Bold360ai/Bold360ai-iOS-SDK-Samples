//
//  SwitchTableViewCell.swift
//  HistorySample
//
//  Created by Nissim Pardo on 05/03/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit

class SwitchTableViewCell: AccountDataTableViewCell {

    @IBOutlet weak var withWelcome: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    override var data: InputItemModel? {
        didSet {
            self.label.text = self.data?.hint
            if let isOn = self.data?.value as? Bool {
                self.withWelcome.isOn = isOn
            }
        }
    }

}
