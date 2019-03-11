//
//  BotTableViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 05/03/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit
import Bold360AI

class BotTableViewController: AccountTableViewController {
    var chatController: ChatController!
    var chatViewController: UIViewController!
    
    var delegate: ChatHandlerDelegate!
    var chatControllerDelegate: ChatControllerDelegate!
    var chatHandlerProvider: ChatHandlerProvider!
    var uploadProvider: FileUploadProvider?
    var continuityProvider: ContinuityProvider?
    var currentChatState: ChatState = .preparing
    var uploadCompletionHandler : ((FileUploadInfo?) -> Void)!
    let imagePicker = UIImagePickerController()


    // MARK: - Table view data source

    
    @objc override func startChat(sender: UIBarButtonItem) {
        super.startChat(sender: sender)
        self.chatController = ChatController(account: self.accountHandler.accountParams)
        self.chatController.delegate = self
        NanoRep.shared().chatDelegate = self
        self.chatController.uploadProvider = self
        self.chatController.handOver = self
        self.chatController.continuityProvider = self
    }

}


extension BotTableViewController: ChatControllerDelegate {
    // MARK: ChatControllerDelegate
    
    func shouldPresentChatViewController(_ viewController: UIViewController!) {
        self.chatViewController = viewController
        self.navigationItem.rightBarButtonItem = self.startChatButton
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didFailWithError(_ error: BLDError!) {
        switch error.type {
        case GeneralErrorType:
            print("GeneralErrorType")
            break
        case BLDChatErrorTypeFailedToStart:
            let alert = UIAlertController(title: "Bold load error", message: "Please check your account parameters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                self.navigationItem.rightBarButtonItem = self.startChatButton
            }

            break
        case BLDChatErrorTypeFailedToFinish:
            print("BLDChatErrorTypeFailedToFinish")
            break
        case BLDChatErrorTypeFailedToSubmitForm:
            print("BLDChatErrorTypeFailedToSubmitForm")
            break
        default:
            break
        }
    }
    
    func shouldHandleFormPresentation(_ formController: UIViewController!) -> Bool {
        return false
    }
    
    func statement(_ statement: StorableChatElement!, didFailWithError error: Error!) {
        guard let _ = statement else {
            return
        }
        
        guard let _ = error  else {
            print("error: \(error)")
            print("statement:: status \(statement.status.rawValue)")
            return
        }
        
//        DispatchQueue.main.async {
//            if (self.reachability?.isReachable)! {
//                let element = Item(item: statement)
//                DBManager.sharedInstance.addData(object: element)
//            }
//        }
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
        return self.accountHandler.withWelcomeMessage
    }
    
//    private func handleWelcomeMsgPresentation() -> Bool {
//        if self.withWelcomeMessage.isOn {
//            return true
//        }
//
//        let welcomeMsgTime = UserDefaults.standard.object(forKey: "WelcomeMsgTime") as? TimeInterval
//        var timeDiff = 0.0;
//
//        if let msgTime = welcomeMsgTime {
//            timeDiff = NSDate().timeIntervalSince1970 - msgTime
//        }
//
//        if welcomeMsgTime == nil || timeDiff > welcomeMsgTimeIteration {
//            // save current time to user defaults
//            UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "WelcomeMsgTime")
//
//            return true
//        }
        
//        return false
//    }
    @objc func buttonAction(sender: UIBarButtonItem!) {
        self.chatController.endChat()
    }
    
    func didUpdateState(_ event: ChatStateEvent!) {
        if (event.scope == StatementScope.Live) {
            if (ChatState.preparing == event.state) {
                self.chatViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End Chat", style: .plain, target: self, action:#selector(buttonAction))
            } else if (ChatState.ended == event.state) {
                self.chatViewController.navigationItem.rightBarButtonItem = nil
            }
        }
        
        switch event.state {
        case .preparing:
            print("ChatPreparing")
        case .started:
            print("ChatStarted")
        case .accepted:
            print("ChatAccepted")
        case .ending:
            print("ChatEnding")
        case .ended:
            print("ChatEnded")
        case .unavailable:
            print("ChatUnavailable")
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
    
//    @objc func buttonAction(sender: UIButton!) {
//        self.chatController.endChat()
//    }
}

extension BotTableViewController: FileUploadProvider {
    func uploadFile(completionHandler: ((FileUploadInfo?) -> Void)!) {
        self.uploadCompletionHandler = completionHandler;
        self.openPhotoLibrary()
    }
    
    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        //        self.navigationController?.performSegue(withIdentifier: "picker", sender: nil)
        self.navigationController?.present(imagePicker, animated: true, completion: nil)
        //        self.chatViewController.present(imagePicker, animated: true, completion: nil)
    }
}

extension BotTableViewController: NRChatEngineDelegate {
    func didFetchConvesationId(_ conversationId: String!) {
        
    }
    
    func shouldHandleMissingEntities(_ response: NRConversationalResponse!, missingEntitiesHandler handler: ((NRConversationMissingEntity?) -> Void)!) {
        
    }
    
    func shouldHandlePersonalInformation(_ personalInfo: NRPersonalInfo!) {
        personalInfo.personalInfoCallback!("works", nil)
    }
    
    
}

extension BotTableViewController: SpeechReconitionDelegate {
    func speechRecognitionStatus(_ status: NRSpeechRecognizerAuthorizationStatus) {
        let alert = UIAlertController(title: "Speech Recognition Error", message: "Please enable speech recognition in Settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        alert.addAction(settingsAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        switch status {
        case .recordingDenied:
            alert.title = "Audio Recording Error"
            alert.message = "Please enable audio recording"
            self.present(alert, animated: true, completion: nil)
        case .denied:
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension BotTableViewController: ChatHandler {
    var isUploadSupported: Bool {
        return false;
    }
    
    func submitForm(_ form: BrandedForm!) {
        
    }
    
    func postArticle(_ articleId: String!) {
        
    }
    
    func startChat(_ chatInfo: [AnyHashable : Any]!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.navigationController?.viewControllers.last?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(AccountViewController.stopLiveChat(sender:))), animated: true)
            self.navigationController?.viewControllers.last?.title = "You're talking with Nisso"
        })
        
    }
    
    func endChat() {
        
    }
    
    func postStatement(_ statement: StorableChatElement!) {
        self.delegate.presentStatement(statement)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate.update(StatementStatus.OK, element: statement)
        }
        let remote = RemoteChatElement(type: .IncomingBotElement, content: "Hello from Live Agent: \(String(describing: statement?.text))")
        remote?.design = ChatElementDesignCustomIncoming
        remote?.statementScope = .Live
        
        // Random delay value for tests
        let random = Double(arc4random_uniform(9) + 1)
        (self.delegate as! NSObject).perform(#selector(ChatHandlerDelegate.presentStatement(_:)), with: remote, afterDelay: random)
    }
    
    func handleClickedLink(_ link: URL!) {
        print(link.absoluteString)
    }
    
    func handleEvent(_ eventParams: [AnyHashable : Any]!) {
        
    }
}

extension BotTableViewController: ContinuityProvider {
    func updateContinuityInfo(_ params: [String : NSNumber]!) {
        print("updateContinuityInfo")
        UserDefaults.standard.setValuesForKeys(params)
        UserDefaults.standard.synchronize()
    }
    
    func fetchContinuity(forKey key: String!, handler: ((NSNumber?) -> Void)!) {
        print("fetchContinuityForKey")
        handler(UserDefaults.standard.value(forKey: key) as? NSNumber)
    }
}

extension BotTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
            print(info)
            let infoFile = FileUploadInfo()
            infoFile.fileDescription = "<p><a target='_blank' href='https://www.weightwatchers.com/us/find-a-meeting/'>https://www.weightwatchers.com/us/find-a-meeting/</a></p>"
            self.uploadCompletionHandler(infoFile)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
            let infoFile = FileUploadInfo()
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"file failed to upload"])
            infoFile.error = error
            
            self.uploadCompletionHandler(infoFile)
        }
        
        print("did cancel")
    }
}
