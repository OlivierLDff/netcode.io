#
#   netcode.io CMake build script
#
#   Copyright Olivier Le Doeuff 2019
#
#   Revision:
#   - Olivier Le Doeuff [19/08/2019] : Initial work
#       - netcode.io static or shared library build (NETCODEIO_BUILD_SHARED)
#       - Test integration with ctest (NETCODEIO_ENABLE_TESTS)
#       - Generate examples (NETCODEIO_ENABLE_EXAMPLES)
#       - Install netcode.io (NETCODEIO_ENABLE_INSTALL)
#

# ┌──────────────────────────────────────────────────────────────────┐
# │                       CMAKE PROPERTIES                           │
# └──────────────────────────────────────────────────────────────────┘

CMAKE_MINIMUM_REQUIRED( VERSION 3.11 )

# DEPENDANCIES

SET( SODIUM_REPOSITORY "https://github.com/OlivierLDff/libsodium" CACHE STRING "Repository of libsodium" )
SET( SODIUM_TAG "master" CACHE STRING "Git Tag of libsodium" )

# ┌──────────────────────────────────────────────────────────────────┐
# │                       PROJECT SETTINGS                           │
# └──────────────────────────────────────────────────────────────────┘

# OPTIONS

# General
SET( NETCODEIO_PROJECT "netcode.io" CACHE STRING "Project Name")
SET( NETCODEIO_TARGET ${NETCODEIO_PROJECT} CACHE STRING "netcode.io library name" )
SET( NETCODEIO_VERSION "1.02" CACHE STRING "netcode.io current version, this is only decorative and will not configure any files" FORCE )
SET( NETCODEIO_BUILD_SHARED OFF CACHE BOOL "Build as a shared library (ON) or as static (OFF)" )
SET( NETCODEIO_FOLDER_PREFIX ${NETCODEIO_PROJECT} CACHE STRING "Prefix folder for all netcode.io generated targets in generated project (only decorative)" )

# Tests
SET( NETCODEIO_ENABLE_TESTS OFF CACHE BOOL "Create or not a target for test (compatible with CTests)" )
SET( NETCODEIO_TESTS_PREFIX ${NETCODEIO_PROJECT} CACHE STRING "Prefix for all netcode tests" )

# Examples
SET( NETCODEIO_ENABLE_EXAMPLES OFF CACHE BOOL "Create or not a target for examples" )
SET( NETCODEIO_EXAMPLES_PREFIX ${NETCODEIO_PROJECT} CACHE STRING "Prefix for all netcode tests" )

# Install
SET( NETCODEIO_ENABLE_INSTALL OFF CACHE BOOL "Create or not a target for install" )
SET( NETCODEIO_INSTALL_PREFIX ${NETCODEIO_PROJECT} CACHE STRING "Prefix for all netcode headers in the install folder" )

# CREATE PROJECT

PROJECT( ${NETCODEIO_PROJECT} VERSION ${NETCODEIO_VERSION} LANGUAGES C CXX )
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# LOG OPTIONS

MESSAGE("---------------- NETCODE.IO OPTIONS. ----------------")

#General
MESSAGE(STATUS "NETCODEIO_PROJECT          : " ${NETCODEIO_PROJECT})
MESSAGE(STATUS "NETCODEIO_TARGET           : " ${NETCODEIO_TARGET})
MESSAGE(STATUS "NETCODEIO_VERSION          : " ${NETCODEIO_VERSION})
MESSAGE(STATUS "NETCODEIO_BUILD_SHARED     : " ${NETCODEIO_BUILD_SHARED})
MESSAGE(STATUS "NETCODEIO_FOLDER_PREFIX    : " ${NETCODEIO_FOLDER_PREFIX})

# Tests
MESSAGE(STATUS "NETCODEIO_ENABLE_TESTS     : " ${NETCODEIO_ENABLE_TESTS})
IF(NETCODEIO_ENABLE_TESTS)
MESSAGE(STATUS "NETCODEIO_TESTS_PREFIX     : " ${NETCODEIO_TESTS_PREFIX})
ENDIF(NETCODEIO_ENABLE_TESTS)

# Examples
MESSAGE(STATUS "NETCODEIO_ENABLE_EXAMPLES  : " ${NETCODEIO_ENABLE_EXAMPLES})
IF(NETCODEIO_ENABLE_EXAMPLES)
MESSAGE(STATUS "NETCODEIO_EXAMPLES_PREFIX  : " ${NETCODEIO_EXAMPLES_PREFIX})
ENDIF(NETCODEIO_ENABLE_EXAMPLES)

