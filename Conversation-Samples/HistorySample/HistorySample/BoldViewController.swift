//
//  BoldViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 07/01/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit
import Bold360AI

class BoldViewController: UIViewController {
    var chatController: ChatController!
    var chatViewController: UIViewController!
    
    @IBOutlet weak var accessKey: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentBold(_ sender: UIBarButtonItem) {
        let account = BCAccount(accessKey: self.accessKey.text)
        self.chatController = ChatController(account: account)
        let font = CustomFont()
        font.fontFileName = "Monotype Sabon Italic.otf"
        font.font = UIFont(name: "MonotypeSabonW04-Italic", size: 20)
        for family: String in UIFont.familyNames {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
        self.chatController.viewConfiguration.outgoingConfig.customFont = font
        self.chatController.delegate = self
    }

}

extension BoldViewController: ChatControllerDelegate {
    func shouldPresentChatViewController(_ viewController: UIViewController!) {
        self.chatViewController = viewController
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(AccountViewController.presentNanorep(_:)))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didFailLoadChatWithError(_ error: Error!) {
        
    }
    
    
    func shouldHandleFormPresentation(_ formController: UIViewController!) -> Bool {
        return false
    }
    
    func statement(_ statement: StorableChatElement!, didFailWithError error: Error!) {
        guard let _ = statement else {
            return
        }
        print("error: \(error)")
        print("statement:: status \(statement.status.rawValue)")
        DispatchQueue.main.async {
            let element = Item(item: statement)
            DBManager.sharedInstance.addData(object: element)
        }
    }
    
    func didClickLink(_ url: String!) {
        if let link = URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
            
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
    
    func shouldPresentWelcomeMessage() -> Bool {
        return true
    }
    
    func didUpdate(_ state: ChatState, with statementScope: StatementScope) {
        if (statementScope == StatementScope.Live) {
            if (ChatState.preparing == state) {
                self.chatViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End Chat", style: .plain, target: self, action:#selector(buttonAction))
            } else if (ChatState.ended == state) {
                self.chatViewController.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func shouldPresent(_ form: BrandedForm!, handler completionHandler: (((UIViewController & BoldForm)?) -> Void)!) {
        if (completionHandler != nil) {
            if form.form?.type == BCFormTypePostChat {
                let postVC = self.storyboard?.instantiateViewController(withIdentifier: "postChat") as! PostChatViewController
                postVC.form = form
                completionHandler(postVC)
            } else if (form.form?.type == BCFormTypeUnavailable) {
                let unavailableVC = self.storyboard?.instantiateViewController(withIdentifier: "unavailable") as! UnavailableViewController
                unavailableVC.form = form
                completionHandler(unavailableVC)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        self.chatController.endChat()
    }
}
