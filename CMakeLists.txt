#
#   netcode.io CMake build script
#
#   Revision:
#   - Olivier Le Doeuff [19/08/2019] : Initial work
#       - netcode.io static or shared library build (NETCODEIO_BUILD_SHARED)
#       - Build libsodium dependancies when SODIUM_TARGET isn't specified
#       - Test integration with ctest (NETCODEIO_ENABLE_TESTS)
#       - Generate examples (NETCODEIO_ENABLE_EXAMPLES)
#       - Install netcode.io (target install)
#

# ┌──────────────────────────────────────────────────────────────────┐
# │                       CMAKE PROPERTIES                           │
# └──────────────────────────────────────────────────────────────────┘

CMAKE_MINIMUM_REQUIRED( VERSION 3.11 )

# DEPENDANCIES

SET( SODIUM_REPOSITORY "https://github.com/OlivierLdff/libsodium.git" CACHE STRING "Repository of libsodium" )
SET( SODIUM_TAG "master" CACHE STRING "Git Tag of libsodium" )

# ┌──────────────────────────────────────────────────────────────────┐
# │                       PROJECT SETTINGS                           │
# └──────────────────────────────────────────────────────────────────┘

# OPTIONS

SET( NETCODEIO_PROJECT "netcode.io" CACHE STRING "Project Name")
SET( NETCODEIO_TARGET "netcode.io" CACHE STRING "netcode.io library name" )
SET( NETCODEIO_VERSION "1.02" CACHE STRING "netcode.io current version, this is only decorative and will not configure any files" FORCE )
SET( NETCODEIO_BUILD_SHARED OFF CACHE BOOL "Build as a shared library (ON) or as static (OFF)" )
SET( NETCODEIO_ENABLE_TESTS OFF CACHE BOOL "Create or not a target for test (compatible with CTests)" )
SET( NETCODEIO_ENABLE_EXAMPLES OFF CACHE BOOL "Create or not a target for examples" )

# CREATE PROJECT

PROJECT( ${NETCODEIO_PROJECT} VERSION ${NETCODEIO_VERSION} LANGUAGES C CXX )
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# LOG OPTIONS

MESSAGE("---------------- NETCODE.IO OPTIONS. ----------------")

MESSAGE(STATUS "NETCODEIO_PROJECT         : " ${NETCODEIO_PROJECT})
MESSAGE(STATUS "NETCODEIO_TARGET          : " ${NETCODEIO_TARGET})
MESSAGE(STATUS "NETCODEIO_VERSION         : " ${NETCODEIO_VERSION})
MESSAGE(STATUS "NETCODEIO_BUILD_SHARED    : " ${NETCODEIO_BUILD_SHARED})
MESSAGE(STATUS "NETCODEIO_ENABLE_TESTS    : " ${NETCODEIO_ENABLE_TESTS})
MESSAGE(STATUS "NETCODEIO_ENABLE_EXAMPLES : " ${NETCODEIO_ENABLE_TESTS})

MESSAGE("---------------- DONE WITH OPTIONS. -----------------")
MESSAGE("                                                     ")

# ┌──────────────────────────────────────────────────────────────────┐
# │                       DEPENDENCIES                               │
# └──────────────────────────────────────────────────────────────────┘

include(FetchContent)

# LIB SODIUM
FetchContent_Declare(
    libsodium
    GIT_REPOSITORY ${SODIUM_REPOSITORY}
    GIT_TAG        ${SODIUM_TAG}
)

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
TARGET_INCLUDE_DIRECTORIES(${NETCODEIO_TARGET} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:netcode.io>)

# Avoid libnetcode.io on darwin for example.
SET_TARGET_PROPERTIES(${NETCODEIO_TARGET} PROPERTIES PREFIX "")
TARGET_LINK_LIBRARIES(${NETCODEIO_TARGET} m ${SODIUM_TARGET})

# ┌──────────────────────────────────────────────────────────────────┐
# │                           TESTS                                  │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODEIO_ENABLE_TESTS)

    # Because tests are in the netcode.c file, the target needs to enable the tests at build time to correctly define symbols
    TARGET_COMPILE_DEFINITIONS(${NETCODEIO_TARGET} PRIVATE "-DNETCODE_ENABLE_TESTS")

    ENABLE_TESTING()

    # Add a test executable. We can't name it test, it's forbidden by cmake system.
    ADD_EXECUTABLE            (netcode_test     test.cpp)
    TARGET_LINK_LIBRARIES     (netcode_test     ${NETCODEIO_TARGET})
    SET_TARGET_PROPERTIES     (netcode_test     PROPERTIES FOLDER Tests)

    # Little trick in order to avoid the #include <netcode.c> in test.c. This is done in order to make sure premake build remain untouched
    TARGET_COMPILE_DEFINITIONS(netcode_test     PRIVATE "-DNETCODE_CMAKE_TEST")

    # Create the test
    ADD_TEST(NAME netcode_test                  COMMAND netcode_test)

