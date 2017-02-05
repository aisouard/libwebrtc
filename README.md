# libwebrtc [![License][license-img]][license-href] [![Build Status][travis-img]][travis-href] [![Build Status][appveyor-img]][appveyor-href]

[![Join the chat at https://gitter.im/aisouard/libwebrtc](https://badges.gitter.im/aisouard/libwebrtc.svg)](https://gitter.im/aisouard/libwebrtc?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> CMake script for retrieving, building and linking Google's WebRTC into a single static library.

## Status

The following table displays the current state of this project, including 
supported platforms and architectures.

<table>
  <tr>
    <th colspan="3">Linux</th>
    <th colspan="2">macOS</th>
    <th colspan="2">Windows</th>
    <th colspan="1">iOS</th>
    <th colspan="4">Android</th>
  </tr>
  <tr>
    <td align="center">x86</td>
    <td align="center">x64</td>
    <td align="center">arm</td>
    <td align="center">x86</td>
    <td align="center">x64</td>
    <td align="center">x86</td>
    <td align="center">x64</td>
    <td align="center">arm</td>
    <td align="center">arm</td>
    <td align="center">arm64</td>
    <td align="center">x86</td>
    <td align="center">x64</td>
  </tr>
  <tr>
    <td align="center">✔</td>
    <td align="center">✔</td>
    <td></td>
    <td></td>
    <td align="center">✔</td>
    <td></td>
    <td align="center">✔</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
</table>

## Prerequisites

- CMake 3.5 or later,
- Python 2.7 (optional for Windows)

### Debian & Ubuntu

Install the required development packages

```
# apt-get install build-essential libglib2.0-dev libgtk2.0-dev libxtst-dev \
                  libxss-dev libpci-dev libdbus-1-dev libgconf2-dev \
                  libgnome-keyring-dev libnss3-dev libasound2-dev libpulse-dev \
                  libudev-dev
```

### macOS

- OS X 10.11 or later,
- Xcode 7.3.1 or later

### Windows

* Windows 7 x64 or later, x86 operating systems are unsupported.
* Visual Studio 2015 **with updates** - Download the [Installer][vs2015-installer]

  Make sure that you install the following components:
  
  * Visual C++, which will select three sub-categories including MFC
  * Universal Windows Apps Development Tools > Tools
  * Universal Windows Apps Development Tools > Windows 10 SDK (**10.0.10586**)

## Getting Started

Clone the repository, initialize the submodules if `depot_tools` is not
installed on your system or not defined inside your `PATH` environment variable.
Create an output directory and browse inside it.

```
$ git clone https://github.com/aisouard/libwebrtc.git
$ cd libwebrtc
$ git submodule init
$ git submodule update
$ mkdir out
$ cd out
```

Windows users **must** append `Win64` if they are using a Visual Studio
generator. The `libwebrtc.sln` project solution will be located inside the
current directory output directory.

```
> cmake -G "Visual Studio 14 2015 Win64" ..
```

Unix users will just have to run `$ cmake ..` to generate the Makefiles, then
run the following commands.

```
$ make
$ make package
# make install
```

The library will be located inside the `lib` folder of the current output
directory. The `include` folder will contain the header files.

## Using WebRTC in your project

Copy the `CMakeModules/FindLibWebRTC.cmake` file inside your CMake modules
directory. Let CMake find your libwebrtc headers and libraries with the
`find_package(LibWebRTC)` the following CMake variables will be created:

- **LIBWEBRTC_DEFINITIONS** - Preprocessor definitions, such as enabling C++11
features, to be used with `add_definitions`
- **LIBWEBRTC_INCLUDE_DIRS** - Include directories, use it with
`include_directories`
- **LIBWEBRTC_LIBRARIES** - List of required libraries to link your software,
use it with `target_link_libraries`

Here is what a CMakeLists.txt file should look like:

```
project(sample)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/CMakeModules)

find_package(LibWebRTC REQUIRED)

set(SOURCE_FILES main.cpp)

include_directories(${LIBWEBRTC_INCLUDE_DIRS})
add_definitions(${LIBWEBRTC_DEFINITIONS})
add_executable(sample ${SOURCE_FILES})
target_link_libraries(sample ${LIBWEBRTC_LIBRARIES})
```

## Advanced Usage

The library will be compiled and usable on the same host's platform and
architecture. Here are some CMake flags which could be useful if you need to
perform cross-compiling.

- **BUILD_SAMPLES**

    Build `PeerConnection` sample, source code located inside the
    Samples/PeerConnection directory.

- **BUILD_TESTS**

    Build WebRTC tests. (not supported yet)

- **NINJA_ARGS**

    Arguments to pass while executing the `ninja` command. For instance, you can
    define the number of cores you would like to use, in order to speed-up the
    build process:
    
    `cmake -DNINJA_ARGS="-j 4" ..`

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

## Contributing

Feel free to open an issue if you wish a bug to be fixed, to discuss a new
feature or to ask a question. I'm open to pull requests, as long as your
modifications are working on the three major OS (Windows, macOS and Linux).

Don't forget to put your name and e-mail address inside the `AUTHORS` file!
You can also reach me on [Twitter][twitter] for further discussion.

## License

Apache License 2.0 © [Axel Isouard][author]

[license-img]:https://img.shields.io/badge/License-Apache%202.0-blue.svg
[license-href]:https://opensource.org/licenses/Apache-2.0
[appveyor-img]:https://ci.appveyor.com/api/projects/status/yd1s303md3tt4w9a?svg=true
[appveyor-href]:https://ci.appveyor.com/project/aisouard/libwebrtc
[travis-img]:https://travis-ci.org/aisouard/libwebrtc.svg?branch=master
[travis-href]:https://travis-ci.org/aisouard/libwebrtc
[osx1011sdk]: https://github.com/phracker/MacOSX-SDKs/releases/download/MacOSX10.11.sdk/MacOSX10.11.sdk.tar.xz
[vs2015-installer]:https://www.microsoft.com/en-US/download/details.aspx?id=48146
[twitter]:https://twitter.com/aisouard
[author]:https://axel.isouard.fr