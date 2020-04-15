# DetroitLabsForecast
David Chopin's code test for Detroit Labs.

## Important:
- DetroitLabsForecast makes use of a single cocoapod, SDWebImage, for asynchronous image loading and caching. After downloading the project, be sure to run `pod install` at the root directory. From here, be sure to run the project from the `Detroit Labs Forecast.xcworkspace` file, not the `Detroit Labs Forecast.xcodeproj` file.
- When running on a simulator instead of a real device, you may need to edit your scheme to enable a default location. I've included a .gpx file that represents an area in downtown Detroit. To enable this default location, edit your scheme, go to Run > Options > set the dropdown for Default Location equal to "detroit" (or any one of the other provided cities).