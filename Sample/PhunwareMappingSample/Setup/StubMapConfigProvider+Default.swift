//
//  StubMapConfigProvider+Default.swift
//  PhunwareMappingSample
//
//  Created by Jeff White on 9/12/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation

// MARK: - Default (PhunHouse) Stub Data
extension StubMapConfigProvider {
    
    static let configData =
    """
    {
      "languages": [
        {
          "code": "en",
          "defaultSpokenLanguageRegion": "US",
          "displayText": "English",
          "stringsFile": "strings_en"
        },
        {
          "code": "es",
          "defaultSpokenLanguageRegion": "MX",
          "displayText": "Español",
          "stringsFile": "strings_es"
        }
      ],
      "mapSettings": {
        "maps": [
          {
            "mapName": "single_building",
            "buildingConfigs": [
              {
                "buildingID": <#Your Building ID#>, // TODO: Replace with your actual Building ID
                "languageCode": "en",
                "onCampusGeozoneIds": [5007],
                "featured": {
                    "title": "Featured",
                    "items": [
                      {
                        "id": "eateries",
                        "title": "Eateries (Test)",
                        "subtitle": "Culinary delights (SD Single Building)",
                        "imageURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/C7d48e86b-d255-469d-8685-90e43971892d/bucket_list_experience-8484d998-7026-439e-8a5a-e4313fec2f50.jpg",
                        "pois": [
                          {
                            "id": "68141844",
                            "title": "Meeting Room",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          },
                          {
                            "id": "68141937",
                            "title": "Lounge Area",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          },
                          {
                            "id": "68144755",
                            "title": "Parking (Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua)",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          }
                        ]
                      },
                      {
                        "id": "rooms",
                        "title": "Luxury Rooms",
                        "subtitle": "Exclusive Suites",
                        "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg",
                        "pois": [
                          {
                            "id": "68141878",
                            "title": "CEO Office",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          },
                          {
                            "id": "68141843",
                            "title": "Office",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          },
                          {
                            "id": "68141943",
                            "title": "Enclosed Work Areas",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          }
                        ]
                      },
                      {
                        "id": "parking",
                        "title": "Parking",
                        "subtitle": "Single Building",
                        "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/Atlantis%20Shuttle.jpg",
                        "pois": [
                          {
                            "id": "68144755",
                            "title": "Parking (Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua)",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          }
                        ]
                      },
                    ]
                  }
              },
              {
                "buildingID": <#Your Building Id#>, // TODO: Replace with your actual Building ID
                "languageCode": "es",
                "onCampusGeozoneIds": [5007],
                "featured": {
                    "title": "Presentado",
                    "items": [
                      {
                        "id": "parking",
                        "title": "Estacionamiento",
                        "subtitle": "Encontrar Estacionamiento",
                        "imageURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/C7d48e86b-d255-469d-8685-90e43971892d/bucket_list_experience-8484d998-7026-439e-8a5a-e4313fec2f50.jpg",
                        "pois": [
                          {
                            "id": "73264775",
                            "title": "Estacionamiento Reservado",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          },
                          {
                            "id": "73264609",
                            "title": "Estacionamiento",
                            "imageURL": "https://cme3-api.phunware.com/v3.0/assets/C7d48e86b-d255-469d-8685-90e43971892d/leap_of_faith.jpg"
                          }
                        ]
                      }
                    ]
                  }
              }
            ],
            "offCampusGeofenceMeters": 1000,
            "lat": <#latitude#>,  // TODO: Replace with your actual latitude
            "long": <#longitude#>,  // TODO: Replace with your actual longitude
            "iOSInitialZoomLatDelta": 0.005,
            "iOSInitialZoomLongDelta": 0.005,
            "androidInitialZoomLevel": 18,
            "androidPOIZoomLevel": 22,
            "routeSnappingTolerance": "toleranceHigh",
            "enableHomeToVenue": true,
            "enableAccessibleRoutesByDefault": false,
            "enableBlueDotLocation": true,
            "enableLandmarkBasedRouting": true,
            "enableMeetingRoomStatus": false,
            "meetingRoomStatusRefreshIntervalMilliSeconds": 60000,
            "enableDisplayPOIsByDistance": true,
            "travelTimeMetersPerSecond": 1.4,
            "enableWaitTimes": true,
            "waitTimeURL": "https://map-api.phunware.com/v3.0/poiWaitTime"
          },
          {
            "mapName": "multi_building",
            "campusConfigs": [
              {
                "campusID": 88237,
                "languageCode": "en",
                "onCampusGeozoneIds": [5007]
              },
              {
                "campusID": 88237,
                "languageCode": "es",
                "onCampusGeozoneIds": [5007]
              }
            ],
            "offCampusGeofenceMeters": 1000,
            "lat": 30.274448,
            "long": -97.749304,
            "iOSInitialZoomLatDelta": 0.0005,
            "iOSInitialZoomLongDelta": 0.0005,
            "androidInitialZoomLevel": 18,
            "androidPOIZoomLevel": 22,
            "routeSnappingTolerance": "toleranceHigh",
            "enableHomeToVenue": true,
            "enableAccessibleRoutesByDefault": false,
            "enableBlueDotLocation": true,
            "enableLandmarkBasedRouting": true,
            "enableMeetingRoomStatus": false,
            "meetingRoomStatusRefreshIntervalMilliSeconds": 60000,
            "enableDisplayPOIsByDistance": true,
            "travelTimeMetersPerSecond": 1.4,
            "enableWaitTimes": true,
            "waitTimeURL": "https://map-api.phunware.com/v3.0/poiWaitTime"
          }
    
        ]
      },
      "categories": [
        "elevators-escalators",
        "elevators",
        "escalators",
        "restrooms",
        "dining",
        "pharmacy",
        "workspaces",
        "medical-services",
        "parking",
        "seating-areas",
        "atm",
        "guest-services",
        "chapels",
        "education",
        "conference-rooms",
        "information",
        "reception",
        "registration",
        "vending-machines",
        "water-fountains",
        "shopping",
        "defibrillator",
        "nursing-rooms",
        "aquariums",
        "rides",
        "towel-stations",
        "valet"
      ],
      "offRouteConfig": {
        "partiallyOffRouteThresholdInMeters": 6,
        "partiallyOffRouteAllowanceInSeconds": 3,
        "fullyOffRouteThresholdInMeters": 10
      },
      "iosRouteUIConfig": {
        "routeStrokeColor": "#254297FF",
        "directionFillColor": "#254297FF",
        "directionStrokeColor": "#254297FF",
        "instructionFillColor": "#254297FF",
        "routeStrokeWidth": 4,
        "directionStrokeWidth": 4,
        "instructionStrokeWidth": 4,
        "joinPointColor": "#254297FF",
        "showJoinPoint": false
      },
      "routeUiConfig": {
        "maneuverColor": "00693f",
        "maneuverDirectionColor": "00693f",
        "routeColor": "00693f",
        "maneuverStrokeWidth": 4,
        "maneuverDirectionStrokeWidth": 4,
        "routeStrokeWidth": 4
      },
      "routeArrivalConfig": {
        "arrivalThreshold": 5
      }
    }
    """
}
