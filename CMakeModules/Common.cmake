macro(add_libwebrtc_command
        ARG_NAME
        ARG_OUTPUT
        ARG_COMMAND
        ARG_WORKING_DIRECTORY
        ARG_COMMENT
)
    set (ARG_DEPENDENCIES ${ARGN})

    add_custom_command(
            OUTPUT  ${ARG_OUTPUT}
            COMMAND export "PATH=${CMAKE_SOURCE_DIR}/Dependencies/depot_tools:$ENV{PATH}" && ${ARG_COMMAND}
            WORKING_DIRECTORY ${ARG_WORKING_DIRECTORY}
            COMMENT ${ARG_COMMENT}
    )

    add_custom_target(
            ${ARG_NAME} ALL
            DEPENDS ${ARG_OUTPUT}
    )

    list(LENGTH ARG_DEPENDENCIES NUM_ARG_DEPENDENCIES)
    if (${NUM_ARG_DEPENDENCIES} GREATER 0)
        add_dependencies(${ARG_NAME} ${ARG_DEPENDENCIES})
    endif ()
endmacro()
