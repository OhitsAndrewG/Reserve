//
//  MapViewController.swift
//  RealReserve
//
//  Created by Andrew Julian Gonzales on 12/5/22.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import AVFAudio


class Flag : NSObject, MKAnnotation{
    var title:String?
    var coordinate:CLLocationCoordinate2D
    init(title:String, location: CLLocationCoordinate2D){
        self.title = title
        self.coordinate = location
    }
}


class MapViewController: UIViewController, MKMapViewDelegate {



    @IBOutlet weak var mapUIMapKit: MKMapView!

    var locations = [String]()
    var reservedSpec = [String:CLLocationCoordinate2D]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapUIMapKit.delegate = self


        // Do any additional setup after loading the view.
    }

    func addCoordinates(location:String){
        DatabaseUser.shares.retrieveCord(address: location) { coordinates in
            print(coordinates);
            self.reservedSpec[location] = coordinates
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if(self.mapUIMapKit.annotations.count != 0){
            self.mapUIMapKit.removeAnnotations(self.mapUIMapKit.annotations)
        }
        DatabaseUser.shares.refreshClientDataFromDatabase { updated in
            if updated {
                DatabaseUser.shares.populateReservedSpec { refreshed in
                    if refreshed {
                        
                        print("\nReserved Spec: \(DatabaseUser.shares.reservedSpec)\n")
                        for (key, value) in DatabaseUser.shares.reservedSpec{
                            let pp = CLLocationCoordinate2D(latitude: value.latitude, longitude: value.longitude)
                            let flag = Flag(title: key, location: pp)
                            self.mapUIMapKit.addAnnotation(flag)
                        }
                    }
                }
            }
        }
    }
        
}
