//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ali Ashaikh on 2019-02-16.
//  Copyright © 2019 Ali Ashaikh. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!

    var fetchedResultsController:NSFetchedResultsController<Location>!
    var annotations: [MKAnnotation] = [MKAnnotation]()
    var selected: MKAnnotation?
    var currentlocatin: Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longPress(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
        fetch()
        reloadMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadMap()
    }
    
    func fetch() {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        // TODO: perform the fetch with fetchedResultsController
        do {
            try fetchedResultsController.performFetch()
            let locations = fetchedResultsController.fetchedObjects
            for location in locations! {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = location.lat
                annotation.coordinate.longitude = location.lon
                mapView.addAnnotation(annotation)
                annotations.append(annotation)
                
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func reloadMap(){
        mapView.addAnnotations(annotations)
    }

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation, animated: false)
        selected = view.annotation
        let locs = fetchedResultsController.fetchedObjects
        for loc in locs! {
            if (loc.lat == selected?.coordinate.latitude || loc.lon == selected?.coordinate.longitude){
                currentlocatin = loc
            }
        }
        performSegue(withIdentifier: "list", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    }
    
    func longPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.began {
            return
        }
        let touchPoint: CGPoint = gesture.location(in: mapView)
        let touchCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchCoordinate
        annotations.append(annotation)
        selected = annotation
        mapView.addAnnotation(annotation)
        
        let location = Location(context: DataController.shared.viewContext)
        location.lat = annotation.coordinate.latitude
        location.lon = annotation.coordinate.longitude
        location.date = Date() as NSDate?
        currentlocatin = location
        try? DataController.shared.viewContext.save()
    }
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "list") {
            let collectionVC = segue.destination as! CollectionViewController
            collectionVC.pin = self.selected
            collectionVC.location = self.currentlocatin
        }
    }

    
    



}

