//
//  LoginVC.swift
//  DigitalNotebook
//
//  Created by Developer on 22/05/25.
//

import UIKit

class LoginVC: BaseViewController {
    @IBOutlet weak var emailTextField: CustomStyledTextField!
    @IBOutlet weak var passwordTextField: CustomStyledTextField!
    
    private let navigator = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func firstTimeInAppTapped(_ sender: UIButton) {
        popViewController()
    }
    
    @IBAction func loginGotClicked(_ sender: UIButton) {
        if let email = emailTextField.text, email != "",
           let password = passwordTextField.text, password != "" {
            if isValidCredentials(email: email, password: password) {
                CrownNotesAPI.shared.login(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let (message, name)):
                            print("✅ \(message), Welcome \(name)")
                            if message == "Login successful" {
                                CrownNotesAPI.shared.email = email
                                CrownNotesAPI.shared.name = name
                                CrownNotesAPI.shared.password = password
                                let registerNavigator = TabBarVC()
                                registerNavigator.modalPresentationStyle = .fullScreen
                                self.passwordTextField.text = ""
                                self.emailTextField.text = ""
                                self.push(vc: registerNavigator)
                            } else {
                                self.showAlertMessage(title: "Error", message: "")
                            }
                            
                        case .failure(let error):
                            print("❌ \(error.localizedDescription)")
                            self.showAlertMessage(title: "Error in Login",
                                                  message: error.localizedDescription)
                        }
                    }
                }
            } else {
                showAlertMessage(title: "Error in Sign in",
                                      message: "Email or password  is not in a suitable format")
            }
        }
    }
    
    @IBAction func loginAsGuestGotClicked(_ sender: UIButton) {
        let registerNavigator = TabBarVC()
        registerNavigator.modalPresentationStyle = .fullScreen
        emailTextField.text = ""
        passwordTextField.text = ""
        push(vc: registerNavigator)
    }

    func isValidCredentials(email: String, password: String) -> Bool {
        // Check password length
        guard password.count > 5 else { return false }
        
        // Check if email is valid using NSPredicate
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@",
            "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
}
