if (HAS_OWN_DEPOT_TOOLS)
  return()
endif (HAS_OWN_DEPOT_TOOLS)

include(LibWebRTCExecute)

libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} log -1 --format=%ci ${WEBRTC_REVISION}
    OUTPUT_VARIABLE _WEBRTC_COMMIT_DATE
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    STAMPFILE webrtc-revision-commit-date
    STATUS "Retrieving date for commit ${WEBRTC_REVISION}"
    ERROR "Unable to find webrtc commit date at ${WEBRTC_REVISION}"
)

string(STRIP ${_WEBRTC_COMMIT_DATE} _WEBRTC_COMMIT_DATE)
libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} rev-list -n 1 --before=\"${_WEBRTC_COMMIT_DATE}\" master
    OUTPUT_VARIABLE _DEPOT_TOOLS_COMMIT
    WORKING_DIRECTORY ${DEPOT_TOOLS_PATH}
    STAMPFILE webrtc-depot-tools-date
    STATUS "Retrieving depot_tools commit before ${_WEBRTC_COMMIT_DATE}"
    ERROR "Unable to find depot_tools commit before ${_WEBRTC_COMMIT_DATE}"
)

string(STRIP ${_DEPOT_TOOLS_COMMIT} _DEPOT_TOOLS_COMMIT)
libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} checkout ${_DEPOT_TOOLS_COMMIT}
    OUTPUT_VARIABLE _DEPOT_TOOLS_CHECKED_OUT
    WORKING_DIRECTORY ${DEPOT_TOOLS_PATH}
    STAMPFILE webrtc-depot-tools-checkout
    STATUS "Checking out depot_tools to commit ${_DEPOT_TOOLS_COMMIT}"
    ERROR "Unable to checkout depot_tools to commit ${_DEPOT_TOOLS_COMMIT}"
)
