[//]: # (https://github.com/cuappdev/assets/tree/master/eatery)

# Eatery - Cornell Dining Made Simple

<p align="center"><img src=https://raw.githubusercontent.com/cuappdev/assets/master/eatery/Eatery-Long-Logo.png width=500 /></p>

Eatery was the first app made by [AppDev](http://cornellappdev.com/), an engineering project team at Cornell University focused on mobile app development. Eatery provides an easy and accessible way to browse the hours/menus of the dining locations on campus as well as keep track of your dining history. Download the current release on the [Apple App Store](https://itunes.apple.com/us/app/id1089672962)

## Development

### 1. Installation
We use [CocoaPods](http://cocoapods.org) for our dependency manager. This should be installed before continuing.

To access the project, clone the project, and run `pod install` in the project directory.

### 2. Configuration
We use [Fabric](https://fabric.io) and Crashlytics for our user analytics. To run the project without a Fabric account, comment out this line in `AppDelegate.swift`:
```swift
Crashlytics.start(withAPIKey: Keys.fabricAPIKey.value)
```

Otherwise, to build the project, you need a `Secrets/Keys.plist` file in the project in order to use Fabric / Crashlytics:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>fabric-api-key</key>
	<string>INSERT_API_KEY</string>
	<key>fabric-build-secret</key>
	<string>INSERT_BUILD_SECRET</string>
</dict>
</plist>

```

Finally, open `Eatery.xcworkspace` and enjoy Eatery!
