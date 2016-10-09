find_program(DEPOTTOOLS_GCLIENT_EXECUTABLE
             NAMES gclient gclient.bat
             PATHS ${CMAKE_CURRENT_SOURCE_DIR}/Dependencies/depot_tools)

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
find_package_handle_standard_args(DepotTools
                                  REQUIRED_VARS DEPOTTOOLS_GCLIENT_EXECUTABLE
                                  FAIL_MESSAGE "Could not find the gclient executable.")