# libwebrtc

[![Build Status][travis-img]][travis-href]
[![Build Status][appveyor-img]][appveyor-href]

Build scripts to help retrieving and compiling WebRTC C++ native libraries.

## Status

The following table displays the current state of this project, including 
supported platforms and architectures.

<table>
  <tr>
    <th></th>
    <th colspan="3">Linux</th>
    <th colspan="2">Mac OS X</th>
    <th colspan="2">Windows</th>
    <th colspan="1">iOS</th>
    <th colspan="1">Android</th>
  </tr>
  <tr>
    <td></td>
    <td>x86</td>
    <td>x64</td>
    <td>arm</td>
    <td>x86</td>
    <td>x64</td>
    <td>x86</td>
    <td>x64</td>
    <td>arm</td>
    <td>arm</td>
  </tr>
  <tr>
    <th>CMake 2.8</th>
    <td>-</td>
    <td bgcolor="#C0F73E">Done</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td bgcolor="#C0F73E">Done</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <th>Jake</th>
    <td>-</td>
    <td bgcolor="#C0F73E">Done</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td bgcolor="#C0F73E">Done</td>
    <td>-</td>
    <td>-</td>
  </tr>
</table>

## Prerequisites

### Linux

### Mac OS X

### Windows

* Windows 7 x64 or later, x86 operating systems are unsupported.
* Visual Studio 2015 Update 2 - Download the [Installer][vs2015-installer] or
[ISO image][vs2015-iso]

  Make sure that you install the following components:
  
  * Visual C++, which will select three sub-categories including MFC
  * Universal Windows Apps Development Tools > Tools
  * Universal Windows Apps Development Tools > Windows 10 SDK (**10.0.10586**)

[appveyor-img]:https://ci.appveyor.com/api/projects/status/yd1s303md3tt4w9a?svg=true
[appveyor-href]:https://ci.appveyor.com/project/aisouard/libwebrtc
[travis-img]:https://travis-ci.org/aisouard/libwebrtc.svg?branch=master
[travis-href]:https://travis-ci.org/aisouard/libwebrtc
[vs2015-installer]:https://go.microsoft.com/fwlink/?LinkId=615448&clcid=0x409
[vs2015-iso]:https://go.microsoft.com/fwlink/?LinkId=615448&clcid=0x409