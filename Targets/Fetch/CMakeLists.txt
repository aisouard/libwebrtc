#
# Fetch
#

set(gclient_config
        ${DEPOTTOOLS_GCLIENT_EXECUTABLE} config --name src
        https://chromium.googlesource.com/external/webrtc.git
)

add_custom_command(
        OUTPUT  ${CMAKE_BINARY_DIR}/.gclient
        COMMAND ${gclient_config}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Configuring gclient to pull webrtc code"
)

add_custom_target(
        webrtc_config ALL
        DEPENDS ${CMAKE_BINARY_DIR}/.gclient
)

#
# Sync
#

set(gclient_sync
        ${DEPOTTOOLS_GCLIENT_EXECUTABLE} sync -n -D
)

add_custom_command(
        OUTPUT  ${CMAKE_BINARY_DIR}/src/all.gyp
        COMMAND ${gclient_sync}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Retrieving WebRTC source code"
)

add_custom_target(
        webrtc_sync ALL
        DEPENDS ${CMAKE_BINARY_DIR}/src/all.gyp
)

add_dependencies(webrtc_sync webrtc_config)

#
# Sync Chromium
#

add_custom_command(
        OUTPUT  ${CMAKE_BINARY_DIR}/src/chromium/src/DEPS
        COMMAND git clone ${WEBRTC_CHROMIUM_DEPS} ${CMAKE_BINARY_DIR}/src/chromium/src
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Retrieving Chromium dependencies"
)

add_custom_target(
        webrtc_chromium_deps ALL
        DEPENDS ${CMAKE_BINARY_DIR}/src/chromium/src/DEPS
)

add_dependencies(webrtc_chromium_deps webrtc_sync)

#
# Setup Links
#

add_custom_command(
        OUTPUT  ${CMAKE_BINARY_DIR}/src/build
        COMMAND ${CMAKE_COMMAND} -E env \"PATH=${CMAKE_SOURCE_DIR}/Dependencies/depot_tools:$ENV{PATH}\" python setup_links.py
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src
        COMMENT "Creating symbolic links"
)

add_custom_target(
        webrtc_links ALL
        DEPENDS ${CMAKE_BINARY_DIR}/src/build
)

add_dependencies(webrtc_links webrtc_chromium_deps)

#
# Remove examples
#

add_custom_command(
        OUTPUT  None
        COMMAND sed -i "s/'include_examples%': 1/'include_examples%': 0/g" src/all.gyp
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Patching build files"
)

add_custom_target(
        webrtc_patch ALL
        DEPENDS None
)

add_dependencies(webrtc_patch webrtc_links)