//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Ali Ashaikh on 2019-02-16.
//  Copyright © 2019 Ali Ashaikh. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Kingfisher

private let reuseIdentifier = "CollectionViewCell"

class CollectionViewController: UIViewController, MKMapViewDelegate,NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var fetchedResultsController:NSFetchedResultsController<Picture>!
    var pin: MKAnnotation?
    var location: Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePin()
        fetch()
        if fetchedResultsController.fetchedObjects?.count == 0 {
            getNewPhotos()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        flowLayout.estimatedItemSize = CGSize(width: 90, height: 90)
        activityIndicator.hidesWhenStopped = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }


    func fetch() {
        let fetchRequest: NSFetchRequest<Picture> = Picture.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "pictures == %@", location)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        // TODO: perform the fetch with fetchedResultsController
        do {
            try fetchedResultsController.performFetch()

        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = floor(self.collectionView.frame.size.width / 3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    
    func updatePin() {
        self.mapView.addAnnotation(pin!)
        self.mapView.region = MKCoordinateRegion(center: (pin?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        collectionView!.reloadData()

    }
    
    //This function was used from Example given in lecture
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func getNewPhotos(){
        activityIndicator.startAnimating()
        let pictures = fetchedResultsController.fetchedObjects
        for picture in pictures! {
            DataController.shared.viewContext.delete(picture)
        }
        var n = 1
        while (n <= 10){
            flickerApi.sharedInstance().searchByLatLon(lat: (pin?.coordinate.latitude)!,lon: (pin?.coordinate.longitude)!){(response, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Unable to load location photos", message: "No Photos Available", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated:true)
                    return
                } else {
                    let picture = Picture(context: DataController.shared.viewContext)
                    picture.id = Int16(n)
                    picture.url = response
                    picture.date = Date() as NSDate?
                    picture.pictures = self.location
                }
                self.activityIndicator.stopAnimating()
            }
            n = n+1
        }
        try? DataController.shared.viewContext.save()

    }
    
    @IBAction func getCollection(_ sender: Any) {
        getNewPhotos()
        updatePin()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (fetchedResultsController.sections?.count) ?? 0
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return (fetchedResultsController.sections?[section].numberOfObjects) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let locationPhoto = fetchedResultsController.object(at: indexPath)
        let resource = ImageResource(downloadURL: URL(string: locationPhoto.url!)!)
        cell.picture.kf.indicatorType = .activity
        cell.picture?.kf.setImage(with: resource)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let locationPhoto = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(locationPhoto)
        collectionView.reloadData()
    }
    

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }


    
}


