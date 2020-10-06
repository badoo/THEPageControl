#!/bin/bash

set -o pipefail

xcodebuild clean build \
    -workspace THEPageControlApp/THEPageControlApp.xcworkspace \
    -scheme THEPageControlApp \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 11' \
    -configuration Debug | xcpretty
