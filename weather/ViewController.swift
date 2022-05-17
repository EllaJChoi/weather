//
//  ViewController.swift
//  weather
//
//  Created by Ella Choi on 2022-03-16.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var highLowLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var hourlyStackView: UIStackView!
    @IBOutlet weak var dailyStackView: UIStackView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var city = ""
    var weatherResult: Forecast?
    var locationManager: CLLocationManager!
    var currentlocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearAll()
        getLocation()
        
    }
    
    func clearAll() {
        cityLabel.text = ""
        weatherLabel.text = ""
        temperatureLabel.text = ""
        degreeLabel.text = ""
        highLowLabel.text = ""
        windLabel.text = ""
        precipitationLabel.text = ""
        hourlyStackView.subviews.forEach({ $0.removeFromSuperview() })
        dailyStackView.subviews.forEach({ $0.removeFromSuperview() })
        bgImageView.backgroundColor = UIColor.clear
    }
    
    func getWeather() {
        NetworkService.shared.getWeather(onSuccess: { (result) in
            self.weatherResult = result
            self.weatherResult?.sortDailyArray()
            self.weatherResult?.sortHourlyArray()
            self.updateViews()
        }) { (errorMessage) in
            debugPrint(errorMessage)
        }
    }
    
    func updateViews() {
        guard let weatherResult = weatherResult else {
            return
        }
        updateView(weather: weatherResult, city: city)
        
        for i in 0..<24 {
            if let hourView = Bundle.main.loadNibNamed("HourView", owner: nil, options: nil)!.first as? HourView {
                let hour = weatherResult.hourly[i]
                let date = Date(timeIntervalSince1970: Double(hour.dt))
                let hourString = Date.getHourFrom(date: date)
                let weatherIconName = hour.weather[0].icon
                let weatherTemperature = hour.temp
                
                hourView.timeLabel.text = i == 0 ? "Now" : hourString
                hourView.weatherImage.image = UIImage(named: weatherIconName)
                hourView.temperatureLabel.text = "\(Int(calculateCelsius(weatherTemperature).rounded()))°"
                hourlyStackView.addArrangedSubview(hourView)
            }
        }
        
        for i in 0...4 {
            if let dayView = Bundle.main.loadNibNamed("DayView", owner: nil, options: nil)!.first as? DayView {
                let day = weatherResult.daily[i + 1]
                let date = Date(timeIntervalSince1970: Double(day.dt))
                let dayString = Date.getDayOfWeekFrom(date: date)
                let weatherIconName = day.weather[0].icon
                
                dayView.dayLabel.text = dayString
                dayView.weatherImage.image = UIImage(named: weatherIconName)
                dayView.highLabel.text = "\(Int(calculateCelsius(day.temp.max).rounded()))"
                dayView.lowLabel.text = "\(Int(calculateCelsius(day.temp.min).rounded()))"
                dailyStackView.addArrangedSubview(dayView)
            }
        }
    }
    
    func updateView(weather: Forecast, city: String) {
        cityLabel.text = city
        weatherLabel.text = weather.current.weather[0].description.capitalized
        temperatureLabel.text = "\(Int(calculateCelsius(weather.current.temp).rounded()))"
        degreeLabel.text = "°"
        highLowLabel.text = "H:\(Int(calculateCelsius(weather.daily[0].temp.max).rounded()))°  L:\(Int(calculateCelsius(weather.daily[0].temp.min).rounded()))°"
        windLabel.text = "WIND \(weather.current.wind_speed) \(windDirection(weather.current.wind_deg))"
        precipitationLabel.text = "PRECIPITATION \(weather.minutely[0].precipitation)"
        bgImageView.backgroundColor = bgColor(weather.current.weather[0].description)
    }
    
    func getLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentlocation = location
            
            let latitude: Double = self.currentlocation!.coordinate.latitude
            let longitude: Double = self.currentlocation!.coordinate.longitude
            
            NetworkService.shared.setLatitude(latitude)
            NetworkService.shared.setLongitude(longitude)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks[0]
                        if let city = placemark.locality {
                            self.city = city
                        }
                    }
                }
            }
            
            getWeather()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        clearAll()
        getLocation()
    }
}

