include(ExternalProject)
include(LibWebRTCCommand)
include(LibWebRTCConfig)
include(LibWebRTCPrefix)

ExternalProject_Add(
    webrtc-src
    PREFIX ${CMAKE_BINARY_DIR}
    BINARY_DIR ${CMAKE_BINARY_DIR}
    SOURCE_DIR ${CMAKE_BINARY_DIR}
    DOWNLOAD_DIR ${CMAKE_BINARY_DIR}

    DOWNLOAD_COMMAND ${PREFIX_EXECUTE} ${DEPOTTOOLS_GCLIENT_EXECUTABLE} sync --revision ${LIBWEBRTC_WEBRTC_REVISION} -D -n
    BUILD_COMMAND ${PREFIX_EXECUTE} ${PYTHON_EXECUTABLE} src/tools/clang/scripts/update.py
    INSTALL_COMMAND ""

    LOG_DOWNLOAD 1
)

set(_NEXT_DEPENDS webrtc-src)
if (UNIX AND NOT APPLE)
  libwebrtc_command(
      NAME webrtc-install-sysroot
      COMMAND ${CMAKE_BINARY_DIR}/src/build/linux/sysroot_scripts/install-sysroot.py --running-as-hook
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      COMMENT "Installing Linux sysroots"
      DEPENDS webrtc-src
  )
  set(_NEXT_DEPENDS webrtc-install-sysroot)

  set(_PLATFORM linux*)
  set(_FOLDER linux64)
elseif (APPLE)
  set(_PLATFORM darwin)
  set(_FOLDER mac)
elseif (WIN32)
  libwebrtc_command(
      NAME webrtc-vs-toolchain
      COMMAND ${PYTHON_EXECUTABLE} src/build/vs_toolchain.py update
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      COMMENT "Updating Visual Studio toolchain"
      DEPENDS webrtc-src
  )
  set(_NEXT_DEPENDS webrtc-vs-toolchain)

  set(_PLATFORM win32)
  set(_FOLDER win)
  set(_SUFFIX .exe)
endif (UNIX AND NOT APPLE)

libwebrtc_command(
    NAME webrtc-fetch-gn
    COMMAND download_from_google_storage --no_resume --platform=${_PLATFORM} --no_auth --bucket chromium-gn -s src/buildtools/${_FOLDER}/gn${_SUFFIX}.sha1
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    COMMENT "Fetching gn binary"
    DEPENDS ${_NEXT_DEPENDS}
)

libwebrtc_command(
    NAME webrtc-fetch-clang-format
    COMMAND download_from_google_storage --no_resume --platform=${_PLATFORM} --no_auth --bucket chromium-clang-format -s src/buildtools/${_FOLDER}/clang-format${_SUFFIX}.sha1
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    COMMENT "Fetching clang-format binary"
    DEPENDS webrtc-fetch-gn
)

#
# Android dependencies
#
set(_NEXT_DEPENDS webrtc-fetch-clang-format)
if (TARGET_OS STREQUAL "android")
  libwebrtc_command(
      NAME webrtc-android-fetch-play-services
      COMMAND ${PYTHON_EXECUTABLE} src/build/android/play_services/update.py download
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      COMMENT "Fetching Google Play Services"
      DEPENDS webrtc-fetch-clang-format
  )

  libwebrtc_command(
      NAME webrtc-android-update-lastchange
      COMMAND ${PYTHON_EXECUTABLE} src/build/util/lastchange.py -o src/build/util/LASTCHANGE
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      COMMENT "Updating src/build/util/LASTCHANGE"
      DEPENDS webrtc-android-fetch-play-services
  )

  set(_NEXT_DEPENDS webrtc-android-update-lastchange)
  foreach(_DEPENDENCY_NAME android-support-test-runner espresso guava hamcrest javax-inject)
    string(REPLACE "-" "_" _DEPENDENCY_FOLDER ${_DEPENDENCY_NAME})

    libwebrtc_command(
        NAME webrtc-android-fetch-${_DEPENDENCY_NAME}
        COMMAND ${PYTHON_EXECUTABLE} src/build/android/update_deps/update_third_party_deps.py download -b chromium-${_DEPENDENCY_NAME} -l third_party/${_DEPENDENCY_FOLDER}
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
        COMMENT "Fetching Android dependency: ${_DEPENDENCY_NAME}"
        DEPENDS ${_NEXT_DEPENDS}
    )

    set(_NEXT_DEPENDS webrtc-android-fetch-${_DEPENDENCY_NAME})
  endforeach(_DEPENDENCY_NAME)
endif (TARGET_OS STREQUAL "android")

#
# Generate build files
#
set(_GEN_ARGS use_gold=false target_cpu=\\"${TARGET_CPU}\\" target_os=\\"${TARGET_OS}\\")

if (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(_GEN_ARGS ${_GEN_ARGS} is_debug=false)
elseif (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(_GEN_ARGS ${_GEN_ARGS} is_debug=true)
endif (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)

if (NOT BUILD_TESTS)
  set(_GEN_ARGS ${_GEN_ARGS} rtc_include_tests=false)
endif (NOT BUILD_TESTS)

if (WIN32)
  set(_GEN_ARGS ${_GEN_ARGS})
  set(_GEN_COMMAND gn gen out/Default --args="${_GEN_ARGS}")
elseif (UNIX)
  set(_GEN_ARGS ${_GEN_ARGS})
  set(_GEN_COMMAND gn gen out/Default --args='"${_GEN_ARGS}"')
endif (WIN32)

libwebrtc_command(
    NAME webrtc-generate
    COMMAND ${_GEN_COMMAND}
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/src"
    COMMENT "Generating build files"
    DEPENDS ${_NEXT_DEPENDS}
)

#
# Run ninja
#
libwebrtc_command(
    NAME webrtc-build
    COMMAND ninja ${NINJA_ARGS} -C out/Default
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/src"
    COMMENT "Building WebRTC"
    DEPENDS webrtc-generate
)

#
# Link the library
#
ExternalProject_Add(
    libwebrtc
    DEPENDS webrtc-build

    INSTALL_DIR ${CMAKE_BINARY_DIR}
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/Targets/libwebrtc
    BINARY_DIR ${CMAKE_BINARY_DIR}/libwebrtc

    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
    -DLIBWEBRTC_INCLUDE_DIR:STRING=${CMAKE_BINARY_DIR}/src/webrtc
    -DLIBWEBRTC_OUTPUT_DIR:PATH=${CMAKE_BINARY_DIR}/src/out/Default
    -DTARGET_OS:STRING=${TARGET_OS}
)