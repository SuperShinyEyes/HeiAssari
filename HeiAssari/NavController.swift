//
//  NavController.swift
//  HeiAssari
//
//  Created by Park Seyoung on 20/10/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import UIKit

class NavController: UINavigationController {
    
    var backButton: UIBarButtonItem!
    var rootVC: ViewController!
    
    //        nav.navigationItem.leftBarButtonItem = backButton

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func loadButtons(rootVC: ViewController) {
        backButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(rootVC.goBack))
        self.navigationItem.setLeftBarButton(backButton, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
