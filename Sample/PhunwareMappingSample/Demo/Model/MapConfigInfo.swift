//
//  MapConfigInfo.swift
//  PhunwareMappingSample
//
//  Created by Ivan Lares on 1/30/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation
import CoreLocation

struct MapConfigInfo {
    let mapConfigKey: String
    let mapName: String
    let homeToVenue: HomeToVenueInfo
}

struct HomeToVenueInfo {
    struct Geozone {
        let identifier: String
        let location: CLLocationCoordinate2D
    }
    
    let geozones: [Geozone]
    let geofenceMeter: CLLocationDistance
    
    init(geozones: [Geozone] = [], geofenceMeter: CLLocationDistance = 1000) {
        self.geozones = geozones
        self.geofenceMeter = geofenceMeter
    }
}

extension MapConfigInfo {
    // Austin
    static let austinOfficeBuilding = MapConfigInfo(
        mapConfigKey: MapConfigKey.austinOffice.rawValue,
        mapName: MapName.building.rawValue,
        homeToVenue: .init(geozones: [
            .init(identifier: "5007", location: .init(latitude: 30.27447818822408, longitude: -97.74930040863083))
        ])
    )
    static let austinOfficeCampus = MapConfigInfo(
        mapConfigKey: MapConfigKey.austinOffice.rawValue,
        mapName: MapName.campus.rawValue,
        homeToVenue: .init(geozones: [
            .init(identifier: "5007", location: .init(latitude: 30.27447818822408, longitude: -97.74930040863083))
        ])
    )
}

enum MapConfigKey: String {
    case austinOffice = "map_config"
    
    static let `default`: MapConfigKey = .austinOffice
}

enum MapName: String {
    case campus = "multi_building"
    case building = "single_building"
    
    static let `default`: MapName = .building
}
