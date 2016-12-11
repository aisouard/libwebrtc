include(ExternalProject)

#
# Generate environment variables
#
set(PATH_SEP ":")
if (WIN32)
  set(PATH_SEP ";")
endif (WIN32)

set(WEBRTC_PATH "${CMAKE_SOURCE_DIR}/Dependencies/depot_tools${PATH_SEP}")
if (WIN32)
  set(WEBRTC_PATH "${WEBRTC_PATH}${CMAKE_SOURCE_DIR}/Dependencies/depot_tools/python276_bin${PATH_SEP}")
endif (WIN32)

set(WEBRTC_PATH "${WEBRTC_PATH}$ENV{PATH}")

set(WEBRTC_ENV "PATH=${WEBRTC_PATH} PYTHONPATH=${CMAKE_BINARY_DIR}/src/build")
if (WIN32)
  set(WEBRTC_ENV "${WEBRTC_ENV} DEPOT_TOOLS_WIN_TOOLCHAIN=0")
endif (WIN32)

set(WEBRTC_CMD_PREFIX ${CMAKE_COMMAND} -E env \"${WEBRTC_ENV}\")

#
# Download chromium dependencies
#
ExternalProject_Add(chromium
                    URL ${LIBWEBRTC_CHROMIUM_DEPS}
                    URL_HASH MD5=${LIBWEBRTC_CHROMIUM_DEPS_HASH}
                    SOURCE_DIR ${CMAKE_BINARY_DIR}/src/chromium/src

                    CONFIGURE_COMMAND ""
                    BUILD_COMMAND ""
                    INSTALL_COMMAND "")

#
# Retrieve WebRTC source code
#
set(GCLIENT_CONFIG_COMMAND ${WEBRTC_CMD_PREFIX}
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} config --name src
    https://chromium.googlesource.com/external/webrtc.git)

set(GCLIENT_SYNC_COMMAND ${WEBRTC_CMD_PREFIX}
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} sync
    --revision ${LIBWEBRTC_WEBRTC_REVISION} -n -D)

if (UNIX AND NOT APPLE)
  set(RETRIEVE_SYSROOT_COMMAND ${CMAKE_BINARY_DIR}/src/build/linux/sysroot_scripts/install-sysroot.py --arch=amd64)
endif (UNIX AND NOT APPLE)

set(UPDATE_CLANG_COMMAND ${PYTHON_EXECUTABLE} src/chromium/src/tools/clang/scripts/update.py)

set(SETUP_LINKS_COMMAND ${PYTHON_EXECUTABLE} src/setup_links.py)

ExternalProject_Add(webrtc-src
                    DEPENDS chromium

                    PREFIX ${CMAKE_BINARY_DIR}
                    BINARY_DIR ${CMAKE_BINARY_DIR}
                    SOURCE_DIR ${CMAKE_BINARY_DIR}
                    DOWNLOAD_DIR ${CMAKE_BINARY_DIR}

                    DOWNLOAD_COMMAND ${GCLIENT_CONFIG_COMMAND}
                    PATCH_COMMAND ${GCLIENT_SYNC_COMMAND}
                    UPDATE_COMMAND ${UPDATE_CLANG_COMMAND}
                    CONFIGURE_COMMAND ${SETUP_LINKS_COMMAND}
                    BUILD_COMMAND "${RETRIEVE_SYSROOT_COMMAND}"
                    INSTALL_COMMAND ""

                    LOG_DOWNLOAD 1
                    LOG_CONFIGURE 1
                    LOG_UPDATE 0
                    LOG_BUILD 0
                    LOG_TEST 0
                    LOG_INSTALL 0)

#
# Generate build files
#
set(LIBWEBRTC_GEN_ARGS use_gold=false)

if (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} is_debug=false)
elseif (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} is_debug=true)
endif (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)

if (WIN32)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS})
elseif (APPLE)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS})
elseif (UNIX AND NOT APPLE)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS})
endif (WIN32)

if (NOT BUILD_TESTS)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} rtc_include_tests=false)
endif (NOT BUILD_TESTS)

add_custom_command(
    OUTPUT "Generate"
    COMMAND ${WEBRTC_CMD_PREFIX} gn gen out/Default --args=\"${LIBWEBRTC_GEN_ARGS}\"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src
    COMMENT "Generating build files")

add_custom_target(
    webrtc-generate ALL
    DEPENDS "Generate")

add_dependencies(webrtc-generate webrtc-src)

#
# Run the build command
#
add_custom_command(
    OUTPUT "Build"
    COMMAND ${WEBRTC_CMD_PREFIX} ninja ${NINJA_ARGS} -C out/Default
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src
    COMMENT "Building WebRTC")

add_custom_target(
    webrtc-ninja ALL
    DEPENDS "Build")

add_dependencies(webrtc-ninja webrtc-generate)

#
# Link the library
#
ExternalProject_Add(libwebrtc
                    DEPENDS webrtc-ninja

                    INSTALL_DIR ${CMAKE_BINARY_DIR}
                    SOURCE_DIR ${CMAKE_SOURCE_DIR}/Targets/libwebrtc
                    BINARY_DIR ${CMAKE_BINARY_DIR}/libwebrtc

                    CMAKE_ARGS
                    -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
                    -DLIBWEBRTC_INCLUDE_DIR:STRING=${CMAKE_BINARY_DIR}/src/webrtc
                    -DLIBWEBRTC_OUTPUT_DIR:PATH=${CMAKE_BINARY_DIR}/src/out/Default)
