project(PeerConnection)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

if(UNIX AND NOT APPLE)
  find_package(X11 REQUIRED)
endif(UNIX AND NOT APPLE)

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

set(PEERCONNECTION_LIBRARIES ${LIBWEBRTC_LIBRARY_PATH} Threads::Threads)

if(WIN32)
    set(PEERCONNECTION_LIBRARIES ${PEERCONNECTION_LIBRARIES} msdmo.lib wmcodecdspuuid.lib dmoguids.lib ole32.lib secur32.lib)
elseif(UNIX AND NOT APPLE)
    set(PEERCONNECTION_LIBRARIES ${PEERCONNECTION_LIBRARIES}
            ${X11_LIBRARIES}
            ${CMAKE_DL_LIBS})
endif(WIN32)

target_link_libraries(PeerConnection ${PEERCONNECTION_LIBRARIES})
