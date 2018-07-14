//
//  ViewController.swift
//  Chat
//
//  Created by Kaiyuan Yu on 12/7/17.
//  Copyright © 2017 Kaiyuan Yu. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuthUI
import Firebase

class LoginViewController: UIViewController,FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var usrnameTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    var FBLoginButton : FBSDKLoginButton!
    
    var loggedin:Bool? = false
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                //login failed
                let alert = UIAlertController(title: "Error", message: "Login failed", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    //nothing happens
                }
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                print(error.localizedDescription)
                self.loggedin = false
                return
            }
            // User is signed in
            // ...
            print("Successfully logged in with facebook")
            self.loggedin = true
            let newUser = Database.database().reference().child("users").child(user!.uid)
            newUser.setValue(["displayname" : "\(user!.displayName!)", "id" : "\(user!.uid)",
                "profileUrl": "\(user!.photoURL!)"])
            self.goToChatView()
        }
    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    
    @IBOutlet weak var orBar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //print("facebook user id: " + FBSDKAccessToken.current().userID)
        let FBLoginButton = FBSDKLoginButton()
        FBLoginButton.delegate = self
        FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        let X_Position:CGFloat = orBar.frame.origin.x+125
        let Y_Position:CGFloat = orBar.frame.origin.y+130
        
        FBLoginButton.center = CGPoint.init(x:X_Position, y:Y_Position)
        self.view.addSubview(FBLoginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            // ...
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
    }

    @IBAction func LoginButtonTapped(_ sender: Any) {
        print("Login tapped")
        let email = usrnameTF.text
        let password = passwordTF.text
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Login failed, check your email and password!", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    //nothing happens
                }
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                
                print(error.localizedDescription)
                return
            }
            //login success, go to main view
            self.loggedin = true
            let newUser = Database.database().reference().child("users").child(user!.uid)
            newUser.setValue(["displayname" : "\(email)", "id" : "\(user!.uid)",
                "profileUrl": ""])
            self.goToChatView()
            print("logged in with email")
            
        }
        
    }
    
    @IBAction func SignupButtonTapped(_ sender: Any) {
        print("Sign up tapped")
        let email = usrnameTF.text
        let password = passwordTF.text
        if(email!.contains("@") == false || password!.count < 6){
            let alert = UIAlertController(title: "Error", message: "Invalid email address or password. Password length must be larger than 6.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                //nothing happens
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
        Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Sign up failed", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    //nothing happens
                }
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                print(error.localizedDescription)
                return
            }
            //user created
            let alert = UIAlertController(title: "Success", message: "Sign up successful", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                //nothing happens
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            //also auto logged in, go to main view
            self.loggedin = true
            print("logged in")
            let newUser = Database.database().reference().child("users").child(user!.uid)
            newUser.setValue(["displayname" : "\(email)", "id" : "\(user!.uid)",
                "profileUrl": ""])
            self.goToChatView()
            
        }

    }
    
    func goToChatView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }
}

