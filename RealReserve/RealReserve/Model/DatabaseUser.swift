//
//  DatabaseUser.swift
//  RealReserve
//
//  Created by Andrew Julian Gonzales on 12/5/22.
//

import Foundation

import Foundation
import FirebaseCore
import FirebaseFirestore
import MapKit
import CoreLocation
import SwiftUI
class DatabaseUser{

    var uid:String?
    var email: String?
    var username: String?
    var reservedDates = [String:String]()
    var reservedSpec = [String:CLLocationCoordinate2D]()
    var reserve = [String]()
    var locations = [String]()
    
    
    public static let shares = DatabaseUser()
    public static var profileimages = [String : UIImage]()
    
    //DONE
    func setCurrentUserData(uid:String, email:String){
        self.uid = uid
        self.email = email
        //sets te variables reservedDates and username
        self.refreshClientDataFromDatabase { updated in
            if(updated){
                print("Data Up to Date")
            }
        }
        DatabaseUser.profileimages[email] = UIImage(named: "image")
    }
    
    func setUserName(userName:String){
        self.username = userName
        self.updateClientDatabase()
    }
    
    func addReseredDate(location:String,formattedDate:String){
        self.reservedDates[location] = formattedDate
        self.updateClientDatabase()
    }
    
    func removeDate(location:String){
        self.reservedDates.removeValue(forKey: location)
        self.updateClientDatabase()
    }
            
    //DONE
    func populateDatabaseUserReserve(){
        self.reserve = []
        self.locations = []
        for(key, value) in self.reservedDates {
            let locationDate = "\(key)   \(value)"
            self.reserve.append(locationDate)
            self.locations.append(key);
        }
    }
    
    
    //-----------------------------------MAP START-----------------------//
    
    func populateReservedSpec(completion: @escaping (Bool) -> Void){
        self.reservedSpec = [:]
        for (key, _) in self.reservedDates{
            let groupOne = DispatchGroup()
            groupOne.enter()
            self.retrieveCord(address: key) { coordinate in
                self.reservedSpec[key] = coordinate
                if(self.reservedSpec.count == self.reservedDates.count){
                    groupOne.leave()
                }
            }
            groupOne.notify(queue: .main) {
                completion(true)
            }
        }
    }
    
    func retrieveCord(address:String, completion: @escaping (CLLocationCoordinate2D) -> Void){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            if(lat != nil && lon != nil){
                completion(CLLocationCoordinate2D(latitude: lat!, longitude:lon!))
            }
        }
    }
    //-----------------------------------MAP END-----------------------//
    
    //----------------------------DATA BASE ---------------------------//
    //DONE
    public func refreshClientDataFromDatabase(completion: @escaping (Bool) -> Void){
        let db = Firestore.firestore()
         let documentReference = db.collection("Users").document(self.uid!)

        let group = DispatchGroup()
        group.enter()
        documentReference.getDocument { document, error in
            if let document = document, document.exists{
                let data = document.data()
                self.username = (data?["Username"] as! String)
                self.reservedDates = data?["ReservedDates"] as! [String : String]
                self.populateDatabaseUserReserve()
            }else{
                print("Document Doesn't Exist")
            }
            group.leave()
        }

        group.notify(queue: .main) {
            print("--------------------------------------------")
            print("DatabaseUser Data Updated:\nuid: \(self.uid!)\nEmail: \(String(describing: self.email))\nUsername: \(String(describing: self.username))\nReservedDates:  \(self.reservedDates)\nReserve: \(self.reserve)\nLocations: \(self.locations)")
            print("--------------------------------------------")
            completion(true)
        }
    }
        
    
    //This this Updates data to the Data base/ not gets data from data base
    public func updateClientDatabase(){
        let db = Firestore.firestore()
        db.collection("Users").document(self.uid!).setData(
            [
            "Email":self.email!,
            "Username": self.username!,
            "ReservedDates": self.reservedDates
        ]){ error in
            if(error == nil){
                print("Successfully Updated Database For: \(self.uid!)")
            }else{
                print("Not Updated to Database")
            }

        }
    }
        
}

        
