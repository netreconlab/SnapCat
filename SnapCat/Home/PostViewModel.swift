//
//  PostViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/11/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import os.log
import ParseSwift
import UIKit
import CoreLocation

class PostViewModel: NSObject, ObservableObject {
    @Published var post: Post?
    @Published var image: UIImage?
    @Published var caption = ""
    @Published var location: ParseGeoPoint?
    @Published var currentPlacemark: CLPlacemark? {
        willSet {
            if let currentLocation = newValue?.location {
                location = try? ParseGeoPoint(location: currentLocation)
            } else {
                location = nil
            }
        }
    }

    private var authorizationStatus: CLAuthorizationStatus
    private var lastSeenLocation: CLLocation?
    private let locationManager: CLLocationManager

    init(post: Post? = nil) {
        if post != nil {
            self.post = post
        } else {
            self.post = Post()
        }
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }

    // MARK: Intents
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func save(completion: @escaping (Result<Post, ParseError>) -> Void) {
        guard let image = image,
              let compressed = image.compressTo(3) else {
            return
        }
        post?.image = ParseFile(data: compressed)
        post?.caption = caption
        post?.location = location
        post?.save { result in
            switch result {

            case .success(let post):
                // Need to fetch new file location
                post.fetch(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Queries
    class func queryLikes(post: Post?) -> Query<Activity> {
        guard let pointer = try? post?.toPointer() else {
            Logger.home.error("Should have created pointer.")
            return Activity.query().limit(0)
        }
        let query = Activity.query(ActivityKey.post == pointer,
                                   ActivityKey.type == Activity.ActionType.like)
            .order([.descending(ParseKey.createdAt)])
        return query
    }

    class func queryComments(post: Post?) -> Query<Activity> {
        guard let pointer = try? post?.toPointer() else {
            Logger.home.error("Should have created pointer.")
            return Activity.query().limit(0)
        }
        let query = Activity.query(ActivityKey.post == pointer,
                                   ActivityKey.type == Activity.ActionType.comment)
            .order([.descending(ParseKey.createdAt)])
        return query
    }
}

// MARK: CLLocationManagerDelegate

// Source: https://www.andyibanez.com/posts/using-corelocation-with-swiftui/
extension PostViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        fetchCountryAndCity(for: locations.first)
    }

    func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, _) in
            self.currentPlacemark = placemarks?.first
        }
    }
}
