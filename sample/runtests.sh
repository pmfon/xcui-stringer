#!/usr/bin/env sh

RESULT_PATH=`mktemp -d`
rm -r $RESULT_PATH
xcodebuild test -project xcuistringer-sample.xcodeproj -scheme xcuistringer-sample -destination 'platform=iOS Simulator,name=iPhone 6,OS=10.1' -resultBundlePath $RESULT_PATH
../transform.py $RESULT_PATH/1_Test
