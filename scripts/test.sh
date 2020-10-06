#!/bin/bash

set -o pipefail

xcodebuild clean test \
    -project THEPageControl/THEPageControl.xcodeproj \
    -scheme THEPageControl \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 11' \
    -configuration Debug | xcpretty
