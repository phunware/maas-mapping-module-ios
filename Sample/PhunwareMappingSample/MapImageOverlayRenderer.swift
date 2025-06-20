//
//  MapImageOverlayRenderer.swift
//  PhunwareMappingSample
//
//  Created by Tyler Prevost on 11/12/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import MapKit

class MapImageOverlayRenderer: MKOverlayRenderer {
    let image: UIImage
    
    init(overlay: MKOverlay, image: UIImage) {
        self.image = image
        super.init(overlay: overlay)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let imageReference = image.cgImage else { return }
        
        let rect = self.rect(for: overlay.boundingMapRect)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -rect.size.height)
        context.draw(imageReference, in: rect)
    }
}
