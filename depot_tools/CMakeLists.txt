if (DEPOT_TOOLS_PATH)
  return()
endif (DEPOT_TOOLS_PATH)

include(ExternalProject)

if (WIN32)
  set(GCLIENT_EXECUTABLE ${CMAKE_BINARY_DIR}/depot_tools/gclient.bat)
else (WIN32)
  set(GCLIENT_EXECUTABLE ${CMAKE_BINARY_DIR}/depot_tools/gclient)
endif (WIN32)

ExternalProject_Add(
    depot-tools

    GIT_REPOSITORY https://chromium.googlesource.com/chromium/tools/depot_tools
    GIT_TAG main

    PREFIX ${CMAKE_BINARY_DIR}/depot_tools

    CONFIGURE_COMMAND ""
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

set(_NEXT_DEPENDS depot-tools)
