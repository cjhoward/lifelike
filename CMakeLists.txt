# Prevent in-source builds
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds prohibited. Call cmake from the build directory.")
endif()

cmake_minimum_required(VERSION 3.7)

# Create project
project(lifelike VERSION "1.0.0")

# Create install target
install(DIRECTORY "${PROJECT_SOURCE_DIR}/bin" DESTINATION . USE_SOURCE_PERMISSIONS FILES_MATCHING PATTERN "*")
install(DIRECTORY "${PROJECT_SOURCE_DIR}/share" DESTINATION . USE_SOURCE_PERMISSIONS FILES_MATCHING PATTERN "*")

# Create clean-build target
add_custom_target(clean-build
	COMMAND git clean -fdX
	WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")

# Create cpack target
add_custom_target(cpack
    COMMAND "${CMAKE_COMMAND}" --build . --target package
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    VERBATIM)

# Create dist target
add_custom_target(dist DEPENDS cpack)

# Configure CPack variables
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION "")
set(CPACK_PACKAGE_CONTACT "C. J. Howard <cjhoward@cjhoward.org>")
set(CPACK_OUTPUT_FILE_PREFIX ${PROJECT_SOURCE_DIR}/dist)
set(CPACK_GENERATOR "TGZ;DEB")

# Configure .deb distribution package
set(CPACK_DEBIAN_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")
set(CPACK_DEBIAN_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}.deb")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "conky-all")

# Include CPack macro
include(CPack)

