//
//  SignUpViewController.swift
//  Reserve
//
//  Created by Andrew Julian Gonzales on 12/2/22.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate{


    @IBOutlet weak var emailUITextField: UITextField!
    @IBOutlet weak var passwordUITextField: UITextField!
    @IBOutlet weak var confirmPasswordUITextField: UITextField!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailUITextField.delegate = self
        self.passwordUITextField.delegate = self
        self.confirmPasswordUITextField.delegate = self
        // Do any additional setup after loading the view.
    }

    @IBAction func registerUserIBAction(_ sender: Any) {
        if(passwordUITextField!.text == confirmPasswordUITextField.text){
            print("Password: \(passwordUITextField.text!) --- Confirm: \(confirmPasswordUITextField.text!)")
            Auth.auth().createUser(withEmail: emailUITextField.text!, password: passwordUITextField.text!){(result, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    self.invalidPasswordaAction()
                } else {
                    DatabaseUser.shares.setCurrentUserData(uid: (result?.user.uid)!, email: self.emailUITextField.text!)
                    DatabaseUser.shares.username = "Default"
                    self.performSegue(withIdentifier: "toTabBar", sender: self)
                    print("success")
                }
            }
        }else{
            self.invalidPasswordaAction()
        }
    }


    func invalidPasswordaAction(){
        let alert = UIAlertController(title: "Invalid", message: "Invalid Email or Password, Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            print("Dismiss was pressed: clear textfields");
            self.passwordUITextField.text = nil;
            self.confirmPasswordUITextField.text = nil;
        }))
        present(alert, animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.emailUITextField.resignFirstResponder()
        self.passwordUITextField.resignFirstResponder()
        self.confirmPasswordUITextField.resignFirstResponder()
        return true
    }

}
