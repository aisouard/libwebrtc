if (WIN32)
  find_program(DEPOTTOOLS_GCLIENT_EXECUTABLE
               NAMES gclient.bat
               PATHS ${CMAKE_CURRENT_SOURCE_DIR}/Dependencies/depot_tools)
else (WIN32)
  find_program(DEPOTTOOLS_GCLIENT_EXECUTABLE
               NAMES gclient
               PATHS ${CMAKE_CURRENT_SOURCE_DIR}/Dependencies/depot_tools)
endif (WIN32)

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
find_package_handle_standard_args(DepotTools
                                  REQUIRED_VARS DEPOTTOOLS_GCLIENT_EXECUTABLE
                                  FAIL_MESSAGE "Could not find the gclient executable.")