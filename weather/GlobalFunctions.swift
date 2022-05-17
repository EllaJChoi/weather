//
//  GlobalFunctions.swift
//  weather
//
//  Created by Ella Choi on 2022-03-16.
//

import UIKit

func calculateCelsius(_ fahrenheit: Double) -> Double {
    return (fahrenheit - 32) * 5 / 9
}

func windDirection(_ degree: Int) -> String {
    if degree <= 15 || degree > 345 {
        return "N"
    } else if degree <= 35 {
        return "NNE"
    } else if degree <= 55 {
        return "NE"
    } else if degree <= 75 {
        return "ENE"
    } else if degree <= 105 {
        return "E"
    } else if degree <= 125 {
        return "ESE"
    } else if degree <= 145 {
        return "SE"
    } else if degree <= 165 {
        return "SSE"
    } else if degree <= 195 {
        return "S"
    } else if degree <= 215 {
        return "SSW"
    } else if degree <= 235 {
        return "SW"
    } else if degree <= 255 {
        return "WSW"
    } else if degree <= 285 {
        return "W"
    } else if degree <= 305 {
        return "WNW"
    } else if degree <= 325 {
        return "NW"
    } else if degree <= 345 {
        return "NNW"
    }
    return ""
}

func bgColor(_ weather: String) -> UIColor {
    switch weather {
    case "clear sky", "few clouds", "scattered clouds", "broken clouds":
        return UIColor(rgb: 0x6092D4)
    case "shower rain", "rain", "thunderstorm":
        return UIColor(rgb: 0xaed3e6)
    case "snow":
        return UIColor(rgb: 0xedf7fc)
    case "mist":
        return UIColor(rgb: 0x40c2ff)
    default:
        return UIColor.clear
    }
    
}

extension Date {
    static func getHourFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        var string = dateFormatter.string(from: date)
        if string.last == "M" {
            string = string.components(separatedBy: ":")[0] + String(string.suffix(2))
        }
        return string
    }
    
    static func getDayOfWeekFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red")
        assert(green >= 0 && green <= 255, "Invalid green")
        assert(blue >= 0 && blue <= 255, "Invalid blue")
        
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }

    convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
