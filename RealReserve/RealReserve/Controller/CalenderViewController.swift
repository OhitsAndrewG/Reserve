//
//  CalenderViewController.swift
//  RealReserve
//
//  Created by Andrew Julian Gonzales on 12/4/22.
//

import UIKit
import FSCalendar
import Firebase
class CalenderViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    var calenderView:FSCalendar = FSCalendar()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseUser.shares.refreshClientDataFromDatabase { updated in
            self.setUpCalender()
        }
        //add all dates that were already pre set when loaded in

        // Do any additional setup after loading the view.
    }
    


    func setUpCalender(){
        view.addSubview(self.calenderView)
        calenderView.frame = view.frame
        calenderView.delegate = self
        calenderView.dataSource = self
        calenderView.scrollDirection = .vertical
        calenderView.appearance.borderRadius = 0
        calenderView.clipsToBounds = true
        calenderView.today = nil
        calenderView.appearance.selectionColor = .darkGray
        calenderView.appearance.eventDefaultColor = .black
        calenderView.appearance.eventSelectionColor = .darkGray
        calenderView.appearance.headerTitleColor = .darkGray
        calenderView.appearance.titleDefaultColor = .darkGray
        calenderView.appearance.weekdayTextColor = .darkGray
    }
    


    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedDate = dateFormatter.string(from: date)
        
        print("Date was Selected: \(formattedDate)")
        let alert = UIAlertController(title: "\(formattedDate)", message: "Please Enter Location", preferredStyle: .alert)
        //add textfields
        alert.addTextField { textBox in
            textBox.placeholder = "St city State"
            textBox.returnKeyType = .done
        }

        //added buttons
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { error in
            //add to data base - date and location
            guard let field = alert.textFields else {
                return
            }
            print("location: \(field[0].text!) Date: \(formattedDate)")
            DatabaseUser.shares.addReseredDate(location: field[0].text!, formattedDate:formattedDate)
        }))
        present(alert, animated: true)
    }
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        
        for (_, value) in DatabaseUser.shares.reservedDates {
            guard let eventDate = dateFormatter.date(from: value)else{return 0}
            if(date.compare(eventDate) == .orderedSame){
                return 2
            }
        }
        return 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DatabaseUser.shares.refreshClientDataFromDatabase { updated in
            self.calenderView.reloadData()
            self.setUpCalender()
        }
    }

}

