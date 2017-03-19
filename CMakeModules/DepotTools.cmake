if (HAS_OWN_DEPOT_TOOLS)
  return()
endif (HAS_OWN_DEPOT_TOOLS)

include(LibWebRTCExecute)

if (WEBRTC_REVISION)
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} log -1 --format=%ci ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_COMMIT_DATE
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      STAMPFILE webrtc-commit-date
      STATUS "Retrieving date for commit ${WEBRTC_REVISION}"
      ERROR "Unable to find webrtc commit date at ${WEBRTC_REVISION}"
  )
elseif (WEBRTC_BRANCH_HEAD)
  message(STATUS "Retrieving branch-heads refspecs")
  execute_process(COMMAND ${GIT_EXECUTABLE} config remote.origin.fetch +refs/branch-heads/*:refs/remotes/branch-heads/* ^\\+refs/branch-heads/\\*:.*$
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                  RESULT_VARIABLE _ADD_REMOTE_RESULT)

  if (NOT _ADD_REMOTE_RESULT EQUAL 0)
    message(FATAL_ERROR "-- Unable to add branch-heads refspec")
  endif (NOT _ADD_REMOTE_RESULT EQUAL 0)

  message(STATUS "Fetching ${WEBRTC_BRANCH_HEAD}")
  execute_process(COMMAND ${GIT_EXECUTABLE} fetch origin ${WEBRTC_BRANCH_HEAD}
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                  RESULT_VARIABLE _WEBRTC_FETCH_RESULT)

  if (NOT _WEBRTC_FETCH_RESULT EQUAL 0)
    message(FATAL_ERROR "-- Unable to fetch ${WEBRTC_BRANCH_HEAD}")
  endif (NOT _WEBRTC_FETCH_RESULT EQUAL 0)

  message(STATUS "Checking out ${WEBRTC_BRANCH_HEAD}")
  execute_process(COMMAND ${GIT_EXECUTABLE} checkout FETCH_HEAD
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                  RESULT_VARIABLE _WEBRTC_CHECKOUT_RESULT)

  if (NOT _WEBRTC_CHECKOUT_RESULT EQUAL 0)
    message(FATAL_ERROR "-- Unable to checkout ${WEBRTC_BRANCH_HEAD}")
  endif (NOT _WEBRTC_CHECKOUT_RESULT EQUAL 0)

  message(STATUS "Retrieving date for commit ${WEBRTC_BRANCH_HEAD}")
  execute_process(COMMAND ${GIT_EXECUTABLE} log -1 --format=%ci
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                  OUTPUT_VARIABLE _WEBRTC_COMMIT_DATE
                  RESULT_VARIABLE _WEBRTC_COMMIT_DATE_RESULT)

  if (NOT _WEBRTC_COMMIT_DATE_RESULT EQUAL 0)
    message(FATAL_ERROR "-- Unable to retrieve the commit date")
  endif (NOT _WEBRTC_COMMIT_DATE_RESULT EQUAL 0)
else (WEBRTC_REVISION)
  message(FATAL_ERROR "-- Both WEBRTC_REVISION and WEBRTC_BRANCH_HEAD variables are undefined")
endif (WEBRTC_REVISION)

string(STRIP ${_WEBRTC_COMMIT_DATE} _WEBRTC_COMMIT_DATE)
message(STATUS "Retrieving depot_tools commit before ${_WEBRTC_COMMIT_DATE}")

execute_process(COMMAND ${GIT_EXECUTABLE} rev-list -n 1 --before=\"${_WEBRTC_COMMIT_DATE}\" master
                WORKING_DIRECTORY ${DEPOT_TOOLS_PATH}
                OUTPUT_VARIABLE _DEPOT_TOOLS_COMMIT)

if (NOT _DEPOT_TOOLS_COMMIT)
  message(FATAL_ERROR "-- Unable to find depot_tools commit before ${_WEBRTC_COMMIT_DATE}")
endif (NOT _DEPOT_TOOLS_COMMIT)

string(STRIP ${_DEPOT_TOOLS_COMMIT} _DEPOT_TOOLS_COMMIT)
message(STATUS "Checking out depot_tools to commit ${_DEPOT_TOOLS_COMMIT}")

execute_process(COMMAND ${GIT_EXECUTABLE} checkout ${_DEPOT_TOOLS_COMMIT}
                WORKING_DIRECTORY ${DEPOT_TOOLS_PATH}
                RESULT_VARIABLE _DEPOT_TOOLS_CHECKED_OUT)

if (NOT _DEPOT_TOOLS_CHECKED_OUT EQUAL 0)
  message(FATAL_ERROR "-- Unable to checkout depot_tools to commit ${_DEPOT_TOOLS_COMMIT}")
endif (NOT _DEPOT_TOOLS_CHECKED_OUT EQUAL 0)
