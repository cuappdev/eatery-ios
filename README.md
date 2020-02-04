[//]: # (https://github.com/cuappdev/assets/tree/master/eatery)

# Eatery - Cornell Dining Made Simple

<p align="center"><img src=https://raw.githubusercontent.com/cuappdev/assets/master/eatery/Eatery-Long-Logo.png width=500 /></p>

Eatery was the first app made by [AppDev](http://cornellappdev.com/), an engineering project team at Cornell University focused on mobile app development. Eatery provides an easy and accessible way to browse the hours/menus of the dining locations on campus as well as keep track of your dining history. Download the current release on the [Apple App Store](https://itunes.apple.com/us/app/id1089672962).

## Development

### 1. Installation
We use [CocoaPods](http://cocoapods.org) for our dependency manager. This should be installed before continuing.

To access the project, clone the project, and run `pod install` in the project directory.

### 2. Configuration
We use [Firebase](https://firebase.google.com) for our user analytics. You will have to retrieve a `GoogleService-Info.plist` from Firebase and then place it inside the `Eatery/` directory.

We also use `GraphQL` to retrieve data from our backend server and use `Apollo` on the client side in order to help us do so. 

To setup `Apollo`, you will have to first install it by running `npm install -g apollo@1.9` in the project directory (make sure you specify version 1.9).

You will also have to retrieve a `schema.json` file by running: `apollo schema:download --endpoint={Backend_URL} schema.json` in the <strong>project directory</strong>.

Finally, open `Eatery.xcworkspace` and enjoy Eatery!
