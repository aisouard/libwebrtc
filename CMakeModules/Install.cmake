#
# Install library
file(GLOB_RECURSE _LIBRARY_FILES
     ${CMAKE_BINARY_DIR}/lib/*${CMAKE_SHARED_LIBRARY_SUFFIX}
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
configure_file(${CMAKE_MODULE_PATH}/LibWebRTCConfig.cmake.in
               ${CMAKE_BINARY_DIR}/LibWebRTCConfig.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/LibWebRTCConfig.cmake
        DESTINATION ${INSTALL_CMAKE_DIR}
        COMPONENT cmake)

#
# Install CMake ConfigVersion file
configure_file(${CMAKE_MODULE_PATH}/LibWebRTCConfigVersion.cmake.in
               ${CMAKE_BINARY_DIR}/LibWebRTCConfigVersion.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/LibWebRTCConfigVersion.cmake
        DESTINATION ${INSTALL_CMAKE_DIR}
        COMPONENT cmake)

#
# Install pkg-config file
if (UNIX)
  configure_file(${CMAKE_MODULE_PATH}/LibWebRTC.pc.in
                 ${CMAKE_BINARY_DIR}/LibWebRTC.pc @ONLY)
  install(FILES ${CMAKE_BINARY_DIR}/LibWebRTC.pc
          DESTINATION ${INSTALL_PKGCONFIG_DIR}
          COMPONENT cmake)
endif (UNIX)

#
# Install CMake Use file
install(FILES ${CMAKE_MODULE_PATH}/UseLibWebRTC.cmake
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
    "${CMAKE_MODULE_PATH}/Uninstall.cmake.in"
    "${CMAKE_BINARY_DIR}/Uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
                  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/Uninstall.cmake)

#
# Create package
set(CPACK_PACKAGE_NAME "LibWebRTC")
set(CPACK_PACKAGE_VERSION_MAJOR "${LIBWEBRTC_MAJOR_VERSION}")
set(CPACK_PACKAGE_VERSION_MINOR "${LIBWEBRTC_MINOR_VERSION}")
set(CPACK_PACKAGE_VERSION_PATCH "${LIBWEBRTC_PATCH_VERSION}")

set(CPACK_INSTALL_CMAKE_PROJECTS
    "${CPACK_INSTALL_CMAKE_PROJECTS};${CMAKE_BINARY_DIR}/libwebrtc;libwebrtc;ALL;/")

if (WIN32)
  set(CPACK_GENERATOR "7Z")
else (WIN32)
  set(CPACK_GENERATOR "TGZ")
endif (WIN32)

set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY 0)
set(CPACK_PACKAGE_FILE_NAME "libwebrtc-${LIBWEBRTC_VERSION}-${TARGET_OS}-${TARGET_CPU}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "libwebrtc")

include(CPack)
