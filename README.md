# libwebrtc [![License][license-img]][license-href] [![Join the chat at https://gitter.im/aisouard/libwebrtc][gitter-img]][gitter-href] [![Build Status][travis-img]][travis-href] [![Build Status][appveyor-img]][appveyor-href]

This repository contains a collection of CMake scripts to help you embed
Google's native WebRTC implementation inside your project as simple as this:

```cmake
cmake_minimum_required(VERSION 3.3)
project(sample)

find_package(LibWebRTC REQUIRED)
include(${LIBWEBRTC_USE_FILE})

set(SOURCE_FILES main.cpp)
add_executable(sample ${SOURCE_FILES})
target_link_libraries(sample ${LIBWEBRTC_LIBRARIES})
```

It also produces a `pkg-config` file if you prefer the classic way:

```
$ g++ `pkg-config --cflags LibWebRTC` main.cpp -o main `pkg-config --libs LibWebRTC`
```

## Status

The following table displays the current state of this project, including
supported platforms and architectures.

<table>
  <tr>
    <td align="center"></td>
    <td align="center">x86</td>
    <td align="center">x64</td>
    <td align="center">arm</td>
    <td align="center">arm64</td>
  </tr>
  <tr>
    <th align="center">Linux</th>
    <td align="center">✔</td>
    <td align="center">✔</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <th align="center">macOS</th>
    <td align="center">-</td>
    <td align="center">✔</td>
    <td align="center">-</td>
    <td align="center">-</td>
  </tr>
  <tr>
    <th align="center">Windows</th>
    <td align="center">✔</td>
    <td align="center">✔</td>
    <td></td>
    <td></td>
  </tr>
</table>

## Prerequisites

- CMake 3.3 or later
- Python 2.7 (optional for Windows since it will use the interpreter located
  inside the `depot_tools` installation)

### Debian & Ubuntu

- Required development packages:

```
# apt-get install build-essential libglib2.0-dev libgtk2.0-dev libxtst-dev \
                  libxss-dev libpci-dev libdbus-1-dev libgconf2-dev \
                  libgnome-keyring-dev libnss3-dev libasound2-dev libpulse-dev \
                  libudev-dev
```

- GCC & G++ 4.8 or later, for C++11 support

### macOS

- OS X 10.11 or later
- Xcode 7.3.1 or later

### Windows

- Windows 7 x64 or later
- Visual Studio 2015 **with updates** - Download the [Installer][vs2015-installer]

  Make sure that you install the following components:
  
  - Visual C++, which will select three sub-categories including MFC
  - Universal Windows Apps Development Tools
    - Tools (1.4.1) and Windows 10 SDK (**10.0.14393**)

- [Windows 10 SDK][w10sdk] with **Debugging Tools for Windows** or
  [Windows Driver Kit 10][wdk10] installed in the same Windows 10 SDK
  installation directory.

## Compiling

Clone the repository, create an output directory, browse inside it,
then run CMake.

```
$ git clone https://github.com/aisouard/libwebrtc.git
$ cd libwebrtc
$ mkdir out
$ cd out
$ cmake ..
```

Windows users **must** add the Win64 suffix to their Visual Studio generator
name if they want to build the library for 64-bit platforms, they'll omit it for
32-bit builds and define the `TARGET_CPU` variable accordingly.

```
> cmake -G "Visual Studio 14 2015" -DTARGET_CPU=x86
> cmake -G "Visual Studio 14 2015 Win64"
```

Then they'll have to open the `libwebrtc.sln` located inside the current output
directory and build the `ALL_BUILD` project.

Unix users will just have to run the following `make` commands.

```
$ make
# make install
```

The library will be located inside the `lib` folder of the current output
directory. The `include` folder will contain the header files. CMake scripts
will be placed inside the `lib/cmake/LibWebRTC` directory.

## Debug and Release configurations

If you are using XCode or Visual Studio, you can simply switch between the Debug
and Release configuration from your IDE. The debugging flags will be
appended to the generator's parameters.

Otherwise, you must define the `CMAKE_BUILD_TYPE` variable to `Debug`.

```
$ cmake -DCMAKE_BUILD_TYPE=Debug ..
```

## Using WebRTC in your project

At the time of writing this README file, there's no proper way to detect any
installation of the WebRTC library and header files. In the meantime, this CMake
script generates and declares a `LibWebRTC` package that will be very easy to
use for your projects.

All you have to do is include the package, then embed the "use file" that will
automatically find the required libraries, define the proper compiling flags and
include directories.

```cmake
find_package(LibWebRTC REQUIRED)
include(${LIBWEBRTC_USE_FILE})

target_link_libraries(my-app ${LIBWEBRTC_LIBRARIES})
```

A pkg-config file is also provided, you can obtain the required compiler and
linker flags by specifying `LibWebRTC` as the package name.

