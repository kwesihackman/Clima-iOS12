//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
   
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "95297d78e2860656ca0e25eb75e2ddc0"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //this works for weather app
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters:[String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess{
                
                
                if let weatherDataJSON: JSON = JSON(response.result.value){
                   self.updateWeatherData(json: weatherDataJSON)
                }
                
                
            }else{
                //issues with connection
                debugPrint("Error \(response.result.error)")
                self.cityLabel.text = "connection issue"
            }
        }
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double{
            weatherDataModel.temperature = Int(tempResult - 273.15) //convert from F to C
            weatherDataModel.city = json["city"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            self.updateUIWithWeatherData()
        }else{
            debugPrint("Something went wrong");
            cityLabel.text = "Weather unvailable"
        }
        
        
        
        
        
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        
        //check for valid location
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            debugPrint("lon = \(location.coordinate.longitude), lat = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("error occured")
        cityLabel.text = "Location Unavaialable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnterANewCityName(city: String) {
        let params:[String: String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
          let destinationVC =   segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


