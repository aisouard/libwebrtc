find_program(GCLIENT_EXECUTABLE
             NAMES gclient gclient.bat
             DOC "Path to gclient executable"
             HINTS ${DEPOT_TOOLS_PATH} ENV DEPOT_TOOLS_PATH)

find_path(DEPOT_TOOLS_PATH
          NAMES gclient gclient.py gclient.bat
                ninja ninja.exe ninja-linux32 ninja-linux64 ninja-mac
                download_from_google_storage download_from_google_storage.bat
                download_from_google_storage.py
          DOC "Path to depot_tools directory"
          HINTS ${DEPOT_TOOLS_PATH} ENV DEPOT_TOOLS_PATH)

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
find_package_handle_standard_args(DepotTools
                                  REQUIRED_VARS GCLIENT_EXECUTABLE DEPOT_TOOLS_PATH
                                  FAIL_MESSAGE "Could not find depot_tools.")
