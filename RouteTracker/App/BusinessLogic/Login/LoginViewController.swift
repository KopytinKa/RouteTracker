//
//  LoginViewController.swift
//  RouteTracker
//
//  Created by Кирилл Копытин on 04.06.2022.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.autocorrectionType = .no
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    
    let realmService = RealmService()
    
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLoginBindings()
    }
    
    // MARK: Private
    private func showLoginError() {
        let alert = UIAlertController(title: "Ошибка", message: "Введены неверные данные пользователя", preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func configureLoginBindings() {
        Observable
            .combineLatest(
                self.loginTextField.rx.text,
                self.passwordTextField.rx.text
            )
            .map { login, password in
                return !(login ?? "").isEmpty && (password ?? "").count >= 6
            }
            .bind { [weak loginButton] inputFilled in
                loginButton?.isEnabled = inputFilled
            }
    }
    
    // MARK: Action
    @IBAction func pressLoginButton(_ sender: UIButton) {
        guard
            let login = loginTextField.text,
            !login.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty
        else { return }
        
        if let users = self.realmService.read(object: UserModel.self, filter: "login == '\(login)'") as? [UserModel],
           let user = users.first,
           user.password == password
        {
            self.onLogin?()
        } else {
            self.showLoginError()
        }
    }
    
    @IBAction func pressRegistrButton(_ sender: UIButton) {
        guard
            let login = loginTextField.text,
            !login.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty
        else { return }
        
        if let users = self.realmService.read(object: UserModel.self, filter: "login == '\(login)'") as? [UserModel],
           let user = users.first
        {
            print("Пользователю \(user.login) будет изменен пароль")
        }
        
        let user = UserModel(login: login, password: password)
        
        self.realmService.add(model: user)
        
        self.onRegister?()
    }
    
    @IBAction func pressSelfieButton(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self

        present(imagePickerController, animated: true)
    }
}

extension LoginViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let image = self?.extractImage(from: info) else { return }
            
        }
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage? {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage? {
            return image
        } else {
            return nil
        }
    }
}
