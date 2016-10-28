//
//  Created by Aleksandrs Proskurins
//
//  License
//  Copyright © 2016 Aleksandrs Proskurins
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import CoreLocation


public protocol APScheduledLocationManagerDelegate {
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error)
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations locations: [CLLocation])
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}


public class APScheduledLocationManager: NSObject, CLLocationManagerDelegate {
    
    private let MaxBGTime: TimeInterval = 170;
    private let MinBGTime: TimeInterval = 2;
    
    private let delegate: APScheduledLocationManagerDelegate
    private let manager = CLLocationManager()
    
    private var isManagerRunning = false
    private var checkLocationTimer: Timer?
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    public private(set) var acceptableLocationAccuracy: CLLocationAccuracy = 100
    public private(set) var checkLocationInterval: TimeInterval = 10
    public private(set) var isRunning = false
    
    public init(delegate: APScheduledLocationManagerDelegate) {
       
        self.delegate = delegate
        
        super.init()
        
        configureLocationManager()
    }
    
    private func configureLocationManager(){
        
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        manager.distanceFilter = kCLDistanceFilterNone;
        manager.delegate = self
    }
    
    public func requestAlwaysAuthorization() {
        
        manager.requestAlwaysAuthorization()
    }
    
    public func startUpdatingLocation(interval: TimeInterval, acceptableLocationAccuracy: CLLocationAccuracy = 100) {
        
        if isRunning {
            
            stoptUpdatingLocation()
        }
        
        checkLocationInterval = interval > MaxBGTime ? MaxBGTime : interval
        checkLocationInterval = interval < MinBGTime ? MinBGTime : interval
        
        self.acceptableLocationAccuracy = acceptableLocationAccuracy
        
        isRunning = true
        
        addNotifications()
        startLocationManager()
    }
    
    public func stoptUpdatingLocation() {
        
        isRunning = false
        
        stopLocationManager()
        stopBackgroundTask()
        stopCheckLocationTimer()
        removeNotifications()
    }
    
    private func addNotifications() {
        
        removeNotifications()
        
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidEnterBackground),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }

    private func removeNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startLocationManager() {
        
        isManagerRunning = true
        manager.startUpdatingLocation()
    }
    
    private func stopLocationManager() {
        
        isManagerRunning = false
        manager.stopUpdatingLocation()
    }
    
    @objc func applicationDidEnterBackground() {
        
        stopBackgroundTask()
        startBackgroundTask()
    }
    
    @objc func applicationDidBecomeActive() {
        
        stopBackgroundTask()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
        delegate.scheduledLocationManager(self, didChangeAuthorization: status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        delegate.scheduledLocationManager(self, didFailWithError: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard isManagerRunning else { return }
        guard locations.count>0 else { return }
        
        let location = locations.last!
        
        if location.horizontalAccuracy < acceptableLocationAccuracy {
            
            startBackgroundTask()
            startCheckLocationTimer()
            stopLocationManager()
            
            delegate.scheduledLocationManager(self, didUpdateLocations: locations)
        }
    }
    
    private func startCheckLocationTimer() {
        
        stopCheckLocationTimer()
        
        checkLocationTimer = Timer.scheduledTimer(timeInterval: checkLocationInterval, target: self, selector: #selector(checkLocationTimerEvent), userInfo: nil, repeats: false)
    }
    
    private func stopCheckLocationTimer() {
        
        if let timer = checkLocationTimer {

            timer.invalidate()
            checkLocationTimer=nil;
        }
    }
    
    func checkLocationTimerEvent() {

        stopCheckLocationTimer()
        
        startLocationManager()
        
        // starting from iOS 7 and above stop background task with delay, otherwise location service won't start
        self.perform(#selector(stopAndResetBgTaskIfNeeded), with: nil, afterDelay: 1)
    }
    
    func stopAndResetBgTaskIfNeeded()  {
        
        if isManagerRunning {
            stopBackgroundTask()
        }else{
            stopBackgroundTask()
            startBackgroundTask()
        }
    }
    
    private func startBackgroundTask() {
        let state = UIApplication.shared.applicationState
        
        if ((state == .background || state == .inactive) && bgTask == UIBackgroundTaskInvalid) {
            
            bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                
                self.checkLocationTimerEvent()
            })
        }
    }
    
    @objc private func stopBackgroundTask() {
        guard bgTask != UIBackgroundTaskInvalid else { return }
        
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = UIBackgroundTaskInvalid
    }
}
