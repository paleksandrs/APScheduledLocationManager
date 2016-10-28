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
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = APScheduledLocationManager(delegate: self)
    }
    
    @IBAction func startStop(_ sender: AnyObject) {
        
        if manager.isRunning {
            
            startStopButton.setTitle("start", for: .normal)
            manager.stoptUpdatingLocation()
        }else{
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                startStopButton.setTitle("stop", for: .normal)
                manager.startUpdatingLocation(interval: 60, acceptableLocationAccuracy: 100)
            }else{
                
                manager.requestAlwaysAuthorization()
            }
        }
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
        
    }
}
