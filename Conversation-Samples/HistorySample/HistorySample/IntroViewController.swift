//
//  IntroViewController.swift
//  HistorySample
//
//  Created by Nissim Pardo on 10/03/2019.
//  Copyright © 2019 bold360ai. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func presentBot(_ sender: OptionButton) {
        let chatController = BotTableViewController()
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    @IBAction func presentSearch(_ sender: OptionButton) {
        let searchViewController = SearchTableViewController()
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
}
