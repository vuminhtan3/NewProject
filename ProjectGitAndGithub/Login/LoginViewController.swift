//
//  LoginViewController.swift
//  ProjectGitAndGithub
//
//  Created by Minh Tan Vu on 30/06/2023.
//

import UIKit
import Alamofire

struct LoginEntity: Codable {
    var userId: String?
    var accessToken: String?
    var refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct LoginError: Codable {
    var type: String?
    var message: String?
}

enum LoginFormField {
    case username
    case password
}

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var usernameWarningLb: UILabel!
    
    @IBOutlet weak var passwordWarningLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTF.text = "tanvm"
        passwordTF.text = "123456"
        usernameWarningLb.isHidden = true
        passwordWarningLb.isHidden = true

        // Do any additional setup after loading the view.
    }

    @IBAction func handleTFTapped(_ sender: UITextField) {
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        let username = usernameTF.text ?? ""
        let password = passwordTF.text ?? ""
        let url = "http://ec2-52-195-148-148.ap-northeast-1.compute.amazonaws.com/login"
        
        AF.request(url,
                   method: .post,
                   parameters: [
                    "username": username,
                    "password": password
                   ],
                   encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200..<300)
        .cURLDescription(calling: { description in
            print(description)
        })
        .responseDecodable(of: LoginEntity.self, completionHandler: { response in
            switch response.result {
            case .success(let loginEntity):
                if let accessToken = loginEntity.accessToken {
                    //Lưu accessToken vào keychain hoặc userdefaults
                    UserDefaults.standard.set(accessToken, forKey: "keyAccessToken")
                } else {
                    //Show lỗi
                }
                //Đi đến màn hình main
                self.routeToMain()
                
            case .failure(let error):
                //Show alert cho người dùng
                if let data = response.data {
                    do {
                        let responseError = try JSONDecoder().decode(LoginError.self, from: data)
                        let alert = UIAlertController(title: "Login Error", message: responseError.message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self.present(alert, animated: true)
                    } catch {
                        print(error)
                    }
                }
            }
        })
    }
    
    @IBAction func registerBtnTapped(_ sender: UIButton) {
        routeToRegister()
    }
    
    private func routeToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let nav = UINavigationController(rootViewController: loginVC)
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else {return}
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    
    private func routeToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else {return}
        
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
    }
    
    private func routeToRegister() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
//        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else {return}
        
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
}
