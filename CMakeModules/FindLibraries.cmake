#
# Find required packages

find_package(Git REQUIRED)
find_package(DepotTools REQUIRED)

if (WIN32)
  set(PYTHON_EXECUTABLE ${DEPOTTOOLS_PATH}/python.bat)
else (WIN32)
  find_package(PythonInterp REQUIRED)
endif (WIN32)

list(APPEND LIBWEBRTC_LIBRARIES webrtc)

if (UNIX AND NOT APPLE)
  find_package(X11 REQUIRED)
  list(APPEND LIBWEBRTC_LIBRARIES ${X11_LIBRARIES} ${CMAKE_DL_LIBS})
endif (UNIX AND NOT APPLE)

if (APPLE)
  find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox)
  find_library(COREAUDIO_LIBRARY CoreAudio)
  find_library(COREFOUNDATION_LIBRARY CoreFoundation)
  find_library(COREGRAPHICS_LIBRARY CoreGraphics)
  find_library(FOUNDATION_LIBRARY Foundation)

  list(APPEND LIBWEBRTC_LIBRARIES ${AUDIOTOOLBOX_LIBRARY} ${COREAUDIO_LIBRARY}
       ${COREFOUNDATION_LIBRARY} ${COREGRAPHICS_LIBRARY} ${FOUNDATION_LIBRARY})
endif (APPLE)

if (WIN32)
  list(APPEND LIBWEBRTC_LIBRARIES msdmo.lib wmcodecdspuuid.lib dmoguids.lib
       ole32.lib secur32.lib winmm.lib ws2_32.lib)
endif (WIN32)
