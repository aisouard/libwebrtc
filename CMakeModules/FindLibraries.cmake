#
# Find required packages
list(APPEND LIBWEBRTC_LIBRARIES webrtc)

if (UNIX AND NOT APPLE)
  find_package(X11 REQUIRED)
  list(APPEND LIBWEBRTC_LIBRARIES ${X11_LIBRARIES} ${CMAKE_DL_LIBS} rt)

  set(THREADS_PREFER_PTHREAD_FLAG ON)
  find_package(Threads REQUIRED)
  if (CMAKE_HAVE_THREADS_LIBRARY)
    list(APPEND LIBWEBRTC_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
  endif (CMAKE_HAVE_THREADS_LIBRARY)
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
       crypt32.lib iphlpapi.lib ole32.lib secur32.lib winmm.lib ws2_32.lib)
endif (WIN32)
