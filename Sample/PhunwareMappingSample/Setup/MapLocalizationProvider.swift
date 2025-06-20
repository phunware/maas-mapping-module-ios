//
//  MapLocalizationProvider.swift
//  PhunwareMappingSample
//
//  Created by Jeff White on 2/5/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareMapping

typealias MapLocalizationResult = Result<MapLocalizationDictionary, Error>

protocol MapLocalizationProvider {

    /// Returns the mapping localization required for rendering localized strings in the mapping module.
    ///  - Parameter languages: The supported languages to fetch localization for
    ///  - Parameter completion: Called when the operation completes
    func fetchMapLocalization(for languages: [MapConfig.Language], completion: @escaping (MapLocalizationResult) -> Void)
}

// MARK: - StubMapLocalizationProvider
class StubMapLocalizationProvider: MapLocalizationProvider {

    func fetchMapLocalization(for languages: [MapConfig.Language], completion: @escaping (MapLocalizationResult) -> Void) {

        func parse() -> MapLocalizationDictionary? {
            guard let data = StubMapLocalizationProvider.localizationData.data(using: .utf8),
                  let rawMapLocalization = try? JSONDecoder().decode(MapLocalizationDictionary.self, from: data) else {
                return nil
            }
            
            return rawMapLocalization
        }

        guard let rawMapLocalization = parse() else {
            completion(.failure(CommonError.internalInconsistency))
            return
        }
        
        var mapLocalization = MapLocalizationDictionary()
        for language in languages {
            if let stringsFileKey = language.stringsFile,
               let languageCodeKey = language.code,
               let stringsDictionary = rawMapLocalization[stringsFileKey] {
                mapLocalization[languageCodeKey] = stringsDictionary
            }
        }
        
        completion(.success(mapLocalization))
    }
}

// MARK: - Stub Data
private extension StubMapLocalizationProvider {
    
    /// Overwrite any localization strings defined in `LocalizableDefaults.xcstrings`
    /// by adding new entries to the JSON payload below.
    /// For example: To use a different string value for the search bar placeholder text,
    ///           we can add a new entry with the key `poi_search_placeholder` to each supported language.
    static let localizationData =
    """
    {
        "strings_en": {
            
        },
        "strings_es": {
            
        },
        "strings_fr": {

        }
    }
    """
}
