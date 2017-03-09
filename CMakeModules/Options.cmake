#
# Options, flags
option(BUILD_TESTS "Build test binaries" OFF)
set(NINJA_ARGS "" CACHE STRING "Ninja arguments to pass before compiling WebRTC")
set(GN_EXTRA_ARGS "" CACHE STRING "Extra gn gen arguments to pass before generating build files")
option(BUILD_SHARED_LIB "Build WebRTC as a shared library" OFF)
set(WEBRTC_REVISION "" CACHE STRING "WebRTC commit hash to checkout")
set(WEBRTC_BRANCH_HEAD "${LIBWEBRTC_WEBRTC_HEAD}" CACHE STRING "WebRTC branch head to checkout")

if(BUILD_SHARED_LIB)
  set(LIBRARY_TYPE SHARED)
else()
  set(LIBRARY_TYPE STATIC)
endif()

#
# Offer the user the choice of overriding the installation directories
set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR include CACHE PATH "Installation directory for header files")
set(INSTALL_CMAKE_DIR lib/cmake/LibWebRTC CACHE PATH "Installation directory for CMake files")

if (UNIX)
  set(INSTALL_PKGCONFIG_DIR lib/pkgconfig CACHE PATH "Installation directory for pkg-config script")
  if (NOT APPLE)
    option(BUILD_DEB_PACKAGE "Build Debian .deb package" OFF)
    option(BUILD_RPM_PACKAGE "Build Red Hat .rpm package" OFF)
  endif (NOT APPLE)
endif (UNIX)

#
# Make relative paths absolute (needed later on)
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()
