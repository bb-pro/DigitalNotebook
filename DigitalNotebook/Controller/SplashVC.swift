//
//  ViewController.swift
//  DigitalNotebook
//
//  Created by Developer on 22/05/25.
//

import UIKit

class SplashVC: BaseViewController {

    let navigator = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func getStartedTapped(_ sender: UIButton) {
        if let signUpVC = navigator.instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
            push(vc: signUpVC)
        }
    }
    
    @IBAction func pushToRegister(_ sender: UIButton) {
        if let loginVC = navigator.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            push(vc: loginVC)
        }
    }
}

