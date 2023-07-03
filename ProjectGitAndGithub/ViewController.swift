//
//  ViewController.swift
//  ProjectGitAndGithub
//
//  Created by Minh Tan Vu on 30/06/2023.
//

import UIKit
import Alamofire
struct RegisterResponse: Decodable {
    var userId: String?
    var accessToken: String?
    var refreshToken: String?
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}


class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.placeholder = "Username"
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
    }
    
    @IBAction func resgisterClick(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let name = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        AF.request("http://ec2-52-195-148-148.ap-northeast-1.compute.amazonaws.com/register",
                   method: .post,
                   parameters: [
                    "username": username,
                    "name": name,
                    "password": password
                   ], encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: RegisterResponse.self,completionHandler: { response in
            switch response.result {
            case .success( let data):
                print("success")
                if let accessToken = data.accessToken {
                    // luu
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(accessToken, forKey: "myKeyAccessToken")
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let homeVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
                    guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else {return}
                    window.rootViewController = homeVC
                    window.makeKeyAndVisible()
                    
                } else {
                    let alert = UIAlertController(title: "Title", message: "Register failure", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        if let message = json?["message"] as? String {
                            let alert = UIAlertController(title: "Title", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }catch {
                        print("errorMsg")
                    }
                }
            }
        })
    }
}
                           
