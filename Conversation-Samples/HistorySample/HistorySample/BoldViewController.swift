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
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var accessKey: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openPhotoLibrary()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        //        self.navigationController?.popViewController(animated: false)
//        self.navigationController?.performSegue(withIdentifier: "picker", sender: nil)
        //        self.navigationController?.present(imagePicker, animated: true, completion: nil)
        //        self.chatViewController.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func presentBold(_ sender: OptionButton) {
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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(AccountViewController.presentNanorep(_:)))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didFailWithError(_ event: BLDError!) {
        
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
    
    func didUpdateState(_ event: ChatStateEvent!) {
        if (event.scope == StatementScope.Live) {
            switch event.state {
            case .preparing:
                print("ChatPreparing")
                self.chatViewController.navigationItem.rightBarButtonItem =
                    UIBarButtonItem(title: "End Chat", style: .plain, target: self, action:#selector(buttonAction))
            case .started:
                print("ChatStarted")
            case .accepted:
                print("ChatAccepted")
            case .ending:
                print("ChatEnding")
            case .ended:
                print("ChatEnded")
                self.navigationController?.popViewController(animated: true)
            case .unavailable:
                print("ChatUnavailable")
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
    
    override func viewDidDisappear(_ animated: Bool) {
        self.chatController?.endChat()
        super.viewDidDisappear(animated)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        self.chatController?.terminate()
    }
}

extension BoldViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //        defer {
        //            picker.dismiss(animated: true)
        //        }
        
        print(info)
        picker.dismiss(animated: true, completion: nil)
        // get the image
        //        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
        //            return
        //        }
        //
        // do something with it
        //        imageView.image = image
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //        defer {
        //            picker.dismiss(animated: true)
        //        }
        
        print("did cancel")
        
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
