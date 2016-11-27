include(Common)
include(ExternalProject)

set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} "0")

ExternalProject_Add(chromium
                    URL ${LIBWEBRTC_CHROMIUM_DEPS}
                    URL_HASH MD5=0ad83a7a7ba20ef4af548578cbc893b7
                    SOURCE_DIR ${CMAKE_BINARY_DIR}/src/chromium/src

                    CONFIGURE_COMMAND ""
                    BUILD_COMMAND ""
                    INSTALL_COMMAND "")

set(GCLIENT_CONFIG_COMMAND
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} config --name src
    https://chromium.googlesource.com/external/webrtc.git)

set(GCLIENT_SYNC_COMMAND
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} sync
    --revision ${LIBWEBRTC_WEBRTC_REVISION} -n -D)

set(SETUP_LINKS_COMMAND ${PYTHON_EXECUTABLE} src/setup_links.py)

ExternalProject_Add(webrtc-src
                    DEPENDS chromium

                    PREFIX ${CMAKE_BINARY_DIR}
                    BINARY_DIR ${CMAKE_BINARY_DIR}
                    SOURCE_DIR ${CMAKE_BINARY_DIR}
                    DOWNLOAD_DIR ${CMAKE_BINARY_DIR}

                    DOWNLOAD_COMMAND ${GCLIENT_CONFIG_COMMAND}
                    UPDATE_COMMAND ${GCLIENT_SYNC_COMMAND}
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/src/chromium/src/third_party/llvm-build/Release+Asserts
                    BUILD_COMMAND ${SETUP_LINKS_COMMAND}
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

set(LIBWEBRTC_GEN_CMD gn gen out/Default --args=\"${LIBWEBRTC_GEN_ARGS}\")
add_libwebrtc_command(webrtc-generate
                      "Generate"
                      "${LIBWEBRTC_GEN_CMD}"
                      ${CMAKE_BINARY_DIR}/src
                      "Generating build files"
                      webrtc-src)

#
# Update clang
#
set(UPDATE_CLANG_COMMAND ${PYTHON_EXECUTABLE} chromium/src/tools/clang/scripts/update.py)
add_libwebrtc_command(webrtc-clang
                      "Clang"
                      "${UPDATE_CLANG_COMMAND}"
                      ${CMAKE_BINARY_DIR}/src
                      "Updating clang"
                      webrtc-generate)

#
# Run the build command
#
set(LIBWEBRTC_BUILD_CMD ninja -C out/Default)
add_libwebrtc_command(webrtc-ninja
                      "Build"
                      "${LIBWEBRTC_BUILD_CMD}"
                      ${CMAKE_BINARY_DIR}/src
                      "Building WebRTC"
                      webrtc-clang)

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