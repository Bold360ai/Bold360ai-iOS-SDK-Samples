// ===================================================================================================
// Copyright © 2018 nanorep.
// NanorepUI SDK.
// All rights reserved.
// ===================================================================================================

import UIKit
import Bold360AI

class UnavailableViewController: UITableViewController {
    @IBOutlet var formTitle: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBAction func startTapped(_ sender: Any) {
        
        var x = 0
        let index = IndexPath(row: x, section: 0)
        
        
        for infoField in (formInfo.form?.formFields)! {
            (infoField as! BCFormField).value = (self.tableView.cellForRow(at: index) as! TextCell).txtField.text
            x += 1
        }
        self.delegate.submitForm(formInfo)
    }
    
    override func viewDidLoad() {
        self.formTitle.text = "Sorry, we can’t chat right now. Please send an email using the form below."
        self.startBtn.setTitle("Send", for: .normal)
    }
    
    var formInfo: BrandedForm!
    var formDelegate: BoldFormDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formInfo.form.formFields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let field = formInfo.form?.formFields[indexPath.row] as? BCFormField {
            if field.type == BCFormFieldTypeEmail || field.type == BCFormFieldTypeText {
                let cell: TextCell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
                cell.txtField.placeholder = field.label

                return cell
            }
        }
        
        return UITableViewCell()
    }
}

extension UnavailableViewController: BoldForm {
    var form: BrandedForm! {
        get {
            return formInfo
        }
        set(form) {
            formInfo = form
        }
    }
    
    var delegate: BoldFormDelegate! {
        get {
            return formDelegate
        }
        set(delegate) {
            formDelegate = delegate
        }
    }
}
