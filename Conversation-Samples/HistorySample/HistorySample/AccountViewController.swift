//
//  AccountViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 31/10/2018.
//  Copyright © 2018 bold360ai. All rights reserved.
//

import UIKit
import BoldAIEngine

class AccountViewController: UIViewController {
    
    var context = [["": ""]]
    var canAddContext: Bool = false
    
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var kb: UITextField!
    @IBOutlet weak var apiKey: UITextField!
    @IBOutlet weak var contextTableView: UITableView!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AccountViewController.updateHeight(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AccountViewController.updateHeight(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let account = AccountParams()
        account.account = self.accountName.text
        account.knowledgeBase = self.kb.text
        if (self.apiKey.text?.count)! > 0 {
            account.apiKey = self.apiKey.text
        }
        
        var temp = [String: String]()
        self.context.forEach { (val) in
            temp[val.keys.first!] = val.values.first
        }
        account.nanorepContext = temp
        (segue.destination as! ViewController).accountParams = account
    }
    
    @objc func updateHeight(notification: Notification)  {
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            self.keyboardConstraint.constant = 0
        } else {
            let height = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
            self.keyboardConstraint.constant = height
        }
    }
    
    @objc func addContext() {
        if self.canAddContext  {
            self.canAddContext = false
            self.context.append(["" : ""])
            let indexPath = IndexPath(row: self.context.count - 1, section: 0)
            self.contextTableView.beginUpdates()
            self.contextTableView.insertRows(at: [indexPath], with: .bottom)
            self.contextTableView.endUpdates()
            self.contextTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    

}

extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.size.width, height: 44)))
        view.backgroundColor = UIColor.lightGray
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.size.width, height: 44)))
        button.setTitle("Add Context", for: .normal)
        view.addSubview(button)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(AccountViewController.addContext), for: .touchUpInside)
        return view
    }
}

extension AccountViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        (cell as! ContextTableViewCell).context = self.context[indexPath.row]
        (cell as! ContextTableViewCell).delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.context.count
    }
    
    
}

extension AccountViewController: ContextTableViewCellDelegate {
    func updateContext(forCell: ContextTableViewCell!, context: [String : String]) {
        self.canAddContext = true
        if let index = self.contextTableView.indexPath(for: forCell)?.row {
            self.context[index] = context
        }
    }
}