# Install
MESSAGE(STATUS "NETCODEIO_ENABLE_INSTALL   : " ${NETCODEIO_ENABLE_INSTALL})
IF(NETCODEIO_ENABLE_INSTALL)
MESSAGE(STATUS "NETCODEIO_INSTALL_PREFIX   : " ${NETCODEIO_INSTALL_PREFIX})
ENDIF(NETCODEIO_ENABLE_INSTALL)

MESSAGE("---------------- DONE WITH OPTIONS. -----------------")
MESSAGE("                                                     ")

# ┌──────────────────────────────────────────────────────────────────┐
# │                       DEPENDENCIES                               │
# └──────────────────────────────────────────────────────────────────┘

include(FetchContent)

# libsodium
FetchContent_Declare(
    libsodium
    GIT_REPOSITORY ${SODIUM_REPOSITORY}
    GIT_TAG        ${SODIUM_TAG}
)

SET(FETCHCONTENT_UPDATES_DISCONNECTED ON)
SET(FETCHCONTENT_QUIET OFF)

# Make all dependancies avaiables
FetchContent_MakeAvailable(libsodium)

# ┌──────────────────────────────────────────────────────────────────┐
# │                          NETCODE.IO                              │
# └──────────────────────────────────────────────────────────────────┘

# NETCODE SOURCES
SET(NETCODEIO_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/netcode.c)
SET(NETCODEIO_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/netcode.h)

# NETCODE.IO TARGET
IF(NETCODEIO_BUILD_SHARED)

    TARGET_COMPILE_DEFINITIONS(${NETCODEIO_TARGET} PRIVATE "-DNETCODEIO_DLL_EXPORT")
    ADD_LIBRARY(${NETCODEIO_TARGET} SHARED ${NETCODEIO_SOURCES} ${NETCODEIO_HEADERS})

ELSE(NETCODEIO_BUILD_SHARED)

    ADD_LIBRARY(${NETCODEIO_TARGET} STATIC  ${NETCODEIO_SOURCES} ${NETCODEIO_HEADERS})
    TARGET_COMPILE_DEFINITIONS(${NETCODEIO_TARGET} PUBLIC "-DNETCODEIO_STATIC")

ENDIF(NETCODEIO_BUILD_SHARED)

# Set include directory
TARGET_INCLUDE_DIRECTORIES(${NETCODEIO_TARGET} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:${NETCODEIO_INSTALL_PREFIX}>)

# Avoid libnetcode.io on darwin for example.
SET_TARGET_PROPERTIES(${NETCODEIO_TARGET} PROPERTIES PREFIX "")

# Link to sodium library
TARGET_LINK_LIBRARIES(${NETCODEIO_TARGET} ${SODIUM_TARGET})

SET_TARGET_PROPERTIES(${NETCODEIO_TARGET} PROPERTIES FOLDER ${NETCODEIO_FOLDER_PREFIX})

# Link to math library when not using msvc
IF(NOT MSVC)
    TARGET_LINK_LIBRARIES(${NETCODEIO_TARGET} m)
ENDIF(NOT MSVC)

# ┌──────────────────────────────────────────────────────────────────┐
# │                           TESTS                                  │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODEIO_ENABLE_TESTS)
    INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/CTestLists.txt)
ENDIF(NETCODEIO_ENABLE_TESTS)

# ┌──────────────────────────────────────────────────────────────────┐
# │                         EXAMPLES                                 │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODEIO_ENABLE_EXAMPLES)

    MACRO(NETCODDEIO_ADD_EXAMPLE EXAMPLE_NAME)

        SET(EXAMPLE_FULL_NAME ${NETCODEIO_EXAMPLES_PREFIX}_${EXAMPLE_NAME})

        MESSAGE(STATUS "Add Example: ${EXAMPLE_FULL_NAME}")

        ADD_EXECUTABLE       (${EXAMPLE_FULL_NAME} ${EXAMPLE_NAME}.c)
        TARGET_LINK_LIBRARIES(${EXAMPLE_FULL_NAME} ${NETCODEIO_TARGET})
        SET_TARGET_PROPERTIES(${EXAMPLE_FULL_NAME} PROPERTIES FOLDER ${NETCODEIO_FOLDER_PREFIX}/Examples)

    ENDMACRO()

    NETCODDEIO_ADD_EXAMPLE(soak)
    NETCODDEIO_ADD_EXAMPLE(profile)
    NETCODDEIO_ADD_EXAMPLE(client)
    NETCODDEIO_ADD_EXAMPLE(server)
    NETCODDEIO_ADD_EXAMPLE(client_server)

ENDIF(NETCODEIO_ENABLE_EXAMPLES)

# ┌──────────────────────────────────────────────────────────────────┐
# │                         INSTALL                                  │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODEIO_ENABLE_INSTALL)
    INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/CInstallLists.txt)
ENDIF(NETCODEIO_ENABLE_INSTALL)