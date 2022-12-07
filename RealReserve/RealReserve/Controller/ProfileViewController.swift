//
//  ProfileViewController.swift
//  RealReserve
//
//  Created by Andrew Julian Gonzales on 12/3/22.
//

import UIKit
import Firebase


class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var addImageUIButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameUITextField: UITextField!
    @IBOutlet weak var confirmUsernameUIButton: UIButton!
    @IBOutlet weak var logoutUIButton: UIButton!
    @IBOutlet weak var scheduleUITableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameUITextField.placeholder = DatabaseUser.shares.username
        self.scheduleUITableView.reloadData()
        //------VISUAL----------------------------------------------//
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds=true;


    }
    
    
    
    @IBAction func logoutIBAction(_ sender: Any) {
        let currentUser = Auth.auth()
        do{
            try currentUser.signOut()
            let optionStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let optionViewController = optionStoryBoard.instantiateViewController(withIdentifier: "OptionViewController") as! OptionViewController
            self.view.window?.rootViewController = optionViewController
            self.view.window?.makeKeyAndVisible()
            DatabaseUser.shares.username = " "
            DatabaseUser.shares.uid = ""
            DatabaseUser.shares.reservedDates = [:]
            DatabaseUser.shares.reserve = []
            DatabaseUser.shares.locations = []
            DatabaseUser.shares.reservedSpec = [:]
            print("Officially Logged Out")
        }catch let errorSignOut as NSError{
            print("Issue with Signing Out: \(errorSignOut.localizedDescription)")
        }
    }

    
    @IBAction func confirmUsernameAction(_ sender: Any) {
        self.usernameUITextField.placeholder = self.usernameUITextField.text!
        DatabaseUser.shares.setUserName(userName: self.usernameUITextField.text!)
    }
    


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseUser.shares.reserve.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //created the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth =  true
        let reservationString = DatabaseUser.shares.reserve[indexPath.row]
        //configure the cell
        cell.textLabel?.text = reservationString
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.beginUpdates()
            let location = DatabaseUser.shares.locations[indexPath.row]
            
            DatabaseUser.shares.removeDate(location: location)
            DatabaseUser.shares.refreshClientDataFromDatabase { updated in
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
            }
    
            
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Inside ViewWillAppear")
        DatabaseUser.shares.refreshClientDataFromDatabase {updated in
            if(updated == true){
                self.scheduleUITableView.reloadData()
            }
        }
    }

}
