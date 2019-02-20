//
//  IntroViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 20/02/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var botButton: UIButton!
    @IBOutlet weak var boldButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.botButton.layer.cornerRadius = 5
        self.botButton.layer.borderColor = self.botButton.tintColor.cgColor
        self.botButton.layer.borderWidth = 1
        self.boldButton.layer.cornerRadius = 5
        self.boldButton.layer.borderColor = self.botButton.tintColor.cgColor
        self.boldButton.layer.borderWidth = 1

        // Do any additional setup after loading the view.
    }
    @IBAction func presentOption(_ sender: UIButton) {
        sender.backgroundColor = sender.tintColor
        sender.setTitleColor(UIColor.white, for: .normal)
        if let segueId = sender.titleLabel?.text {
            self.perform(#selector(IntroViewController.presentBold(params:)), with: [segueId, sender], afterDelay: 0.2)
        }
    }
    
    @objc func presentBold(params:[Any]) {
        self.performSegue(withIdentifier: params.first as! String, sender: params.last)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let button = (sender as? UIButton) {
            button.setTitleColor(button.tintColor, for: .normal)
            button.backgroundColor = UIColor.white
            
        }
        
    }
    

}
