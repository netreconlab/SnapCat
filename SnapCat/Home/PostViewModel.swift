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
    var currentPlacemark: CLPlacemark? {
        willSet {
            if let currentLocation = newValue?.location {
                location = try? ParseGeoPoint(location: currentLocation)
            } else {
                location = nil
            }
            objectWillChange.send()
        }
    }
    private var authorizationStatus: CLAuthorizationStatus
    private var lastSeenLocation: CLLocation?
    private let locationManager: CLLocationManager

    init(post: Post? = nil) {
        if post != nil {
            self.post = post
        } else {
            self.post = Post(image: nil)
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

    func save() async throws -> Post {
        guard let image = image,
              let compressed = image.compressTo(3),
              var currentPost = post else {
            return Post()
        }
        currentPost.image = ParseFile(data: compressed)
        currentPost.caption = caption
        currentPost.location = location
        return try await currentPost.save()
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
