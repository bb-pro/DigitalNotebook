//
//  SignUpVC.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit

class SignUpVC: BaseViewController {
    @IBOutlet weak var nameTextField: CustomStyledTextField!
    @IBOutlet weak var emailTextField: CustomStyledTextField!
    @IBOutlet weak var passwordTextField: CustomStyledTextField!
    
    private let navigator = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func dismissViewButton(_ sender: UIButton) {
        popViewController()
    }
    
    @IBAction func loginGotTapped(_ sender: UIButton) {
        // here i should initialize and set user data
        if let email = emailTextField.text, email != "",
           let password = passwordTextField.text,  password != "",
           let name = nameTextField.text, name != "" {
            if isValidCredentials(email: email, password: password) {
                CrownNotesAPI.shared.registerUser(email: email, name: name, password: password) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let message):
                            print("✅ \(message), Welcome \(name)")
                            if message == "User registered" {
                                CrownNotesAPI.shared.email = email
                                CrownNotesAPI.shared.name = name
                                CrownNotesAPI.shared.password = password

                                let registerNavigator = TabBarVC()
                                registerNavigator.modalPresentationStyle = .fullScreen
                                self.nameTextField.text = ""
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                                self.push(vc: registerNavigator)
                            } else {
                                self.showAlertMessage(title: "Error", message: "")
                            }
                        case .failure(let error):
                            print("❌ \(error.localizedDescription)")
                            self.showAlertMessage(title: "Error in Sign up",
                                                  message: error.localizedDescription)
                        }
                    }
                }
            } else {
                showAlertMessage(title: "Error in Sign up",
                                      message: "Email or password  is not in a suitable format")
            }
        }
    }
    
    @IBAction func loginAsGuestGotTapped(_ sender: UIButton) {
        let registerNavigator = TabBarVC()
        registerNavigator.modalPresentationStyle = .fullScreen
        nameTextField.text = ""
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
