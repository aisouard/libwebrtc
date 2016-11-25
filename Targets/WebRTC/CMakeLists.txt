include(Common)
include(ExternalProject)

ExternalProject_Add(chromium
                    SOURCE_DIR ${CMAKE_BINARY_DIR}/src/chromium/src

                    GIT_REPOSITORY ${LIBWEBRTC_CHROMIUM_DEPS}
                    CONFIGURE_COMMAND ""
                    BUILD_COMMAND ""
                    INSTALL_COMMAND "")

ExternalProject_Add(webrtc
                    DEPENDS chromium

                    PREFIX ${CMAKE_BINARY_DIR}
                    BINARY_DIR ${CMAKE_BINARY_DIR}
                    SOURCE_DIR ${CMAKE_BINARY_DIR}
                    DOWNLOAD_DIR ${CMAKE_BINARY_DIR}

                    DOWNLOAD_COMMAND ""
                    CONFIGURE_COMMAND ""
                    BUILD_COMMAND ""
                    INSTALL_COMMAND "")

#
# Configure gclient
#
set(GCLIENT_CONFIG_COMMAND
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} config --name src
    https://chromium.googlesource.com/external/webrtc.git)
ExternalProject_Add_Step(webrtc config
                         COMMAND ${GCLIENT_CONFIG_COMMAND}
                         COMMENT "Configure gclient"
                         WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

#
# Synchronize
#
set(GCLIENT_SYNC_COMMAND
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} sync
    --revision ${LIBWEBRTC_WEBRTC_REVISION} -n -D)
ExternalProject_Add_Step(webrtc sync
                         DEPENDEES config
                         COMMAND ${GCLIENT_SYNC_COMMAND}
                         COMMENT "Synchronize WebRTC"
                         WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

#
# Update clang
#
set(UPDATE_CLANG_COMMAND python chromium/src/tools/clang/scripts/update.py)
ExternalProject_Add_Step(webrtc clang
                         DEPENDEES sync
                         COMMAND ${UPDATE_CLANG_COMMAND}
                         COMMENT "Update clang"
                         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src)

#
# Generate symbolic links
#
set(SETUP_LINKS_COMMAND python setup_links.py)
ExternalProject_Add_Step(webrtc links
                         DEPENDEES clang
                         COMMAND ${SETUP_LINKS_COMMAND}
                         COMMENT "Generate symbolic links"
                         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src)

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
                      webrtc)

#
# Run the build command
#
set(LIBWEBRTC_BUILD_CMD ninja -C out/Default)
add_libwebrtc_command(webrtc-build
                      "Build"
                      "${LIBWEBRTC_BUILD_CMD}"
                      ${CMAKE_BINARY_DIR}/src
                      "Building WebRTC"
                      webrtc-generate)

#
# Link the library
#
ExternalProject_Add(libwebrtc
                    DEPENDS webrtc-build
                    INSTALL_COMMAND ""
                    SOURCE_DIR ${CMAKE_SOURCE_DIR}/Targets/libwebrtc
                    BINARY_DIR ${CMAKE_BINARY_DIR}/libwebrtc

                    CMAKE_ARGS
                    -DLIBWEBRTC_OUTPUT_DIR:STRING=${CMAKE_BINARY_DIR}/src/out/Default
                    -DLIBWEBRTC_INSTALL_LIB_DIR:PATH=${LIBWEBRTC_INSTALL_LIB_DIR})
