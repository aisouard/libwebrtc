file(WRITE ${WEBRTC_PARENT_DIR}/.gclient "solutions = [
  {
    \"url\": \"https://chromium.googlesource.com/external/webrtc.git\",
    \"managed\": False,
    \"name\": \"src\",
    \"deps_file\": \"DEPS\",
    \"custom_deps\": {},
  },
]
")

if (TARGET_OS STREQUAL "android")
  file(APPEND ${WEBRTC_PARENT_DIR}/.gclient "target_os = [\"android\", \"unix\"]")
elseif (TARGET_OS STREQUAL "ios")
  file(APPEND ${WEBRTC_PARENT_DIR}/.gclient "target_os = [\"ios\", \"mac\"]")
elseif (TARGET_OS STREQUAL "linux")
  file(APPEND ${WEBRTC_PARENT_DIR}/.gclient "target_os = [\"unix\"]")
elseif (TARGET_OS STREQUAL "mac")
  file(APPEND ${WEBRTC_PARENT_DIR}/.gclient "target_os = [\"mac\"]")
elseif (TARGET_OS STREQUAL "win")
  file(APPEND ${WEBRTC_PARENT_DIR}/.gclient "target_os = [\"win\"]")
endif (TARGET_OS STREQUAL "android")
