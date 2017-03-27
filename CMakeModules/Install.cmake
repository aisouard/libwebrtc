#
# Install library
file(GLOB_RECURSE _LIBRARY_FILES
     ${CMAKE_BINARY_DIR}/lib/*${CMAKE_STATIC_LIBRARY_SUFFIX})

install(FILES ${_LIBRARY_FILES}
        DESTINATION ${INSTALL_LIB_DIR}
        COMPONENT lib)

#
# Install headers
install(DIRECTORY "${CMAKE_BINARY_DIR}/include/"
        DESTINATION ${INSTALL_INCLUDE_DIR}
        COMPONENT include
        FILES_MATCHING PATTERN "*.h")

#
# Install CMake Config file
configure_file(${CMAKE_MODULE_PATH}/Templates/LibWebRTCConfig.cmake.in
               ${CMAKE_BINARY_DIR}/LibWebRTCConfig.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/LibWebRTCConfig.cmake
        DESTINATION ${INSTALL_CMAKE_DIR}
        COMPONENT cmake)

#
# Install CMake ConfigVersion file
configure_file(${CMAKE_MODULE_PATH}/Templates/LibWebRTCConfigVersion.cmake.in
               ${CMAKE_BINARY_DIR}/LibWebRTCConfigVersion.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/LibWebRTCConfigVersion.cmake
        DESTINATION ${INSTALL_CMAKE_DIR}
        COMPONENT cmake)

#
# Install pkg-config file
if (UNIX)
  set(prefix "${CMAKE_INSTALL_PREFIX}")
  set(exec_prefix "\${prefix}")
  set(libdir "${INSTALL_LIB_DIR}")
  set(includedir "${INSTALL_INCLUDE_DIR}")

  set(LIBWEBRTC_PC_LIBS "-L${INSTALL_LIB_DIR}" "-lwebrtc")
  foreach(LIB_NAME ${LIBWEBRTC_LIBRARIES})
    if (LIB_NAME MATCHES "[\\/]")
      get_filename_component(LIB_DIR "${LIB_NAME}" PATH)
      get_filename_component(LIB_NAME "${LIB_NAME}" NAME_WE)
      string(REGEX REPLACE "^lib(.*)" "-l\\1" LIB_NAME "${LIB_NAME}")

      if (NOT ${LIB_DIR} IN_LIST LIB_DIRS)
        list(APPEND LIB_DIRS ${LIB_DIR})
        list(APPEND LIBWEBRTC_PC_LIBS_PRIVATE "-L${LIB_DIR}")
      endif (NOT ${LIB_DIR} IN_LIST LIB_DIRS)

    elseif (NOT LIB_NAME MATCHES "^-l")
      set(LIB_NAME "-l${LIB_NAME}")
    endif ()
    list(APPEND LIBWEBRTC_PC_LIBS_PRIVATE "${LIB_NAME}")
  endforeach(LIB_NAME ${LIBWEBRTC_LIBRARIES})

  foreach(DEFINITION ${LIBWEBRTC_DEFINITIONS})
    list(APPEND LIBWEBRTC_PC_DEFINITIONS "-D${DEFINITION}")
  endforeach(DEFINITION ${LIBWEBRTC_DEFINITIONS})

  list(REMOVE_ITEM LIBWEBRTC_PC_LIBS_PRIVATE "-lwebrtc")
  string(REPLACE ";" " " LIBWEBRTC_PC_DEFINITIONS "${LIBWEBRTC_PC_DEFINITIONS}")
  string(REPLACE ";" " " LIBWEBRTC_PC_LIBS "${LIBWEBRTC_PC_LIBS}")
  string(REPLACE ";" " " LIBWEBRTC_PC_LIBS_PRIVATE "${LIBWEBRTC_PC_LIBS_PRIVATE}")
  string(REPLACE ";" " " LIBWEBRTC_PC_CXXFLAGS "${LIBWEBRTC_REQUIRED_CXX_FLAGS}")

  configure_file(${CMAKE_MODULE_PATH}/Templates/LibWebRTC.pc.in
                 ${CMAKE_BINARY_DIR}/LibWebRTC.pc @ONLY)
  install(FILES ${CMAKE_BINARY_DIR}/LibWebRTC.pc
          DESTINATION ${INSTALL_PKGCONFIG_DIR}
          COMPONENT cmake)
endif (UNIX)

#
# Install CMake Use file
install(FILES ${CMAKE_MODULE_PATH}/Templates/UseLibWebRTC.cmake
        DESTINATION ${INSTALL_CMAKE_DIR}
        COMPONENT cmake)

#
# Install CMake Targets file
install(DIRECTORY "${CMAKE_BINARY_DIR}/lib/cmake/LibWebRTC/"
        DESTINATION ${INSTALL_CMAKE_DIR}
        COMPONENT cmake
        FILES_MATCHING PATTERN "*.cmake")

#
# Add uninstall target
configure_file(
    "${CMAKE_MODULE_PATH}/Templates/Uninstall.cmake.in"
    "${CMAKE_BINARY_DIR}/Uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
                  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/Uninstall.cmake)