ENDIF(NETCODEIO_ENABLE_TESTS)

# ┌──────────────────────────────────────────────────────────────────┐
# │                         EXAMPLES                                 │
# └──────────────────────────────────────────────────────────────────┘

IF(NETCODEIO_ENABLE_EXAMPLES)

    ADD_EXECUTABLE       (soak                  soak.c)
    TARGET_LINK_LIBRARIES(soak                  ${NETCODEIO_TARGET})
    SET_TARGET_PROPERTIES(soak                  PROPERTIES FOLDER Examples)

    ADD_EXECUTABLE       (profile               profile.c)
    TARGET_LINK_LIBRARIES(profile               ${NETCODEIO_TARGET})
    SET_TARGET_PROPERTIES(profile               PROPERTIES FOLDER Examples)

    ADD_EXECUTABLE       (client                client.c)
    TARGET_LINK_LIBRARIES(client                ${NETCODEIO_TARGET})
    SET_TARGET_PROPERTIES(client                PROPERTIES FOLDER Examples)

    ADD_EXECUTABLE       (server                server.c)
    TARGET_LINK_LIBRARIES(server                ${NETCODEIO_TARGET})
    SET_TARGET_PROPERTIES(server                PROPERTIES FOLDER Examples)

    ADD_EXECUTABLE       (client_server         client_server.c)
    TARGET_LINK_LIBRARIES(client_server         ${NETCODEIO_TARGET})
    SET_TARGET_PROPERTIES(client_server         PROPERTIES FOLDER Examples)

ENDIF(NETCODEIO_ENABLE_EXAMPLES)

####

# Layout. This works for all platforms:
#   * <prefix>/lib/cmake/<PROJECT-NAME>
#   * <prefix>/lib/
#   * <prefix>/include/
set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(include_install_dir "include")

set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")

# Configuration
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(targets_export_name "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

# Include module with fuction 'write_basic_package_version_file'
include(CMakePackageConfigHelpers)

# Configure '<PROJECT-NAME>ConfigVersion.cmake'
# Note: PROJECT_VERSION is used as a VERSION
write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)

# Configure '<PROJECT-NAME>Config.cmake'
# Use variables:
#   * targets_export_name
#   * PROJECT_NAME
MESSAGE(STATUS "Configure Config.cmake.in file located in ${CMAKE_CURRENT_SOURCE_DIR}/cmake")
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
)

# Targets:
#   * <prefix>/lib/libbar.a
#   * <prefix>/lib/libbaz.a
#   * header location after install: <prefix>/include/foo/Bar.hpp
#   * headers can be included by C++ code `#include <foo/Bar.hpp>`
install(
    TARGETS ${NETCODEIO_TARGET}
    EXPORT "${targets_export_name}"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    INCLUDES DESTINATION "${include_install_dir}"
)

#install(TARGETS libsodium DESTINATION ".")

add_custom_command(
        TARGET ${NETCODEIO_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
                ${CMAKE_CURRENT_SOURCE_DIR}/netcode.h
                ${CMAKE_CURRENT_BINARY_DIR}/include/netcode.io/netcode.h)

# Headers:
#   * Source/foo/Bar.hpp -> <prefix>/include/foo/Bar.hpp
#   * Source/foo/Baz.hpp -> <prefix>/include/foo/Baz.hpp
install(
    DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/netcode.io"
    DESTINATION "${include_install_dir}"
    FILES_MATCHING PATTERN "*.h"
)

# Export headers:
#   ${NETCODEIO_HEADERS}
#install(
#    FILES
#        ${NETCODEIO_HEADERS}
#    DESTINATION "${include_install_dir}"
#)

# Config
#   * <prefix>/lib/cmake/Foo/FooConfig.cmake
#   * <prefix>/lib/cmake/Foo/FooConfigVersion.cmake
install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
)

# Config
#   * <prefix>/lib/cmake/Foo/FooTargets.cmake
install(
    EXPORT "${targets_export_name}"
    NAMESPACE "${namespace}"
    DESTINATION "${config_install_dir}"
)
