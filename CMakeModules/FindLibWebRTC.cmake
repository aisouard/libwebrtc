find_path(LIBWEBRTC_INCLUDE_DIR typedefs.h
          HINTS
          ENV LIBWEBRTCDIR
          PATH_SUFFIXES webrtc
          include/webrtc include)

find_library(LIBWEBRTC_LIBRARY
             NAMES webrtc
             HINTS
             ENV LIBWEBRTCDIR
             PATH_SUFFIXES lib)

mark_as_advanced(LIBWEBRTC_LIBRARY LIBWEBRTC_INCLUDE_DIR)