project(PeerConnection)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

if(UNIX AND NOT APPLE)
    find_package(X11 REQUIRED)
endif(UNIX AND NOT APPLE)

if(APPLE)
    find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox)
    find_library(COREAUDIO_LIBRARY CoreAudio)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    find_library(COREGRAPHICS_LIBRARY CoreGraphics)
    find_library(FOUNDATION_LIBRARY Foundation)
endif(APPLE)

set(PEERCONNECTION_SOURCE_FILES
        main.cpp
        Core.cpp
        CreateSessionObserver.cpp
        DataChannelObserver.cpp
        Peer.cpp
        PeerConnectionObserver.cpp
        SetLocalSessionDescriptionObserver.cpp
        SetRemoteSessionDescriptionObserver.cpp
)

set(PEERCONNECTION_HEADER_FILES
        Console.h
        Core.h
        CreateSessionObserver.h
        DataChannelObserver.h
        IPeer.h
        Peer.h
        PeerConnectionObserver.h
        SetLocalSessionDescriptionObserver.h
        SetRemoteSessionDescriptionObserver.h
)

include_directories(${CMAKE_BINARY_DIR}/src)

if(WIN32)
    add_definitions(-DWEBRTC_WIN -DNOMINMAX)
    set(PEERCONNECTION_SOURCE_FILES ${PEERCONNECTION_SOURCE_FILES}
            Win32Console.cpp)
else(WIN32)
    add_definitions(-DWEBRTC_POSIX -std=gnu++0x -D_GLIBCXX_USE_CXX11_ABI=0)
    set(PEERCONNECTION_SOURCE_FILES ${PEERCONNECTION_SOURCE_FILES}
            UnixConsole.cpp)
endif(WIN32)

add_executable(PeerConnection
        ${PEERCONNECTION_SOURCE_FILES}
        ${PEERCONNECTION_HEADER_FILES})

set(PEERCONNECTION_LIBRARIES webrtc Threads::Threads)

if(WIN32)
    set(PEERCONNECTION_LIBRARIES ${PEERCONNECTION_LIBRARIES} msdmo.lib wmcodecdspuuid.lib dmoguids.lib ole32.lib secur32.lib)
elseif(UNIX AND NOT APPLE)
    set(PEERCONNECTION_LIBRARIES ${PEERCONNECTION_LIBRARIES}
            ${X11_LIBRARIES}
            ${CMAKE_DL_LIBS})
elseif(APPLE)
    set(PEERCONNECTION_LIBRARIES ${PEERCONNECTION_LIBRARIES}
        ${AUDIOTOOLBOX_LIBRARY} ${COREAUDIO_LIBRARY} ${COREFOUNDATION_LIBRARY}
        ${COREGRAPHICS_LIBRARY} ${FOUNDATION_LIBRARY})
endif(WIN32)

add_library(webrtc STATIC IMPORTED)
set_property(TARGET webrtc PROPERTY IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/libwebrtc/${LIBWEBRTC_LIBRARY_NAME}")

target_link_libraries(PeerConnection ${PEERCONNECTION_LIBRARIES})
add_dependencies(PeerConnection libwebrtc)