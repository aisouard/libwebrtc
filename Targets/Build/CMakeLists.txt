#
# Generate build files
#

add_custom_command(
        OUTPUT  ${CMAKE_BINARY_DIR}/Nevermind
        COMMAND ${CMAKE_COMMAND} -E env \"PATH=${CMAKE_SOURCE_DIR}/Dependencies/depot_tools:$ENV{PATH}\" gn gen out/Default --args='is_debug=false rtc_include_tests=false'
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src
        COMMENT "Generate build files"
)

add_custom_target(
        webrtc_generate_build ALL
        DEPENDS ${CMAKE_BINARY_DIR}/Nevermind
)

add_dependencies(webrtc_generate_build webrtc_links)

#
# Run ninja
#

add_custom_command(
        OUTPUT  ${CMAKE_BINARY_DIR}/src/out/Default/obj/root.stamp
        COMMAND ${CMAKE_COMMAND} -E env \"PATH=${CMAKE_SOURCE_DIR}/Dependencies/depot_tools:$ENV{PATH}\" ninja -C out/Default
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src
        COMMENT "Build WebRTC"
)

add_custom_target(
        webrtc_build ALL
        DEPENDS ${CMAKE_BINARY_DIR}/src/out/Default/obj/root.stamp
)

add_dependencies(webrtc_build webrtc_generate_build)

#
# Merge libraries into a single one
#

add_custom_command(
        OUTPUT  ${CMAKE_BINARY_DIR}/libwebrtc.a
        COMMAND python webrtc/build/merge_libs.py out/Default ${CMAKE_BINARY_DIR}/libwebrtc.a
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src
        COMMENT "Merging libraries into libwebrtc.a"
)

add_custom_target(
        webrtc_merge ALL
        DEPENDS ${CMAKE_BINARY_DIR}/libwebrtc.a
)

add_dependencies(webrtc_merge webrtc_build)