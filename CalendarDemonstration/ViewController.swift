//
//  ViewController.swift
//  CalendarDemonstration
//
//  Created by Joel Meyer E. on 20.12.21.
//

import UIKit
import EventKit
import Foundation

class ViewController: UIViewController {
    //create EventStore
    var store = EKEventStore()
    //add Calendars
    @IBOutlet var startText: UITextField!
    @IBOutlet var endText: UITextField!
    @IBOutlet var titleText: UITextField!
    
    //edit Calendar
    @IBOutlet var renameFrom: UITextField!
    @IBOutlet var renameCalTo: UITextField!
    @IBOutlet var changeColorTo: UITextField!
    
    //edite Events
    //@IBOutlet var eventToRemove: UITextField!
    @IBOutlet var eventToBeRemoved: UITextField!
    @IBOutlet var newEventName: UITextField!
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        store.requestAccess(to: .event) { granted, error in
            // Handle the response to the request.
            print("Acces to events granted")
        }
        
    
        //Looks for single or multiple taps.
             let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false

            view.addGestureRecognizer(tap)

    }

    //add Calendar One
    @IBAction func CalendarOne(_ sender: Any) {
        //look if calendar was created
        var projectCalendar:EKCalendar? = getCalendar(calendarName: "Calendar 1")

        //create new Calendar if calendar does not exist
        if (projectCalendar == nil)
        {
            //create new calendar
            projectCalendar = EKCalendar.init(for: .event, eventStore: store)
            
            //set calendar settings
            projectCalendar?.title = "Calendar 1"
            projectCalendar?.cgColor = UIColor.red.cgColor
            projectCalendar?.source = getiCloudSource()
            print("Calendar 1 was created")
        }
        
        // Save the calendar using the Event Store instance
        try! store.saveCalendar(projectCalendar!, commit: true)
    
    }
    
    //add Calendar 2
    @IBAction func CalendarTwo(_ sender: Any) {
        
        var secondCalendar:EKCalendar? = getCalendar(calendarName: "Calendar 2")
        
        //create new Calendar if calendar does not exist create one
        if (secondCalendar == nil)
        {
            //create new calendar
            secondCalendar = EKCalendar.init(for: .event, eventStore: store)
            
            //set calendar settings
            secondCalendar?.title = "Calendar 2"
            secondCalendar?.cgColor = UIColor.green.cgColor
            secondCalendar?.source = getiCloudSource()
            print("Calendar 2 was created")
        }
        try! store.saveCalendar(secondCalendar!, commit: true)
    }
    
    
    @IBAction func addCalendarThree(_ sender: Any) {
        var thirdCalendar:EKCalendar? = getCalendar(calendarName: "Calendar 3")
        
        //create new Calendar if calendar does not exist create one
        if (thirdCalendar == nil)
        {
            //create new calendar
            thirdCalendar = EKCalendar.init(for: .event, eventStore: store)
            
            //set calendar settings
            thirdCalendar?.title = "Calendar 3"
            thirdCalendar?.cgColor = UIColor.blue.cgColor
            thirdCalendar?.source = getiCloudSource()
            print("Calendar 3 was created")
        }
        try! store.saveCalendar(thirdCalendar!, commit: true)
    }
    
    @IBAction func addEventToFirstCalendar(_ sender: Any) {
        try! store.save(addEventFunction(to: "Calendar 1"), span: .thisEvent, commit: true)
    }
    
   
    @IBAction func addAllDayEvent(_ sender: Any) {

        //pget day from interface
        let startArray = startText.text?.components(separatedBy: ".")
        
        // Specify date components
        var startingDate = DateComponents()
        startingDate.year = Int(startArray![2])
        startingDate.month = Int(startArray![1])
        startingDate.day = Int(startArray![0])
      
        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian)
        let allDayEvent = userCalendar.date(from: startingDate)

        //add event
        let newEvent = EKEvent.init(eventStore: store)
        newEvent.title = titleText.text
        newEvent.calendar = getCalendar(calendarName: "Calendar 2")
        newEvent.startDate = allDayEvent
        newEvent.endDate = allDayEvent
        newEvent.isAllDay = true
        
        //save event
        try! store.save(newEvent, span: .thisEvent, commit: true)
        print("All day event shoud be added")
    }
    
    @IBAction func removeCalendarOne(_ sender: Any) {
        try! store.removeCalendar(getCalendar(calendarName: "Calendar 1")!, commit: true)
        print("Calendar 1 shoud be removed")
    }
    
    @IBAction func removeCalendarTwo(_ sender: Any) {
        try! store.removeCalendar(getCalendar(calendarName: "Calendar 2")!, commit: true)
        print("Calendar 2 shoud be removed")
    }
    
  
    
    func getCalendar (calendarName:String) -> EKCalendar? {
        // get all sources of EventStore
        let sourcesInEventStore = store.sources
        
        //set Calendar source to iCloud
       for source in sourcesInEventStore
        {
           if source.title == "iCloud"
           {
               for calendar in source.calendars(for: .event){
                   //look if calendar already exist
                   if calendar.title == calendarName
                   {
                       print("\(calendarName) already existed")
                       return calendar
                   }
                       }
           }
       }
        print("\(calendarName) does not exist")
        return nil  //
    }
    
    func getiCloudSource() -> EKSource?{
        
        for source in store.sources
         {
            if source.title == "iCloud"
            {
                return source
            }
        }
        return nil
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func editCalendarButton(_ sender: Any) {
        let calendar = getCalendar(calendarName: renameFrom.text!)
        calendar?.title = renameCalTo.text!
        let changeColor = changeColorTo.text!
        
        switch changeColor {
        case "red":
            calendar?.cgColor = UIColor.red.cgColor
        case "blue":
            calendar?.cgColor = UIColor.blue.cgColor
        case "green":
            calendar?.cgColor = UIColor.green.cgColor
        case "black":
            calendar?.cgColor = UIColor.green.cgColor
        default:
            print("Color has yet to be implemented")
        }
        
        //save Calendar
        try! store.saveCalendar(calendar!, commit: true)
    }
    
    @IBAction func deleteEventFromCalendarButton(_ sender: Any) {
        
        try! store.remove(fetchEvent(withTitle: eventToBeRemoved.text!)!, span: .thisEvent)
        print("Event shouls be deleted")
    }
    
    @IBAction func editEvent(_ sender: Any) {
        let eventToEdit = fetchEvent(withTitle: eventToBeRemoved.text!)!
        
        eventToEdit.title = newEventName.text!
        try! store.save(eventToEdit, span: .thisEvent, commit: true)
        print("Event should be edited")
    }
    
    func fetchEvent (withTitle:String) -> EKEvent?{
        // Get the appropriate calendar.
        let calendar = Calendar.current
                        
        // Create the start date components
        var oneDayAgoComponents = DateComponents()
        oneDayAgoComponents.day = -1
        let oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date(), wrappingComponents: false)

        // Create the end date components.
        var oneYearFromNowComponents = DateComponents()
        oneYearFromNowComponents.year = 1
        let oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date(), wrappingComponents:false)

        // Create the predicate from the event store's instance method.
        let calendarArray:[EKCalendar] = [getCalendar(calendarName: "Calendar 1")!]
        //[sourcesInEventStore[1].calendars(for: .event).first!]
                
        var predicate: NSPredicate? = nil
        if let anAgo = oneDayAgo, let aNow = oneYearFromNow {
        predicate = store.predicateForEvents(withStart: anAgo, end: aNow, calendars:calendarArray)
        }

        // Fetch all events that match the predicate.
        var events: [EKEvent]? = nil
        if let aPredicate = predicate {
        events = store.events(matching: aPredicate)
        }
        
        var fetchedEvent:EKEvent? = nil
        
        for event in events!
        {
            if event.title == withTitle
            {
                fetchedEvent = event
            }
        }
        
        return fetchedEvent!
    }
    @IBAction func addEventCalendarThree(_ sender: Any) {
        let fetchedEvent = addEventFunction(to: "Calendar 3")
        
        let reocurrence = [EKRecurrenceRule.init(recurrenceWith: .weekly, interval: 1, end: nil)]
        fetchedEvent.recurrenceRules = reocurrence

        
        try! store.save(fetchedEvent, span: .futureEvents, commit: true)
    }
    
    func addEventFunction (to:String) -> EKEvent{
        //get date from interface
        let startArray = startText.text?.components(separatedBy: ".")
        let endArray = endText.text?.components(separatedBy: ".")
        
        // Specify date components
        var startingDate = DateComponents()
        startingDate.year = Int(startArray![2])
        startingDate.month = Int(startArray![1])
        startingDate.day = Int(startArray![0])
 
        startingDate.hour = Int(startArray![3])
        startingDate.minute = Int(startArray![4])
        
        var endingDate = DateComponents()
        endingDate.year = Int(endArray![2])
        endingDate.month = Int(endArray![1])
        endingDate.day = Int(endArray![0])
        //dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
        endingDate.hour = Int(endArray![3])
        endingDate.minute = Int(endArray![4])

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian)
        let starintgTime = userCalendar.date(from: startingDate)
        let endingTime = userCalendar.date(from: endingDate)
        
        //add event
        let newEvent = EKEvent.init(eventStore: store)
        newEvent.title = titleText.text
        newEvent.calendar = getCalendar(calendarName: to)
        newEvent.startDate = starintgTime
        newEvent.endDate = endingTime
        
        return newEvent
    }
}



