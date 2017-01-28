#
# Subsystem
#

set(TARGET_OS "" CACHE STRING "Target OS, used as --target_os argument")
set(TARGET_OS_LIST android chromeos ios linux nacl mac win)

if (TARGET_OS STREQUAL "")
  if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(TARGET_OS "linux")
  elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(TARGET_OS "mac")
  elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
    set(TARGET_OS "win")
  endif ()
endif (TARGET_OS STREQUAL "")

if (NOT ${TARGET_OS} IN_LIST TARGET_OS_LIST)
  message(FATAL_ERROR "Unknown value '${TARGET_OS}' for variable TARGET_OS, the following values are supported: ${TARGET_OS_LIST}")
endif (NOT ${TARGET_OS} IN_LIST TARGET_OS_LIST)

set(TARGET_CPU "" CACHE STRING "Target CPU, used as --target_cpu argument")
set(TARGET_CPU_LIST x86 x64 arm arm64 mipsel)

if (TARGET_CPU STREQUAL "")
  if (CMAKE_SYSTEM_PROCESSOR MATCHES "^i.86$")
    set(TARGET_CPU "x86")
  elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "^x86.64$")
    set(TARGET_CPU "x64")
  elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64")
    set(TARGET_CPU "x64")
  else ()
    set(TARGET_CPU ${CMAKE_SYSTEM_PROCESSOR})
  endif (CMAKE_SYSTEM_PROCESSOR MATCHES "^i.86$")
endif (TARGET_CPU STREQUAL "")

if (NOT ${TARGET_CPU} IN_LIST TARGET_CPU_LIST)
  message(FATAL_ERROR "Unknown value '${TARGET_CPU}' for variable TARGET_CPU, the following values are supported: ${TARGET_CPU_LIST}")
endif (NOT ${TARGET_CPU} IN_LIST TARGET_CPU_LIST)

if (UNIX)
  if (TARGET_CPU STREQUAL "x86")
    set(CMAKE_C_FLAGS -m32)
    set(CMAKE_CXX_FLAGS -m32)
  endif (TARGET_CPU STREQUAL "x86")
endif(UNIX)