```
$ pkg-config --cflags --libs LibWebRTC
```

## Fetching a specific revision

The latest working release will be fetched by default, unless you decide to
retrieve a specific commit by setting it's hash into the **WEBRTC_REVISION**
CMake variable, or another branch head ref into the **WEBRTC_BRANCH_HEAD**
variable.

```
$ cmake -DWEBRTC_REVISION=be22d51 ..
$ cmake -DWEBRTC_BRANCH_HEAD=refs/branch-heads/57 ..
```

If both variables are set, it will focus on fetching the commit defined inside
**WEBRTC_REVISION**.

## Managing depot_tools

CMake will retrieve the latest revision of the `depot_tools` repository. It will
get the WebRTC repository's commit date, then check-out `depot_tools` to the
commit having the closest date to WebRTC's, in order to ensure a high
compatibility with `gclient` and other tools.

It is possible to prevent this behavior by specifying the location to your own
`depot_tools` repository by defining the **DEPOT_TOOLS_PATH** variable.

```
$ cmake -DDEPOT_TOOLS_PATH=/opt/depot_tools ..
```

## Configuration

The library will be compiled and usable on the same host's platform and
architecture. Here are some CMake flags which could be useful if you need to
perform cross-compiling.

- **BUILD_DEB_PACKAGE**

    Generate Debian package, defaults to OFF, available under Linux only.

- **BUILD_RPM_PACKAGE**

    Generate Red Hat package, defaults to OFF, available under Linux only.

- **BUILD_TESTS**

    Build WebRTC unit tests and mocked classes such as `FakeAudioCaptureModule`.

- **BUILD_SAMPLE**

    Build an executable located inside the `sample` folder.

- **DEPOT_TOOLS_PATH**

    Set this variable to your own `depot_tools` directory. This will prevent
    CMake from fetching the one matching with the desired WebRTC revision.

- **GN_EXTRA_ARGS**

    Add extra arguments to the `gn gen --args` parameter.

- **NINJA_ARGS**

    Arguments to pass while executing the `ninja` command.

- **TARGET_OS**

    Target operating system, the value will be used inside the `--target_os`
    argument of the `gn gen` command. The value **must** be one of the following:
    
    - `android`
    - `chromeos`
    - `ios`
    - `linux`
    - `mac`
    - `nacl`
    - `win`

- **TARGET_CPU**

    Target architecture, the value will be used inside the `--target_cpu`
    argument of the `gn gen` command. The value **must** be one of the following:
    
    - `x86`
    - `x64`
    - `arm`
    - `arm64`
    - `mipsel`

- **WEBRTC_BRANCH_HEAD**

    Set the branch head ref to retrieve, it is set to the latest working one.
    This variable is ignored if **WEBRTC_REVISION** is set.

- **WEBRTC_REVISION**

    Set a specific commit hash to check-out.

## Contributing

Feel free to open an issue if you wish a bug to be fixed, to discuss a new
feature or to ask a question. I'm open to pull requests, as long as your
modifications are working on the three major OS (Windows, macOS and Linux).

Don't forget to put your name and e-mail address inside the `AUTHORS` file!
You can also reach me on [Twitter][twitter] for further discussion.

## Acknowledgements

Many thanks to Dr. Alex Gouaillard for being an excellent mentor for this
project.

Everything started from his
« [Automating libwebrtc build with CMake][webrtc-dr-alex-cmake] » blog article,
which was a great source of inspiration for me to create the easiest way to link
the WebRTC library in any native project.

## License

Apache License 2.0 © [Axel Isouard][author]

[license-img]:https://img.shields.io/badge/License-Apache%202.0-blue.svg
[license-href]:https://opensource.org/licenses/Apache-2.0
[appveyor-img]:https://ci.appveyor.com/api/projects/status/yd1s303md3tt4w9a?svg=true
[appveyor-href]:https://ci.appveyor.com/project/aisouard/libwebrtc
[travis-img]:https://travis-ci.org/aisouard/libwebrtc.svg?branch=master
[travis-href]:https://travis-ci.org/aisouard/libwebrtc
[gitter-img]:https://badges.gitter.im/aisouard/libwebrtc.svg
[gitter-href]:https://gitter.im/aisouard/libwebrtc?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
[osx1011sdk]: https://github.com/phracker/MacOSX-SDKs/releases/download/MacOSX10.11.sdk/MacOSX10.11.sdk.tar.xz
[vs2015-installer]:https://www.microsoft.com/en-US/download/details.aspx?id=48146
[w10sdk]:https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk
[wdk10]:https://go.microsoft.com/fwlink/p/?LinkId=526733
[twitter]:https://twitter.com/aisouard
[webrtc-dr-alex-cmake]:http://webrtcbydralex.com/index.php/2015/07/22/automating-libwebrtc-build-with-cmake
[author]:https://axel.isouard.fr
