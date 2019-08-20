#
#   netcode.io CMake build script
#
#   Copyright Olivier Le Doeuff 2019
#
#   Revision:
#   - Olivier Le Doeuff [19/08/2019] : Initial work
#       - netcode.io static or shared library build (NETCODE_BUILD_SHARED)
#       - Test integration with ctest (NETCODE_ENABLE_TESTS)
#       - Generate examples (NETCODE_ENABLE_EXAMPLES)
#       - Install netcode.io (NETCODE_ENABLE_INSTALL)
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
SET( NETCODE_PROJECT "netcode" CACHE STRING "Project Name")
SET( NETCODE_TARGET ${NETCODE_PROJECT} CACHE STRING "netcode.io library name" )
SET( NETCODE_VERSION "1.2.1" CACHE STRING "netcode.io current version, this is only decorative and will not configure any files" FORCE )
SET( NETCODE_BUILD_SHARED OFF CACHE BOOL "Build as a shared library (ON) or as static (OFF)" )
SET( NETCODE_FOLDER_PREFIX ${NETCODE_PROJECT} CACHE STRING "Prefix folder for all netcode.io generated targets in generated project (only decorative)" )

# Tests
SET( NETCODE_ENABLE_TESTS OFF CACHE BOOL "Create or not a target for test (compatible with CTests)" )
SET( NETCODE_TESTS_PREFIX ${NETCODE_PROJECT} CACHE STRING "Prefix for all netcode tests" )

# Examples
SET( NETCODE_ENABLE_EXAMPLES OFF CACHE BOOL "Create or not a target for examples" )
SET( NETCODE_EXAMPLES_PREFIX ${NETCODE_PROJECT} CACHE STRING "Prefix for all netcode tests" )

# Install
SET( NETCODE_ENABLE_INSTALL OFF CACHE BOOL "Create or not a target for install" )
SET( NETCODE_INSTALL_PREFIX ${NETCODE_PROJECT} CACHE STRING "Prefix for all netcode headers in the install folder" )

# CREATE PROJECT

PROJECT( ${NETCODE_PROJECT} VERSION ${NETCODE_VERSION} LANGUAGES C CXX )
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# LOG OPTIONS

MESSAGE("---------------- NETCODE.IO OPTIONS. ----------------")

#General
MESSAGE(STATUS "NETCODE_PROJECT          : " ${NETCODE_PROJECT})
MESSAGE(STATUS "NETCODE_TARGET           : " ${NETCODE_TARGET})
MESSAGE(STATUS "NETCODE_VERSION          : " ${NETCODE_VERSION})
MESSAGE(STATUS "NETCODE_BUILD_SHARED     : " ${NETCODE_BUILD_SHARED})
MESSAGE(STATUS "NETCODE_FOLDER_PREFIX    : " ${NETCODE_FOLDER_PREFIX})

# Tests
MESSAGE(STATUS "NETCODE_ENABLE_TESTS     : " ${NETCODE_ENABLE_TESTS})
IF(NETCODE_ENABLE_TESTS)
MESSAGE(STATUS "NETCODE_TESTS_PREFIX     : " ${NETCODE_TESTS_PREFIX})
ENDIF(NETCODE_ENABLE_TESTS)

# Examples
MESSAGE(STATUS "NETCODE_ENABLE_EXAMPLES  : " ${NETCODE_ENABLE_EXAMPLES})
IF(NETCODE_ENABLE_EXAMPLES)
MESSAGE(STATUS "NETCODE_EXAMPLES_PREFIX  : " ${NETCODE_EXAMPLES_PREFIX})
ENDIF(NETCODE_ENABLE_EXAMPLES)

# Install
MESSAGE(STATUS "NETCODE_ENABLE_INSTALL   : " ${NETCODE_ENABLE_INSTALL})
IF(NETCODE_ENABLE_INSTALL)
MESSAGE(STATUS "NETCODE_INSTALL_PREFIX   : " ${NETCODE_INSTALL_PREFIX})
ENDIF(NETCODE_ENABLE_INSTALL)

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

