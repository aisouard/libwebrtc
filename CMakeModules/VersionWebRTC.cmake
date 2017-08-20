include(LibWebRTCExecute)

libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} clone --depth 1 ${WEBRTC_GIT_URL} ${WEBRTC_SOURCE_DIR}
    OUTPUT_VARIABLE _WEBRTC_CLONE
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    STAMPFILE webrtc-clone
    STATUS "Cloning WebRTC"
    ERROR "Unable to clone WebRTC"
)

libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} config remote.origin.fetch +refs/branch-heads/*:refs/remotes/branch-heads/* ^\\+refs/branch-heads/\\*:.*$
    OUTPUT_VARIABLE _WEBRTC_CONFIG_FETCH
    WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
    STAMPFILE webrtc-config-fetch
    STATUS "Setting up WebRTC branch-heads refspecs"
    ERROR "Unable to setup up WebRTC branch-heads refspecs"
)

# get WebRTC version
if (WEBRTC_REVISION)
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} fetch origin
      OUTPUT_VARIABLE _WEBRTC_FETCH
      WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
      STAMPFILE webrtc-fetch
      STATUS "Fetching webrtc"
      ERROR "Unable to fetch webrtc"
  )
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} checkout ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_CHECKOUT
      WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
      STAMPFILE webrtc-checkout-commit
      STATUS "Checking out webrtc to commit ${WEBRTC_REVISION}"
      ERROR "Unable to checkout webrtc to commit ${WEBRTC_REVISION}"
  )
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} name-rev --refs remotes/branch-heads/* --name-only ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_NAME_REV
      WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
      STAMPFILE webrtc-name-rev
      STATUS "Finding out WebRTC branch for commit ${WEBRTC_REVISION}"
      ERROR "Unable to find out WebRTC branch for commit ${WEBRTC_REVISION}"
  )
  string(REGEX MATCH "^branch-heads/([0-9]+).*" _MATCHES "${_WEBRTC_NAME_REV}")
  if (_MATCHES)
    set(WEBRTC_BRANCH_HEAD ${CMAKE_MATCH_1})
  else (_MATCHES)
    message(FATAL_ERROR "-- Unable to find out WebRTC branch for commit ${WEBRTC_REVISION} in name ${_WEBRTC_NAME_REV}")
  endif (_MATCHES)
elseif (WEBRTC_BRANCH_HEAD)
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} ls-remote --exit-code ${WEBRTC_GIT_URL} refs/branch-heads/${WEBRTC_BRANCH_HEAD}
      OUTPUT_VARIABLE _WEBRTC_BRANCH_HEAD_INFO
      WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
      STAMPFILE webrtc-branch-head-info
      STATUS "Retrieving info for WebRTC branch ${WEBRTC_BRANCH_HEAD}"
      ERROR "Unable to retrieve info for WebRTC branch ${WEBRTC_BRANCH_HEAD}"
  )
  string(REGEX REPLACE "^[ \t]*([0-9a-f]+)[ \t]+.*" "\\1" WEBRTC_REVISION "${_WEBRTC_BRANCH_HEAD_INFO}")

  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} fetch origin ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_FETCH
      WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
      STAMPFILE webrtc-fetch-commit
      STATUS "Fetching webrtc commit ${WEBRTC_REVISION}"
      ERROR "Unable to fetch webrtc commit ${WEBRTC_REVISION}"
  )
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} checkout ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_CHECKOUT
      WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
      STAMPFILE webrtc-checkout-commit
      STATUS "Checking out webrtc to commit ${WEBRTC_REVISION}"
      ERROR "Unable to checkout webrtc to commit ${WEBRTC_REVISION}"
  )
else (WEBRTC_REVISION)
  message(FATAL_ERROR "-- Both WEBRTC_REVISION and WEBRTC_BRANCH_HEAD variables are undefined")
endif (WEBRTC_REVISION)

configure_file(${CMAKE_SOURCE_DIR}/webrtc/CMakeLists.txt.in ${WEBRTC_SOURCE_DIR}/CMakeLists.txt @ONLY)

message(STATUS "WebRTC version ${WEBRTC_BRANCH_HEAD}-${WEBRTC_REVISION}")
