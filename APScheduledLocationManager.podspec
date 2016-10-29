
Pod::Spec.new do |s|
  s.name         = "APScheduledLocationManager"
  s.version      = "1.0.0"
  s.summary      = "Location manager that allows to get background location updates every n seconds"
  s.description  = <<-DESC
  Location manager that allows to get background location updates every n seconds with desired location accuracy.
                   DESC

  s.homepage     = "https://github.com/paleksandrs/APScheduledLocationManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       =   "Aleksandrs Proskurins"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/paleksandrs/APScheduledLocationManager.git", :tag => "1.0.0" }
  s.source_files =  "APScheduledLocationManager/*.swift"
end
