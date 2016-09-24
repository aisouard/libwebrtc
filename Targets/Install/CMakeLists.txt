#
# Install library
#

install(
        FILES ${CMAKE_BINARY_DIR}/${LIBWEBRTC_LIBRARY}
        DESTINATION ${LIBWEBRTC_INSTALL_LIB_DIR}
        COMPONENT Libraries
)

#
# Install headers
#

file(
        GLOB_RECURSE header_files
        RELATIVE ${CMAKE_BINARY_DIR}/src
        FOLLOW_SYMLINKS
        ${CMAKE_BINARY_DIR}/src/webrtc/*.h
)

foreach(f ${header_files})
    get_filename_component(RELATIVE_PATH ${f} DIRECTORY)
    install(
            FILES ${CMAKE_BINARY_DIR}/src/${f}
            DESTINATION ${LIBWEBRTC_INSTALL_INCLUDE_DIR}/${RELATIVE_PATH}
            COMPONENT Headers
    )
endforeach()