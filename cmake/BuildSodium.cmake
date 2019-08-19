#
#   Download Script by Olivier Le Doeuff
#
## CMAKE INPUT
#
#   -SODIUM_REPOSITORY : libsodium repository url
#   -SODIUM_TAG : sodium git tag
#
## CMAKE OUTPUT
#
#

MESSAGE(STATUS "Download and build libsodium")

# repository path & tag
IF( NOT SODIUM_REPOSITORY )
    SET( SODIUM_REPOSITORY "https://github.com/OlivierLdff/libsodium.git" CACHE STRING "libsodium repository, can be a local URL" FORCE )
ENDIF()
MESSAGE(STATUS "libsodium repository folder : ${SODIUM_REPOSITORY}")

IF( NOT DEFINED SODIUM_TAG )
    SET( SODIUM_TAG master CACHE STRING "libsodium git tag" FORCE )
ENDIF()
MESSAGE(STATUS "libsodium repository tag  : ${SODIUM_TAG}")

INCLUDE( ${PROJECT_SOURCE_DIR}/cmake/DownloadProject.cmake )

DOWNLOAD_PROJECT(PROJ   libsodium
    GIT_REPOSITORY      ${SODIUM_REPOSITORY}
    GIT_TAG             ${SODIUM_TAG}
    UPDATE_DISCONNECTED 1
    QUIET
    )

ADD_SUBDIRECTORY( ${libsodium_SOURCE_DIR} ${libsodium_BINARY_DIR} )