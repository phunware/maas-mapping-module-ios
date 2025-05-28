# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.9.2] - 2025-05-22

### Fixed

- Background views not respecting the background color assigned to the theme  

## [1.9.1] - 2025-1-14

### Fixed

- Centers the text position of the Map Navigation Button (RoundToggleButton)
- Fixes spanish translations for maps and routing
- Adjusts placement of the accessible toggle to be more prominent
- Hides empty categories

## [1.9.0] - 2024-11-21

### Added

- Added featured lists feature
- Added audio player to POI detail
- Added category and building selector to search view
- Added French localization support
- Added image caching

### Changed

- Migrated config structure for featured lists and off-route prompt

### Fixed

- Fixed an issue where turn-by-turn cards not updating while wayfinding

## [1.8.6] - 2024-04-08

### Fixed

- Fixed an issue where wait times API affecting category load times.

## [1.8.5] - 2023-11-07

### Fixed

- Fixed an issue where acquiring blue-dot would fail when multiple instances of the Mapping Module are created.

## [1.8.4] - 2023-09-29

### Fixed

- Fixed an issue where URL components required for constructing deep links were not accessible through public API

## [1.8.3] - 2023-09-15

### Fixed

- Fixed an issue where the location permission priming screen could become unresponsive

## [1.8.2] - 2023-08-30

### Changed

- Improved routing performance

## [1.8.1] - 2023-07-20

### Fixed

- Fixed an issue where the floor name could not be overridden for a POI

## [1.8.0] - 2023-05-18

### Added

- Added POI wait time feature
- Added category list deep link support

### Changed

- Changed "Map View" screen view analytic to "Map Screen View"

### Fixed

- Fixed off-route prompt issue where prompt wasn't shown if user is on a different floor

## [1.7.1] - 2023-04-23

### Added

- Added multi-map support to share my location feature

### Changed

- Changed arrival card interface and dismissal mechanism
- Changed share my location feature to automatically place a pin if user location (blue-dot) is acquired

### Fixed

- Fixed issue with turn-by-turn static routing while user location (blue-dot) is enabled
- Fixed issue where off route prompt is shown with static routing

## [1.7.0] - 2023-02-23

### Added

- Added ability to show an arrival card
- Added support for landmark routing
- Added support for voice directions
- Added ability to show remaining distance to points of interest
- Added ability to show remaining walk time to points of interest

## [1.4.0] - 2022-08-22

### Added

- Initial release

[1.9.2]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.9.2%0D1.9.1
[1.9.1]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.9.1%0D1.9.0
[1.9.0]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.9.0%0D1.8.6
[1.8.6]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.8.6%0D1.8.5
[1.8.5]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.8.5%0D1.8.4
[1.8.4]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.8.4%0D1.8.3
[1.8.3]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.8.3%0D1.8.2
[1.8.2]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.8.2%0D1.8.1
[1.8.1]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.8.1%0D1.8.0
[1.8.0]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.8.0%0D1.7.1
[1.7.1]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.7.1%0D1.7.0
[1.7.0]: https://bitbucket.org/phunware/module-phunware-mapping-ios/branches/compare/1.7.0%0D1.4.0
[1.4.0]: https://bitbucket.org/phunware/module-phunware-mapping-ios/src/1.4.0/
