include(ExternalProject)

#
# Generate environment variables
#
set(WEBRTC_PATH ${CMAKE_SOURCE_DIR}/Dependencies/depot_tools)

if (WIN32)
  get_filename_component(DEPOT_TOOLS_PYTHON_PATH
                         "${DEPOT_TOOLS_PATH}/python276_bin"
                         REALPATH)
  list(APPEND WEBRTC_PATH ${DEPOT_TOOLS_PYTHON_PATH})
endif (WIN32)

list(APPEND WEBRTC_PATH $ENV{PATH})

if (WIN32)
  string(REGEX REPLACE "\\\\" "/" WEBRTC_PATH_STR "${WEBRTC_PATH}")
else (WIN32)
  string(REGEX REPLACE ";" ":" WEBRTC_PATH_STR "${WEBRTC_PATH}")
endif (WIN32)

get_filename_component(CHROMIUM_PYTHONPATH
                       "${CMAKE_BINARY_DIR}/src/build"
                       REALPATH)

set(WEBRTC_ENV PATH=${WEBRTC_PATH_STR} PYTHONPATH=${CHROMIUM_PYTHONPATH} DEPOT_TOOLS_WIN_TOOLCHAIN=0)
set(WEBRTC_PREFIX ${CMAKE_COMMAND} -E env \\\"${WEBRTC_ENV}\\\")

#
# Retrieve WebRTC source code
#
set(GCLIENT_CONFIG_COMMAND ${DEPOTTOOLS_GCLIENT_EXECUTABLE} config --name src https://chromium.googlesource.com/external/webrtc.git)

set(GCLIENT_SYNC_COMMAND
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} sync
    --revision ${LIBWEBRTC_WEBRTC_REVISION} -n -D)

set(RETRIEVE_SYSROOT_COMMAND echo)
if (UNIX AND NOT APPLE)
  set(RETRIEVE_SYSROOT_COMMAND ${CMAKE_BINARY_DIR}/src/build/linux/sysroot_scripts/install-sysroot.py --arch=amd64)
endif (UNIX AND NOT APPLE)

set(UPDATE_CLANG_COMMAND ${PYTHON_EXECUTABLE} src/tools/clang/scripts/update.py)

ExternalProject_Add(webrtc-src
                    PREFIX ${CMAKE_BINARY_DIR}
                    BINARY_DIR ${CMAKE_BINARY_DIR}
                    SOURCE_DIR ${CMAKE_BINARY_DIR}
                    DOWNLOAD_DIR ${CMAKE_BINARY_DIR}

                    DOWNLOAD_COMMAND ${WEBRTC_PREFIX} ${GCLIENT_CONFIG_COMMAND}
                    PATCH_COMMAND ${WEBRTC_PREFIX} ${GCLIENT_SYNC_COMMAND}
                    UPDATE_COMMAND ${WEBRTC_PREFIX} ${UPDATE_CLANG_COMMAND}
                    BUILD_COMMAND ${RETRIEVE_SYSROOT_COMMAND}

                    INSTALL_COMMAND ""

                    LOG_DOWNLOAD 1)

#
# Retrieve buildtools binaries
#
set(WEBRTC_PREFIX ${CMAKE_COMMAND} -E env \"${WEBRTC_ENV}\")
add_custom_command(
    OUTPUT "Buildtools"

    COMMAND ${WEBRTC_PREFIX} download_from_google_storage --no_resume --platform=linux* --no_auth --bucket chromium-gn -s src/buildtools/linux64/gn.sha1
    COMMAND ${WEBRTC_PREFIX} download_from_google_storage --no_resume --platform=linux* --no_auth --bucket chromium-clang-format -s src/buildtools/linux64/clang-format.sha1
    COMMAND ${WEBRTC_PREFIX} download_from_google_storage --no_resume --platform=darwin --no_auth --bucket chromium-gn -s src/buildtools/mac/gn.sha1
    COMMAND ${WEBRTC_PREFIX} download_from_google_storage --no_resume --platform=darwin --no_auth --bucket chromium-clang-format -s src/buildtools/mac/clang-format.sha1
    COMMAND ${WEBRTC_PREFIX} download_from_google_storage --no_resume --platform=win32 --no_auth --bucket chromium-gn -s src/buildtools/win/gn.exe.sha1
    COMMAND ${WEBRTC_PREFIX} download_from_google_storage --no_resume --platform=win32 --no_auth --bucket chromium-clang-format -s src/buildtools/win/clang-format.exe.sha1

    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Populating buildtools folder")

add_custom_target(
    webrtc-buildtools ALL
    DEPENDS "Buildtools")

add_dependencies(webrtc-buildtools webrtc-src)

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

set(WEBRTC_PREFIX ${CMAKE_COMMAND} -E env \"${WEBRTC_ENV}\")
set(LIBWEBRTC_GEN_COMMAND gn gen out/Default --args=\"${LIBWEBRTC_GEN_ARGS}\")

add_custom_command(
    OUTPUT "Generate"

    COMMAND ${WEBRTC_PREFIX} ${LIBWEBRTC_GEN_COMMAND}

    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src
    COMMENT "Generating build files")

add_custom_target(
    webrtc-generate ALL
    DEPENDS "Generate")

add_dependencies(webrtc-generate webrtc-buildtools)

#
# Run the build command
#
set(LIBWEBRTC_BUILD_COMMAND ninja ${NINJA_ARGS} -C out/Default)

add_custom_command(
    OUTPUT "Build"

    COMMAND ${WEBRTC_PREFIX} ${LIBWEBRTC_BUILD_COMMAND}

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
