set(BUILD_PATH "${CMAKE_BINARY_DIR}/src/build")
set(DEPOTTOOLS_PATH "${CMAKE_SOURCE_DIR}/Dependencies/depot_tools")

if (WIN32)
  set(DEPOTTOOLS_PATH "${DEPOTTOOLS_PATH};${DEPOTTOOLS_PATH}/python276_bin")
endif (WIN32)

macro(add_libwebrtc_command
      ARG_NAME
      ARG_OUTPUT
      ARG_COMMAND
      ARG_WORKING_DIRECTORY
      ARG_COMMENT)
  set(ARG_DEPENDENCIES ${ARGN})

  if (WIN32)
    add_custom_command(
        OUTPUT ${ARG_OUTPUT}
        COMMAND set "DEPOT_TOOLS_WIN_TOOLCHAIN=0"
        COMMAND set "PATH=${DEPOTTOOLS_PATH};$ENV{PATH}"
        COMMAND set "PYTHONPATH=${BUILD_PATH}"
        COMMAND ${ARG_COMMAND}
        WORKING_DIRECTORY ${ARG_WORKING_DIRECTORY}
        COMMENT ${ARG_COMMENT})
  else (WIN32)
    add_custom_command(
        OUTPUT ${ARG_OUTPUT}
        COMMAND export PATH=${DEPOTTOOLS_PATH}:${BUILD_PATH}:$ENV{PATH} PYTHONPATH=${BUILD_PATH} && ${ARG_COMMAND}
        WORKING_DIRECTORY ${ARG_WORKING_DIRECTORY}
        COMMENT ${ARG_COMMENT})
  endif (WIN32)

  add_custom_target(
      ${ARG_NAME} ALL
      DEPENDS ${ARG_OUTPUT})

  list(LENGTH ARG_DEPENDENCIES NUM_ARG_DEPENDENCIES)
  if (${NUM_ARG_DEPENDENCIES} GREATER 0)
    add_dependencies(${ARG_NAME} ${ARG_DEPENDENCIES})
  endif ()
endmacro()