SET(SODIUM_FOLDER_PREFIX "Dependencies/libsodium" CACHE STRING "")

SET(FETCHCONTENT_UPDATES_DISCONNECTED ON)
SET(FETCHCONTENT_QUIET OFF)

# Make all dependencies avaiables
FetchContent_MakeAvailable(libsodium)

# ┌──────────────────────────────────────────────────────────────────┐
# │                          NETCODE.IO                              │
# └──────────────────────────────────────────────────────────────────┘

# NETCODE SOURCES
SET(NETCODE_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/netcode.c)
SET(NETCODE_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/netcode.h)

# NETCODE.IO TARGET
IF(NETCODE_BUILD_SHARED)

    TARGET_COMPILE_DEFINITIONS(${NETCODE_TARGET} PRIVATE "-DNETCODE_DLL_EXPORT")
    ADD_LIBRARY(${NETCODE_TARGET} SHARED ${NETCODE_SOURCES} ${NETCODE_HEADERS})

ELSE(NETCODE_BUILD_SHARED)

    ADD_LIBRARY(${NETCODE_TARGET} STATIC  ${NETCODE_SOURCES} ${NETCODE_HEADERS})
    TARGET_COMPILE_DEFINITIONS(${NETCODE_TARGET} PUBLIC "-DNETCODE_STATIC")

ENDIF(NETCODE_BUILD_SHARED)

# Set include directory
TARGET_INCLUDE_DIRECTORIES(${NETCODE_TARGET} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:${NETCODE_INSTALL_PREFIX}>)

# Avoid libnetcode.io on darwin for example.
SET_TARGET_PROPERTIES(${NETCODE_TARGET} PROPERTIES PREFIX "")

# Link to sodium library
TARGET_LINK_LIBRARIES(${NETCODE_TARGET} ${SODIUM_TARGET})

SET_TARGET_PROPERTIES(${NETCODE_TARGET} PROPERTIES FOLDER ${NETCODE_FOLDER_PREFIX})

# Link to math library when not using msvc
IF(NOT MSVC)
    TARGET_LINK_LIBRARIES(${NETCODE_TARGET} m)
ENDIF(NOT MSVC)

# ┌──────────────────────────────────────────────────────────────────┐
# │                           TESTS                                  │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODE_ENABLE_TESTS)
    INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/CTestLists.txt)
ENDIF(NETCODE_ENABLE_TESTS)

# ┌──────────────────────────────────────────────────────────────────┐
# │                         EXAMPLES                                 │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODE_ENABLE_EXAMPLES)

    MACRO(NETCODE_ADD_EXAMPLE EXAMPLE_NAME)

        SET(EXAMPLE_FULL_NAME ${NETCODE_EXAMPLES_PREFIX}_${EXAMPLE_NAME})

        MESSAGE(STATUS "Add Example: ${EXAMPLE_FULL_NAME}")

        ADD_EXECUTABLE       (${EXAMPLE_FULL_NAME} ${EXAMPLE_NAME}.c)
        TARGET_LINK_LIBRARIES(${EXAMPLE_FULL_NAME} ${NETCODE_TARGET})
        SET_TARGET_PROPERTIES(${EXAMPLE_FULL_NAME} PROPERTIES FOLDER ${NETCODE_FOLDER_PREFIX}/Examples)

    ENDMACRO()

    NETCODE_ADD_EXAMPLE(soak)
    NETCODE_ADD_EXAMPLE(profile)
    NETCODE_ADD_EXAMPLE(client)
    NETCODE_ADD_EXAMPLE(server)
    NETCODE_ADD_EXAMPLE(client_server)

ENDIF(NETCODE_ENABLE_EXAMPLES)

# ┌──────────────────────────────────────────────────────────────────┐
# │                         INSTALL                                  │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODE_ENABLE_INSTALL)
    INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/CInstallLists.txt)
ENDIF(NETCODE_ENABLE_INSTALL)