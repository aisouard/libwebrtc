include(LibWebRTCExecute)

libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} describe --tags --dirty=-dirty
    OUTPUT_VARIABLE _LIBWEBRTC_TAG
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    STAMPFILE webrtc-current-tag
    STATUS "Retrieving current git tag"
    ERROR "Unable to retrieve the current git tag"
)
string(STRIP ${_LIBWEBRTC_TAG} _LIBWEBRTC_TAG)

string(REGEX REPLACE "^v?([0-9]+)\\..*" "\\1" LIBWEBRTC_MAJOR_VERSION "${_LIBWEBRTC_TAG}")
string(REGEX REPLACE "^v?[0-9]+\\.([0-9]+).*" "\\1" LIBWEBRTC_MINOR_VERSION "${_LIBWEBRTC_TAG}")
string(REGEX REPLACE "^v?[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" LIBWEBRTC_PATCH_VERSION "${_LIBWEBRTC_TAG}")
string(REGEX REPLACE "^v?[0-9]+\\.[0-9]+\\.[0-9]+(.*)" "\\1" LIBWEBRTC_BUILD_VERSION "${_LIBWEBRTC_TAG}")

set(LIBWEBRTC_API_VERSION
    "${LIBWEBRTC_MAJOR_VERSION}.${LIBWEBRTC_MINOR_VERSION}.${LIBWEBRTC_PATCH_VERSION}")
set(LIBWEBRTC_VERSION
    ${LIBWEBRTC_API_VERSION}${LIBWEBRTC_BUILD_VERSION})

set(LIBWEBRTC_WEBRTC_HEAD refs/branch-heads/60)
