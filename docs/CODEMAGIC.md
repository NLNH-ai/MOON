# Codemagic build

This project is set up for Windows-to-iOS builds through Codemagic.

## First build: simulator prototype

Run the `ios-simulator-prototype` workflow first. It does not require Apple signing and proves that the SwiftUI app and XCTest target compile on a Codemagic Mac.

Artifacts:

- `OneulDal.app` from the iOS Simulator build
- `OneulDalTests.xcresult`
- Xcode logs

## TestFlight internal build

Run `ios-testflight` after Apple signing is ready. This workflow creates an App Store signed IPA and uploads it to App Store Connect for TestFlight internal testing.

Required Codemagic setup:

- Connect the repository containing this `oneuldal-ios` folder.
- Make Codemagic read `codemagic.yaml` from the project root.
- In Apple Developer, create an explicit App ID for `com.oneuldal.app`.
- In App Store Connect, create the app record using bundle ID `com.oneuldal.app`.
- In App Store Connect, create a dedicated API key with `App Manager` access and download the `.p8` key once.
- In Codemagic Team settings > Team integrations > Developer Portal, add that API key with the name `oneuldal-app-store-connect`, or update `codemagic.yaml` to match your integration name.
- In Codemagic Team settings > codemagic.yaml settings > Code signing identities, add or generate an `Apple Distribution` certificate.
- In Codemagic Team settings > codemagic.yaml settings > Code signing identities > iOS provisioning profiles, fetch or upload an App Store profile matching `com.oneuldal.app`.

If App Store Connect uses a different bundle id, update `BUNDLE_ID` in `codemagic.yaml` before running the TestFlight workflow.

The workflow uses Codemagic CLI tooling to apply matching App Store signing files:

- `xcode-project use-profiles --custom-export-options='{"testFlightInternalTestingOnly": true}'`
- `xcode-project build-ipa`

The `testFlightInternalTestingOnly` export option is intentional for quick device testing. It avoids external beta review and limits the build to App Store Connect internal tester groups.

## Trigger

The TestFlight workflow runs on tags matching `ios-*`, for example:

```sh
git tag ios-0.1.0
git push origin ios-0.1.0
```

The simulator workflow can be run manually from Codemagic for quick validation.
