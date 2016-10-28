//
//  Created by Aleksandrs Proskurins
//
//  License
//  Copyright © 2016 Aleksandrs Proskurins
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
import APScheduledLocationManager
import CoreLocation

class ViewController: UIViewController, APScheduledLocationManagerDelegate {
    
    private var manager: APScheduledLocationManager!

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = APScheduledLocationManager(delegate: self)
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
           startUpdatingLocation()
        }else{
            manager.requestAlwaysAuthorization()
        }
    }
    
    func startUpdatingLocation()  {
        
         manager.startUpdatingLocation(interval: 170 )
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        
        let l = locations.first!
        
        textView.text = "\(textView.text!)\r \(formatter.string(from: Date())) loc: \(l.coordinate.latitude), \(l.coordinate.longitude)"
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error) {
        
        
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways && !manager.isRunning {
            
            startUpdatingLocation()
        }
    }
}

