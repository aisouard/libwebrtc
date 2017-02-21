find_program(GCLIENT_EXECUTABLE
             NAMES gclient gclient.bat
             PATHS ${CMAKE_CURRENT_SOURCE_DIR}/depot_tools)

find_path(DEPOTTOOLS_PATH
          NAMES gclient gclient.py gclient.bat
                gn gn.py gn.bat
                ninja ninja.exe ninja-linux32 ninja-linux64 ninja-mac
                download_from_google_storage download_from_google_storage.bat
                download_from_google_storage.py
          HINTS ${CMAKE_CURRENT_SOURCE_DIR}/depot_tools)

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
find_package_handle_standard_args(DepotTools
                                  REQUIRED_VARS GCLIENT_EXECUTABLE
                                  FAIL_MESSAGE "Could not find the gclient executable.")
