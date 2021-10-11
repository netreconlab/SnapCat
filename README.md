# SnapCat
![Swift](https://img.shields.io/badge/swift-5.4-brightgreen.svg) ![Xcode 13.0+](https://img.shields.io/badge/xcode-13.0%2B-blue.svg) ![iOS 15.0+](https://img.shields.io/badge/iOS-15.0%2B-blue.svg) ![ci](https://github.com/netreconlab/SnapCat/workflows/ci/badge.svg?branch=main)

<img src="https://user-images.githubusercontent.com/8621344/126432401-b1ffce20-ec39-4a44-9757-ced7ca7f59d7.png" width="250"> <img src="https://user-images.githubusercontent.com/8621344/126432735-10159e91-1a7f-4b70-854c-ffbb087ae239.png" width="250"> <img src="https://user-images.githubusercontent.com/8621344/126432438-143fea01-7e88-4eea-945d-ea81ef9c45b7.png" width="250">

SnapCat is a social media application for posting pictures, comments, and finding friends. SnapCat is designed using SwiftUI and the [ParseSwift SDK](https://github.com/parse-community/Parse-Swift). The app is meant to serve as a base app for University of Kentucky graudate researchers and undergraduate students learning iOS mobile app development.

## Setup Your Parse Server
You can setup your parse-server locally to test using [snapcat branch](https://github.com/netreconlab/parse-hipaa/tree/snapcat) of [parse-hipaa](https://github.com/netreconlab/parse-hipaa). Simply type the following to get your parse-server running with postgres locally:

1. Fork [parse-hipaa](https://github.com/netreconlab/parse-hipaa/tree/snapcat)
2. `cd parse-hipaa`
3.  `docker-compose up` - this will take a couple of minutes to setup as it needs to initialize postgres, but as soon as you see `parse-server running on port 1337.`, it's ready to go. See [here](https://github.com/netreconlab/parse-hipaa#getting-started) for details
4. If you would like to use mongo instead of postgres, in step 3, type `docker-compose -f docker-compose.mongo.yml up` instead of `docker-compose up`

## Fork this repo 

1. Fork [SnapCat](https://github.com/netreconlab/SnapCat.git), in particular the [snapcat branch](https://github.com/netreconlab/parse-hipaa/tree/snapcat).
2. Open `SnapCat.xcodeproj` in Xcode
3. You may need to configure your "Team" and "Bundle Identifier" in "Signing and Capabilities"
4. Run the app and data will synchronize with parse-hipaa via http://localhost:1337/parse automatically
5. You can edit Parse server setup in the ParseSwift.plist file in the Xcode browser

## View your data in Parse Dashboard
Parse Dashboard is the easiest way to view your data in the Cloud (or local machine in this example) and comes with [parse-hipaa](https://github.com/netreconlab/parse-hipaa). To access:
1. Open your browser and go to http://localhost:4040/dashboard
2. Username: `parse`
3. Password: `1234`
4. Be sure to refresh your browser to see new changes synched from your CareKitSample app
