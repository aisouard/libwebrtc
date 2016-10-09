include(Common)

#
# Fetch
#

set(GCLIENT_CONFIG_COMMAND
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} config --name src
    https://chromium.googlesource.com/external/webrtc.git)

add_libwebrtc_command(libwebrtc_config
                      ${CMAKE_BINARY_DIR}/.gclient
                      "${GCLIENT_CONFIG_COMMAND}"
                      ${CMAKE_BINARY_DIR}
                      "Configuring gclient to pull webrtc code")

#
# Sync
#

set(GCLIENT_SYNC_COMMAND
    ${DEPOTTOOLS_GCLIENT_EXECUTABLE} sync
    --revision ${LIBWEBRTC_WEBRTC_REVISION} -n -D)

add_libwebrtc_command(libwebrtc_sync
                      ${CMAKE_BINARY_DIR}/src/all.gyp
                      "${GCLIENT_SYNC_COMMAND}"
                      ${CMAKE_BINARY_DIR}
                      "Retrieving WebRTC source code"
                      libwebrtc_config)

#
# Sync Chromium
#

set(GIT_CLONE_COMMAND
    git clone ${LIBWEBRTC_CHROMIUM_DEPS} ${CMAKE_BINARY_DIR}/src/chromium/src)

add_libwebrtc_command(libwebrtc_chromium_deps
                      ${CMAKE_BINARY_DIR}/src/chromium/src
                      "${GIT_CLONE_COMMAND}"
                      ${CMAKE_BINARY_DIR}
                      "Retrieving Chromium dependencies"
                      libwebrtc_sync)

#
# Update Clang
#

set(UPDATE_CLANG_COMMAND python chromium/src/tools/clang/scripts/update.py)

add_libwebrtc_command(libwebrtc_clang
                      ${CMAKE_BINARY_DIR}/src/chromium/src/third_party/llvm-build
                      "${UPDATE_CLANG_COMMAND}"
                      ${CMAKE_BINARY_DIR}/src
                      "Updating clang"
                      libwebrtc_chromium_deps)

#
# Setup Links
#

set(SETUP_LINKS_COMMAND python setup_links.py)

add_libwebrtc_command(libwebrtc_links
                      ${CMAKE_BINARY_DIR}/src/tools/clang
                      "${SETUP_LINKS_COMMAND}"
                      ${CMAKE_BINARY_DIR}/src
                      "Creating symbolic links"
                      libwebrtc_clang)
