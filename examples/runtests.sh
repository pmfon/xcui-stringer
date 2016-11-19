#!/usr/bin/env sh

pushd $(dirname -- "$0")

RESULT_PATH=`mktemp -d` && rm -r $RESULT_PATH
TEST_TARGET='xcuistringer-sample'
xcodebuild test -project $TEST_TARGET.xcodeproj -scheme $TEST_TARGET -destination 'platform=iOS Simulator,name=iPhone 6,OS=10.1' -resultBundlePath $RESULT_PATH
../transform.py $RESULT_PATH/1_Test

popd
