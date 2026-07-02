# Codemagic build

This project is set up for Windows-to-iOS builds through Codemagic.

## First build: simulator prototype

Run the `ios-simulator-prototype` workflow first. It does not require Apple signing and proves that the SwiftUI app and XCTest target compile on a Codemagic Mac.

Artifacts:

- `OneulDal.app` from the iOS Simulator build
- `OneulDalTests.xcresult`
- Xcode logs

## TestFlight build

Run `ios-testflight` after Apple signing is ready.

Required Codemagic setup:

- Connect the repository containing this `oneuldal-ios` folder.
- Make Codemagic read `codemagic.yaml` from the project root.
- Add an App Store Connect integration named `oneuldal-app-store-connect`, or update `codemagic.yaml` to match your integration name.
- Create or fetch an App Store provisioning profile for `com.oneuldal.app`.
- Set `DEVELOPMENT_TEAM` in Codemagic variables.
- Confirm `PROVISIONING_PROFILE_SPECIFIER` matches the profile name. The default is `OneulDal App Store Profile`.

If App Store Connect uses a different bundle id, update `BUNDLE_ID` in `codemagic.yaml` before running the TestFlight workflow.

## Trigger

The TestFlight workflow runs on tags matching `ios-*`, for example:

```sh
git tag ios-0.1.0
git push origin ios-0.1.0
```

The simulator workflow can be run manually from Codemagic for quick validation.
