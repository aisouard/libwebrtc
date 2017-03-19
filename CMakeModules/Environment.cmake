set(_WEBRTC_PATH ${DEPOT_TOOLS_PATH})
set(_DEPOT_TOOLS_ENV PATH=${_WEBRTC_PATH})

if (WIN32)
  get_filename_component(DEPOT_TOOLS_PYTHON_PATH
                         "${_WEBRTC_PATH}/python276_bin"
                         REALPATH)
  list(APPEND _WEBRTC_PATH ${DEPOT_TOOLS_PYTHON_PATH})
endif (WIN32)

list(APPEND _WEBRTC_PATH $ENV{PATH})

if (WIN32)
  string(REGEX REPLACE "/" "\\\\" _WEBRTC_PATH "${_WEBRTC_PATH}")
  string(REGEX REPLACE ";" "\\\;" _WEBRTC_PATH "${_WEBRTC_PATH}")
else (WIN32)
  string(REGEX REPLACE ";" ":" _WEBRTC_PATH "${_WEBRTC_PATH}")
endif (WIN32)

get_filename_component(_CHROMIUM_PYTHONPATH
                       "${CMAKE_SOURCE_DIR}/build"
                       REALPATH)

set(_WEBRTC_ENV
    PATH=\"${_WEBRTC_PATH}\"
    PYTHONPATH=\"${_CHROMIUM_PYTHONPATH}\"
    DEPOT_TOOLS_WIN_TOOLCHAIN=0
    DEPOT_TOOLS_UPDATE=0
    CHROME_HEADLESS=1)

set(PREFIX_EXECUTE cmake -E env ${_WEBRTC_ENV} ${PREFIX_FILENAME})
