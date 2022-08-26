//
//  MapConfigProvider.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareMapping

typealias MapConfigResult = Result<MapConfig, Error>

protocol MapConfigProvider {

    /// Returns the mapping configuration required for rendering the mapping module.
    ///  - Parameter completion: Called when the operation completes
    func fetchMapConfig(_ completion: @escaping (MapConfigResult) -> Void)
}

// MARK: - StubMapConfigProvider
class StubMapConfigProvider: MapConfigProvider {

    func fetchMapConfig(_ completion: @escaping (MapConfigResult) -> Void) {

        func parse() -> MapConfig? {
            guard let data = StubMapConfigProvider.configData.data(using: .utf8),
                  let mapConfig = try? JSONDecoder().decode(MapConfig.self, from: data) else {
                return nil
            }
            
            return mapConfig
        }

        guard let mapConfig = parse() else {
            completion(.failure(CommonError.internalInconsistency))
            return
        }
        
        completion(.success(mapConfig))
    }
}

// MARK: - Stub Data
private extension StubMapConfigProvider {

    static let configData: String = {
        let invalidID = 0
        let buildingID = invalidID
        let campusID = invalidID
        
        guard [buildingID, campusID].contains(where: { $0 != invalidID }) else {
            fatalError("A building ID or campus ID is required but missing.")
        }
        
        return """
        {
          "features": {
            "featureA": {
              "roles": [
                "contractor",
                "regular"
              ],
              "config": ""
            }
          },
          "languages": [
            {
              "code": "en",
              "displayText": "English",
              "stringsFile": "strings_localization_en"
            },
            {
              "code": "es",
              "displayText": "Español",
              "stringsFile": "strings_localization_es"
            }
          ],
          "mapSettings": {
            "maps": [
              {
                "mapName": "Single Building",
                "buildingConfigs": [
                  {
                    "buildingID": \(buildingID),
                    "languageCode": "en",
                    "onCampusGeozoneIds": [
                      1234,
                      5678
                    ]
                  }
                ],
                "offCampusGeofenceMeters": 1000,
                "lat": 33.0219,
                "long": -117.0826,
                "iOSInitialZoomLatDelta": 0.0015,
                "iOSInitialZoomLongDelta": 0.0015,
                "iOSPOIZoomLatDelta": 0.00025,
                "iOSPOIZoomLongDelta": 0.00025,
                "androidInitialZoomLevel": 18,
                "androidPOIZoomLevel": 21,
                "routeSnappingTolerance": "toleranceHigh",
                "enableManagedCompass": true,
                "enableHometoVenue": true,
                "enableBlueDotLocation": true,
                "enableAccessibleRoutesByDefault": false
              },
              {
                "mapName": "Multi-Building",
                "campusConfigs": [
                  {
                    "campusID": \(campusID),
                    "languageCode": "en",
                    "onCampusGeozoneIds": [
                      1234,
                      5678
                    ]
                  }
                ],
                "offCampusGeofenceMeters": 1000,
                "lat": 33.0219,
                "long": -117.0826,
                "iOSInitialZoomLatDelta": 0.00085,
                "iOSInitialZoomLongDelta": 0.00085,
                "iOSPOIZoomLatDelta": 0.00025,
                "iOSPOIZoomLongDelta": 0.00025,
                "androidInitialZoomLevel": 18,
                "androidPOIZoomLevel": 21,
                "routeSnappingTolerance": "toleranceHigh",
                "enableManagedCompass": true,
                "enableHomeToVenue": true,
                "enableBlueDotLocation": true,
                "enableAccessibleRoutesByDefault": false
              }
            ]
          },
          "categories": [
            {
              "title": "$restroom",
              "poiTypes": [
                "Restroom",
                "Public Restroom"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_publicrestroom%403x-5b892ac6-2ffa-447d-b1d3-be07dfd4744b.png"
            },
            {
              "title": "$elevators",
              "poiTypes": [
                "Elevator",
                "Escalator"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_elevator%403x-e54664c4-73ce-445b-b80e-13a6e3bb026d.png"
            },
            {
              "title": "$dining",
              "poiTypes": [
                "Food Court",
                "Fast Food",
                "Cafeteria"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_dining%403x-bd3595bc-5dea-490b-87e5-399a3b135f86.png"
            },
            {
              "title": "$pharmacy",
              "poiTypes": [
                "Pharmacy"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_pharmacy%403x-7ac6d806-8b35-4a7e-bd30-8540c2eed6cb.png"
            },
            {
              "title": "Areas",
              "poiTypes": [
                "Offices",
                "Dept. Areas"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_department%403x-0f18810f-0319-4a90-bb70-3293f30cb8f5.png"
            },
            {
              "title": "$doctor_offices",
              "poiTypes": [
                "Offices"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/offices-b1f8ab86-fd9d-4790-8fa7-8557b43b6e4a.png"
            },
            {
              "title": "$patient_rooms",
              "poiTypes": [
                "Medical Service",
                "Physician",
                "Dentist",
                "Massage"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_physicianoffices%403x-55cd81d0-138d-4a19-bb94-0b743161b4ab.png"
            },
            {
              "title": "$parking",
              "poiTypes": [
                "Other",
                "Auto Dealerships"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_parking%403x-fba17871-0783-41af-a560-79d0b16af71d.png"
            },
            {
              "title": "$entrances",
              "poiTypes": [
                "Entrance/Exit"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_entrance%403x-ce0ac4bf-bd3a-4afd-9f08-5f7fbcbc347e.png"
            },
            {
              "title": "$waiting_area",
              "poiTypes": [
                "Waiting Area",
                "Seating"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_waitingarea%403x-577aead1-93ea-4827-abba-36a004fb00ba.png"
            },
            {
              "title": "$atm",
              "poiTypes": [
                "Currency Exchange",
                "ATM",
                "Bank"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_atm%403x-46e52c56-c7cd-48b7-955c-d466862cc2cc.png"
            },
            {
              "title": "$cashier",
              "poiTypes": [
                "Money Transferring Service"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_cashier%403x-351634d7-b138-47e3-9cef-e511daae98d8.png"
            },
            {
              "title": "$chapel",
              "poiTypes": [
                "Church"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_church%403x-2a341ac5-d359-43e1-9ad0-2a7d7fb6f901.png"
            },
            {
              "title": "$class_locations",
              "poiTypes": [
                "Education"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_classlocations%403x-894367a6-ee1f-4e17-aabe-1b67397633df.png"
            },
            {
              "title": "$conference_room",
              "poiTypes": [
                "Conference Room"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_conferenceroom%403x-367c5374-9a18-46d5-b580-0774895eac99.png"
            },
            {
              "title": "$lobby",
              "poiTypes": [
                "Information"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_lobby%403x-33a33ff3-9969-427c-a4cd-400ac7d97f97.png"
            },
            {
              "title": "$registration",
              "poiTypes": [
                "Reception"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/registration-97d30a1f-5746-4e16-80d9-dd3dfae2fe37.png"
            },
            {
              "title": "$vending_machine",
              "poiTypes": [
                "Vending Machine"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_vendingmachine%403x-605eb0bb-c497-4132-8820-41dd3e10ea75.png"
            },
            {
              "title": "$water_fountain",
              "poiTypes": [
                "Water Feature"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_waterfountain%403x-574fc485-b17a-418a-9737-286c39c2b08f.png"
            },
            {
              "title": "$gift_shop",
              "poiTypes": [
                "Gift, Antique, & Art"
              ],
              "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/giftshop-fddfaf28-7395-4672-bb0b-838efb057fa3.png"
            }
          ],
          "otherCategory": {
            "title": "$other",
            "iconURL": "https://pw-cme3-api-prod.s3.amazonaws.com/public/assets/Cd56ed6f7-fae1-45a0-8d20-23ab9384d06d/btn_other%403x-db9c1d1f-3c9d-4dc2-8dec-cd2f93ac594f.png"
          },
          "iOSOffRouteConfig": {
            "arrivalThreshold": 4,
            "minOffRouteDistanceThreshold": 9,
            "maxOffRouteDistanceThreshold": 11,
            "maxTimeThresholdSeconds": 5,
            "alertGracePeriodSeconds": 10
          },
          "androidOffRouteConfig": {
            "minOffRouteDistanceThreshold": 5,
            "maxOffRouteDistanceThreshold": 9,
            "offRouteTimeThresholdMilliseconds": 5000,
            "offRouteIdleTimeThresholdMilliseconds": 20000,
            "alertGracePeriodMilliSeconds": 10000
          }
        }
        """
    }()
}
