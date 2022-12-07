//
//  LogInViewController.swift
//  Reserve
//
//  Created by Andrew Julian Gonzales on 12/2/22.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    
    @IBOutlet weak var emailUITextField: UITextField!
    
    @IBOutlet weak var passwordUITextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInUIButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailUITextField.text!, password: passwordUITextField.text!){ arg ,error  in
                if(error != nil){
                    self.invalidInformation();
                }else{
                    
                    DatabaseUser.shares.setCurrentUserData(uid: (arg?.user.uid)!, email: self.emailUITextField.text!)
                    

                    self.performSegue(withIdentifier: "toTabBar", sender: self)

                }

        }
    }
    
    
    func invalidInformation(){
        let alert = UIAlertController(title: "Invalid", message: "Invalid Email or Password Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            print("Dismiss was pressed: clear textfields");
            self.passwordUITextField.text = nil;
            self.emailUITextField.text = nil;
        }))
        present(alert, animated: true)
    }
}
