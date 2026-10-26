fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios release

```sh
[bundle exec] fastlane ios release
```

Build Lift Tracker and upload to App Store Connect

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload an already-built IPA to TestFlight / App Store Connect

### ios submit_lift_tracker

```sh
[bundle exec] fastlane ios submit_lift_tracker
```

Create App Store version, attach build, upload metadata/screenshots, optionally submit

Options: submit:true, skip_screenshots:true

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
