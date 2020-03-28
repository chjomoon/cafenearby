//
//  ViewController.swift
//  assignment2
//
//  Created by Chanjo MOON on 11/30/19.
//  Copyright © 2019 Chanjo MOON    201444544.
//  All rights reserved.
//
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource  {

    /**
     * Intstace Variables
     **/
    var locationManager = CLLocationManager() //create an instance to manage our the user’s location.
    var cafeLocations : [coffeeShop] = []
    var openingTime = ["08:00 ~ 08:30","I don't know","Open 24hr","09:00 ~ 18:00" , "07:00 ~ 15:00", "06:30 ~ 22:00","Open 24hr","Closed Today", "06:00 ~ 09:00"]
    
    var distances : [Double] = []
    let myLocation  = CLLocation(latitude: 53.406566, longitude: -2.966531)
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var logos = [#imageLiteral(resourceName: "star"), #imageLiteral(resourceName: "costa"), #imageLiteral(resourceName: "nero"), #imageLiteral(resourceName: "any") , #imageLiteral(resourceName: "lpl"), #imageLiteral(resourceName: "vic")]

    override func viewDidLoad() {
        super.viewDidLoad()
        //myMap.delegate = self
        locationManager.delegate = self as CLLocationManagerDelegate //we want messages about location
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization() //ask the user for permission to get their location
        locationManager.startUpdatingLocation() //and start receiving those messages (if we’re allowed to)
        
        mapView.delegate = self
        //json decoding
        if let url = URL(string: "https://dentistry.liverpool.ac.uk/_ajax/coffee/"){
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else {
                return}
                do{
                    let decoder = JSONDecoder()
                    let shops = try decoder.decode(coffeeOnCampus.self, from: jsonData)
                    var count = 0
                    //looping to store the data into the struct
                    for shop in shops.data {
                        self.cafeLocations.append(shop)
                        count += 1
                        let cafeLoc = CLLocation(latitude: Double(shop.latitude)!, longitude: Double(shop.longitude)!)
                        let distance = self.myLocation.distance(from: cafeLoc)
                        self.distances.append(round(100*distance)/100)
                    }
                    self.createAnntations(locations: self.cafeLocations)
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                }.resume()
        }
        //updating the table view
        self.tableView.reloadData()
        //annotation for the Ashton building
        let ashton = MKPointAnnotation()
        ashton.title = "Ashton Building"
        ashton.subtitle = "your current location"
        ashton.coordinate = CLLocationCoordinate2D(latitude: 53.406566, longitude: -2.966531)
        mapView.addAnnotation(ashton)
    }
    
    //location setting for the map(the Ashton building)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = 53.406566 //locationOfUser.coordinate.latitude
        let longitude = -2.966531 //locationOfUser.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.004
        let lonDelta: CLLocationDegrees = 0.004
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    //struct of coffeeshop
    struct coffeeShop: Decodable {
        let id: String
        let name: String
        let latitude: String
        let longitude: String
        //let distance : String
    }
    
    struct coffeeOnCampus: Decodable {
     let data: [coffeeShop]
     let code: Int
    }
    var coffeeShops: coffeeOnCampus?
    
    //method to create new anotation of coffee shops on the map by using the decoding data [ViewController.coffeeShop]
    func createAnntations(locations : [ViewController.coffeeShop]){
        var count = 0
        for location in locations {
            openingTime.shuffle()
            let annotation = MKPointAnnotation()
            annotation.title = location.name
            annotation.subtitle = "opening times: " + openingTime[count] + " address: Liverpool"
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(location.latitude)!, longitude: Double(location.longitude)!)
            mapView.addAnnotation(annotation)
            count += 1
        }
        
    }
    
    /*
     * mapView:viewForAnnotation: provides the view for each annotation.
     * This method is called for all or some of the added annotations.
     * For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
     * This method may be called for all or some of the added annotations.
     **/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        //assigning the images of coffeeshops and the user locations
        if annotation.title == "Ashton Building"{
            annotationView?.image = logos[5]
        }else if annotation.title == "Starbucks" {
            annotationView?.image = logos[0]
        }else if annotation.title == "Costa"{
            annotationView?.image = logos[1]
        }else if annotation.title == "Nero" {
            annotationView?.image = logos[2]
        }else if annotation.title == "92 Degrees Coffee" {
            annotationView?.image = logos[3]
        }else {
            annotationView?.image = logos[4]
        }
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    //once click the coffeeshops, it displays the notification
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected : \(String(describing: view.annotation?.title))" )
    }
    //initialize the number of rows of table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //setting the number of rows of table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(distances.count)
        return 9
    }
    /*
     * Table view to display distances from user's current location(Ashton building)
     **/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DistanceTableViewCell
        if cafeLocations.count > 0{
            cell.cafeName?.text = cafeLocations[indexPath.row].name
        }else {
            cell.cafeName?.text = "scroll the map and the table to show update"
        }
        if distances.count > 0 {
            cell.cafeDistance?.text = String(distances[indexPath.row]) + " meters away"
        }else{
            cell.cafeDistance?.text = " "
        }
    
        tableView.insertRows(at: [indexPath], with: .automatic)

        return cell
    }
    
    
    /*
     * Method to send a data to seque another view controller
     **/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let passedInfo = segue.destination as! InfoViewController
        //let myIndexPath = self.
        let myRow = cafeLocations.count
        passedInfo.whichCoffeeShop = myRow
        print("Selected : " + String(passedInfo.whichCoffeeShop))
        //passedInfo.playSong = songData[myRow]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    
}

//var cShops = [coffeeShop(id:"1", name: "92",latitude: "53.401439", longitude: "-2.97081"), coffeeShop(id:"2",name:"Starbucks",latitude:"53.405343",longitude:"-2.966432"), coffeeShop(id:"3",name:"Starbucks",latitude:"53.41074",longitude:"-2.96515"),coffeeShop(id:"4",name:"Waterhouse Cafe",latitude:"53.4063679",longitude:"-2.9657691"),coffeeShop(id:"5",name:"Nero",latitude:"53.4061008",longitude:"-2.964589"),coffeeShop(id:"6",name:"Costa",latitude:"53.4059",longitude:"-2.9671"),coffeeShop(id:"7",name:"Nero",latitude:"53.4011952",longitude:"-2.9679057"),coffeeShop(id:"8",name:"Sydney Jones Cafe",latitude:"53.4028829",longitude:"-2.9637649")]

