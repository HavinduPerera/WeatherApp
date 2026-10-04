# WeatherApp

A SwiftUI weather dashboard for iOS. Search for any location and get current
conditions, a daily forecast, nearby tourist attractions on a map, and a
persistent list of places you've looked up.

Built with SwiftUI, SwiftData, MapKit and the OpenWeatherMap One Call API 3.0.

## Features

- **Now** — current conditions for the active location, with contextual
  weather advice (clothing, travel, activity suggestions).
- **Forecast** — multi-day daily forecast cards.
- **Map** — the location plus up to five nearby tourist attractions, found via
  `MKLocalSearch` and stored alongside the place.
- **Saved** — every location you've searched, persisted with SwiftData and
  sorted by most recently used. The app reopens on your last location, and
  falls back to London on a first launch.

## Requirements

- Xcode 16 or later (the project uses `objectVersion = 77` synchronized groups)
- iOS 17 or later
- Swift 6
- An OpenWeatherMap API key with **One Call API 3.0** access

## Setup

The API key is not committed. After cloning:

```bash
cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
```

Then open `Config/Secrets.xcconfig` and set your key:

```
OPENWEATHER_API_KEY = your_key_here
```

Open `WeatherDashboardTemplate.xcodeproj` and run. `Config/Secrets.xcconfig`
is gitignored, so your key stays local.

Get a key at [openweathermap.org/api/one-call-3](https://openweathermap.org/api/one-call-3).
One Call 3.0 requires a (free-tier) subscription — a plain default key returns
HTTP 401.

### How the key is wired

`Config/Base.xcconfig` is the project's base configuration. It optionally
includes `Secrets.xcconfig` (via `#include?`, so the project still builds
without it) and exposes `OPENWEATHER_API_KEY`. That value is substituted into
`Config/Info.plist` at build time, and `WeatherService` reads it back with
`Bundle.main.object(forInfoDictionaryKey:)`.

If the key is missing, the app builds and launches but surfaces a
`WeatherMapError.missingAPIKey` explaining what to configure.

## Project structure

```
Config/                 Build configuration and the Info.plist template
WeatherDashboardTemplate/
├── Model/              SwiftData models (Place, AnnotationModel) and API DTOs
├── View/               Tab screens: Current, Forecast, Map, Visited Places
├── Shared/             Reusable cards and detail subviews
├── ViewModel/          MainAppViewModel, WeatherService, LocationManager
└── Utility/            App state, error and success types, formatters
```

The app follows MVVM: `MainAppViewModel` owns all published state and
coordinates `WeatherService` (networking) and `LocationManager` (geocoding and
POI search), while views stay declarative.

## Notes

The Xcode project and target are still named `WeatherDashboardTemplate`, from
the original coursework template this was built on.
