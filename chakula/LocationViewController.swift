import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let defaultLocation = CLLocationCoordinate2D(latitude: 38.8976763, longitude: -77.0365298)
    var receivedLocation: CLLocationCoordinate2D?
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var instructionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if receivedLocation != nil {
            centerMapOnLocation(receivedLocation!)
        }
        else {
            centerMapOnLocation(defaultLocation)
        }
        print("white house")
        mapView.showsUserLocation = true
        instructionLabel.lineBreakMode = .ByWordWrapping
        instructionLabel.numberOfLines = 0
        
        let status = CLLocationManager.authorizationStatus()
        placeMarker()
        switch(status){
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            print("Authorized")
        default:
            launchLocationDisabledAlert()
        }
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        updateAddress(mapView.centerCoordinate)
    }
    
    func placeMarker(){
        let imageName = "chakula-map-marker"
        let image = UIImage(named: imageName)
        let marker = UIImageView(image: image!)
        let markerWidth = marker.frame.width
        let markerHeight = marker.frame.height
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        print("Width: \(markerWidth)")
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let mapCenterY = mapView.frame.size.height/2 + navigationBarHeight + mapView.frame.origin.y
        let mapCenter = CGPointMake((mapView.frame.size.width/2), mapCenterY)
        print(mapCenter)
        marker.frame = CGRectMake(screenSize.width/2 - markerWidth/2, mapCenter.y - markerHeight/2, markerWidth, markerHeight)
        view.addSubview(marker)
    }
    
    func launchLocationDisabledAlert(){
        let title = "Location Disabled"
        let message = "Chakula can't access your location. Enable location services for Chakula in Settings -> Privacy -> Location Services -> Chak Truck"
        let okayText = "Okay"
        let ios7Alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: okayText)
        ios7Alert.show()
    }
    
    @IBAction func goToLocationWasPressed(sender: AnyObject) {
        centerMapOnLocation(mapView.userLocation.coordinate)
    }
    
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        print(coordinate)
        mapView.setRegion(coordinateRegion, animated: true)
        updateAddress(coordinate)
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        updateAddress(self.mapView.centerCoordinate)
        print("In region changed animated")
    }
    
    var currentAddress: String {
        get {
            return addressLabel.text!
        }
        set {
            addressLabel.text! = newValue
        }
    }
    
    private func updateAddress(coordinate: CLLocationCoordinate2D) {
        let coordAsLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        print("updating address")
        CLGeocoder().reverseGeocodeLocation(coordAsLocation, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                if let addressDict = pm.addressDictionary as Dictionary?,
                        streetAddress = addressDict["Street"] as! String?{
                        self.currentAddress = streetAddress
                } else {
                    self.currentAddress = pm.name!
                }
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Segue coming!")
        // set the location to the one on my screen
        if let feed = segue.destinationViewController as? FoodFeedController {
            feed.currentCoords = mapView.centerCoordinate
        }
    }
}