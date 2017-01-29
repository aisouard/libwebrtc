# - Try to find LibWebRTC
# Once done this will define
#  LIBWEBRTC_FOUND - System has LibWebRTC
#  LIBWEBRTC_INCLUDE_DIRS - The LibWebRTC include directories
#  LIBWEBRTC_LIBRARIES - The libraries needed to use LibWebRTC
#  LIBWEBRTC_DEFINITIONS - Compiler switches required for using LibWebRTC

if (LibWebRTC_FIND_QUIETLY)
  set(_FIND_FLAGS QUIET)
endif (LibWebRTC_FIND_QUIETLY)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED ${_FIND_FLAGS})

if (APPLE)
  find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox)
  find_library(COREAUDIO_LIBRARY CoreAudio)
  find_library(COREFOUNDATION_LIBRARY CoreFoundation)
  find_library(COREGRAPHICS_LIBRARY CoreGraphics)
  find_library(FOUNDATION_LIBRARY Foundation)
elseif (UNIX)
  find_package(X11 REQUIRED ${_FIND_FLAGS})
endif (APPLE)

if (WIN32)
  set(LIBWEBRTC_DEFINITIONS -DWEBRTC_WIN -DNOMINMAX)
elseif (UNIX)
  set(LIBWEBRTC_DEFINITIONS -DWEBRTC_POSIX -std=gnu++0x -D_GLIBCXX_USE_CXX11_ABI=0)
endif (WIN32)

find_path(LIBWEBRTC_INCLUDE_DIR libwebrtc.h
          HINTS ${PC_LIBXML_INCLUDEDIR} ${PC_LIBXML_INCLUDE_DIRS}
          PATH_SUFFIXES libwebrtc)

find_library(LIBWEBRTC_LIBRARY NAMES webrtc
             HINTS ${PC_LIBXML_LIBDIR} ${PC_LIBXML_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibWebRTC DEFAULT_MSG
                                  LIBWEBRTC_LIBRARY LIBWEBRTC_INCLUDE_DIR)

if (LIBWEBRTC_FOUND)
  set(LIBWEBRTC_LIBRARIES ${LIBWEBRTC_LIBRARY} Threads::Threads)

  if (WIN32)
    set(LIBWEBRTC_LIBRARIES ${LIBWEBRTC_LIBRARIES} msdmo.lib wmcodecdspuuid.lib
        dmoguids.lib ole32.lib secur32.lib)
  elseif (APPLE)
    set(LIBWEBRTC_LIBRARIES ${LIBWEBRTC_LIBRARIES}
        ${AUDIOTOOLBOX_LIBRARY} ${COREAUDIO_LIBRARY} ${COREFOUNDATION_LIBRARY}
        ${COREGRAPHICS_LIBRARY} ${FOUNDATION_LIBRARY})
  elseif (UNIX)
    set(LIBWEBRTC_LIBRARIES ${LIBWEBRTC_LIBRARIES} ${X11_LIBRARIES}
        ${CMAKE_DL_LIBS})
  endif (WIN32)

  set(LIBWEBRTC_INCLUDE_DIRS ${LIBWEBRTC_INCLUDE_DIR})
endif()

mark_as_advanced(LIBWEBRTC_INCLUDE_DIR LIBWEBRTC_LIBRARY)