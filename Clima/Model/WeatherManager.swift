//
//  WeatherManager.swift
//  Clima
//
//  Created by Angela Yu on 03/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

//MARK: - creating the URL of our ap

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?q="
    let endURL = "&appid=80ce5549e68fe8f36f5705d662e812b1"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)\(cityName)\(endURL)"
        performRequest(with: urlString)
    }
    
    //MARK: - passing our location
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
       let apiLocationURL = "https://api.openweathermap.org/data/2.5/weather?"
        
        
        let urlString = "\(apiLocationURL)&lat=\(latitude)&lon=\(longitude)&appid=80ce5549e68fe8f36f5705d662e812b1"
        performRequest(with: urlString)
    }
    
    
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}


