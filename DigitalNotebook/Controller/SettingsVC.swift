//
//  SettingsVC.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit

class SettingsVC: BaseViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet var bottomButtons: [UIButton]!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var pushNotificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = SettingsUserDataManager.shared.fetchUserData(to: SettingsUserDataManager.shared.userImage) as? Data {
            userImage.image = UIImage(data: img)
        }
        checkNotifications()
        userNameTextField.text = CrownNotesAPI.shared.name ?? "Unknown user"
        userEmailTextField.text = CrownNotesAPI.shared.email ?? "Unknown email"
        userImageView.layer.cornerRadius = 12
        userImageView.layer.borderWidth = 1.5
        userImageView.layer.borderColor = UIColor(resource: .accent).cgColor
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(gesture)
    }
    
    @objc func imageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        
    }
    
    @IBAction func emailChanged(_ sender: UITextField) {
        
    }
    
    
    @IBAction func emailNotifChanged(_ sender: UISwitch) {
        SettingsUserDataManager.shared.setUserData(to: SettingsUserDataManager.shared.emailNotification,
                                                   value: sender.isOn)
        checkNotifications()
    }
    
    @IBAction func pushNotifChanged(_ sender: UISwitch) {
        SettingsUserDataManager.shared.setUserData(to: SettingsUserDataManager.shared.pushNotification,
                                                   value: sender.isOn)
        checkNotifications()
    }
    
    @IBAction func bottomButtons(_ sender: UIButton) {
        for btn in bottomButtons {
            if btn.tag == sender.tag {
                btn.alpha = 0.5
            } else {
                btn.alpha = 1.0
            }
        }
        
        switch sender.tag {
        case 0:
            userEmailTextField.isUserInteractionEnabled = true
            userEmailTextField.layer.borderColor = UIColor(resource: .accent).cgColor
            userEmailTextField.layer.borderWidth = 1.5
            userNameTextField.layer.borderWidth = 0.0
            userNameTextField.isUserInteractionEnabled = false
        case 1:
            userNameTextField.isUserInteractionEnabled = true
            userNameTextField.layer.borderColor = UIColor(resource: .accent).cgColor
            userNameTextField.layer.borderWidth = 1.5
            userEmailTextField.layer.borderWidth = 0.0
            userEmailTextField.isUserInteractionEnabled = false
        case 2:
            if let email = CrownNotesAPI.shared.email {
                CrownNotesAPI.shared.deleteUser(email: email, password: CrownNotesAPI.shared.password!) { result in
                    switch result {
                    case .success(let message):
                        print("✅ Success: \(message)")
                        DispatchQueue.main.async {
                            self.popToTopViewController()
                            self.showAlertMessage(title: "Account Deleted", message: "Your account has been deleted")
                        }
                    case .failure(let error):
                        print("❌ Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.showAlertMessage(title: "Deletion Failed", message: error.localizedDescription)
                        }
                    }
                }
            } else {
                popToTopViewController()
                showAlertMessage(title: "Account Deleted", message: "Your account has been deleted")
            }
        case 3:
            CrownNotesAPI.shared.email = nil
            CrownNotesAPI.shared.name = nil
            CrownNotesAPI.shared.password = nil
            popToTopViewController()
            showAlertMessage(title: "Logged out", message: "Your logged out successfully")
        default:
            break
        }
    }
    
    func checkNotifications() {
        let emailNoti = SettingsUserDataManager.shared.fetchUserData(to: SettingsUserDataManager.shared.emailNotification) as! Bool
        let pushNoti = SettingsUserDataManager.shared.fetchUserData(to: SettingsUserDataManager.shared.pushNotification) as! Bool
        emailNotificationSwitch.setOn(emailNoti, animated: true)
        pushNotificationSwitch.setOn(pushNoti, animated: true)
    }
}
extension SettingsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            SettingsUserDataManager.shared.setUserData(to: SettingsUserDataManager.shared.userImage,
                                                       value: image.pngData() as Any)
            userImage.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension UIViewController {
    func presentAlert(title: String, message: String, onOkTapped: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            onOkTapped?()
        }
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
}

