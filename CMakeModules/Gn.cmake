set(_GEN_ARGS "use_gold=false target_cpu=\\\"${TARGET_CPU}\\\" target_os=\\\"${TARGET_OS}\\\"")

if (MSVC OR XCODE)
  set(_GEN_ARGS ${_GEN_ARGS} is_debug=$<$<CONFIG:Debug>:true>$<$<CONFIG:Release>:false>$<$<CONFIG:RelWithDebInfo>:false>$<$<CONFIG:MinSizeRel>:false>)
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
  set(_GEN_ARGS "${_GEN_ARGS} is_debug=true")
else (MSVC OR XCODE)
  set(_GEN_ARGS "${_GEN_ARGS} is_debug=false")
endif (MSVC OR XCODE)

if (BUILD_TESTS)
  set(_GEN_ARGS "${_GEN_ARGS} rtc_include_tests=true")
else (BUILD_TESTS)
  set(_GEN_ARGS "${_GEN_ARGS} rtc_include_tests=false")
endif (BUILD_TESTS)

if (GN_EXTRA_ARGS)
  set(_GEN_ARGS "${_GEN_ARGS} ${GN_EXTRA_ARGS}")
endif (GN_EXTRA_ARGS)

set(_GN_OUT_DIR out/Default)
set(_GEN_COMMAND_LINE gn gen ${_GN_OUT_DIR} --args=\"${_GEN_ARGS}\")

if (WIN32)
  set(_SCRIPT_SUFFIX .bat)
elseif (UNIX)
  set(_SCRIPT_SUFFIX .sh)
  set(_GEN_COMMAND sh)
endif (WIN32)

string(REPLACE ";" " " _GEN_COMMAND_STR "${_GEN_COMMAND_LINE}")
set(_GN_SCRIPT_FILENAME ${WEBRTC_PARENT_DIR}/gn-gen${_SCRIPT_SUFFIX})
file(WRITE ${_GN_SCRIPT_FILENAME} ${_GEN_COMMAND_STR})

set(_GEN_COMMAND ${_GEN_COMMAND} ${_GN_SCRIPT_FILENAME})
