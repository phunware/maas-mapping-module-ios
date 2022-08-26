//
//  MapOverlay.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import MapKit

class MapOverlay: NSObject, MKOverlay {
    
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    
    func canReplaceMapContent() -> Bool {
        true
    }
    
    init(coordinate: CLLocationCoordinate2D,
         boundingMapRect: MKMapRect) {
        self.coordinate = coordinate
        self.boundingMapRect = boundingMapRect
    }
}
