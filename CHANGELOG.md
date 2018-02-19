# Changelog

## Version 1.1

*TBD*

[View Issues][v1.1-issues]

**Features:**

- Added `BUILD_TESTS` CMake configuration variable

## Version 1.0

*March 27, 2017*

[View Issues][v1.0-issues]

**Features:**

- Using CMake version 3.3
- Installs LibWebRTC as a CMake package
- Support for `gn`-based releases
- Synchronize depot_tools with WebRTC's commit date
- `TARGET_OS` and `TARGET_CPU` CMake config variables
- `WEBRTC_REVISION` and `WEBRTC_BRANCH_HEAD` CMake config variables
- x86 support under Windows
- Better host OS and CPU architecture detection
- pkg-config file generation
- Deprecated shared library support
- Debug mode support
- .zip package for Windows, .tar.gz for Unix
- Basic .deb and .rpm package generation

**Fixes:**

- Removed package.json and Jake support, focusing on CMake only
- Refactored source code, removed Targets folder
- Run commands with `cmake -E env`, no more Prefix File Trick
- No more `merge_libs.py` call, use CMake to create the library
- Removed the peer connection sample, wrote a little executable for tests
- Removed FindLibWebRTC.cmake, defined CMake package files
- Removed depot_tools git submodule
- Retrieve the Linux sysroot before calling the generator
- Removed support for releases older than January 1st, 2017 for now
- Removed libwebrtc-chromium-deps repository
- Wrote libwebrtc_execute macro
- Created uninstall target
- Removed BUILD_TESTS flag for now
- Fixed static linking

[v1.1-issues]:https://github.com/aisouard/libwebrtc/milestone/1
[v1.0-issues]:https://github.com/aisouard/libwebrtc/milestone/1
