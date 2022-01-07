if (HAS_OWN_DEPOT_TOOLS)
  return()
endif (HAS_OWN_DEPOT_TOOLS)

include(LibWebRTCExecute)

if (WEBRTC_REVISION)
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} log -1 --format=%ci ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_COMMIT_DATE
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      STAMPFILE webrtc-revision-commit-date
      STATUS "Retrieving date for commit ${WEBRTC_REVISION}"
      ERROR "Unable to find webrtc commit date at ${WEBRTC_REVISION}"
  )
elseif (WEBRTC_BRANCH_HEAD)
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} log -1 --format=%ci
      OUTPUT_VARIABLE _WEBRTC_COMMIT_DATE
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      STAMPFILE webrtc-branch-head-commit-date
      STATUS "Retrieving date for ${WEBRTC_BRANCH_HEAD}"
      ERROR "Unable to retrieve the commit date for ${WEBRTC_BRANCH_HEAD}"
  )
else (WEBRTC_REVISION)
  message(FATAL_ERROR "-- Both WEBRTC_REVISION and WEBRTC_BRANCH_HEAD variables are undefined")
endif (WEBRTC_REVISION)

string(STRIP ${_WEBRTC_COMMIT_DATE} _WEBRTC_COMMIT_DATE)
libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} rev-list -n 1 --before=\"${_WEBRTC_COMMIT_DATE}\" main
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
