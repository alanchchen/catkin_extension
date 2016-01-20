macro(add_prebuilt_library)
  cmake_parse_arguments(LOCAL "" "" "NAME;PATH;LINKER_LANGUAGE;VERSION;SOVERSION" ${ARGN})

  find_library(LIB_${LOCAL_NAME}
    NAMES ${LOCAL_NAME}
    PATHS ${LOCAL_PATH}
    NO_DEFAULT_PATH
  )

  add_library(${LOCAL_NAME} ${LIB_${LOCAL_NAME}})
  set_target_properties(${LOCAL_NAME} PROPERTIES LINKER_LANGUAGE ${LOCAL_LINKER_LANGUAGE})

  set(IS_SYMBOLIC false)

  if("${CMAKE_LIBRARY_OUTPUT_DIRECTORY}" STREQUAL "")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CATKIN_DEVEL_PREFIX}/lib)
  endif()

  # If VERSION is not empty
  if(NOT "${LOCAL_VERSION}" STREQUAL "")
    # Things will get strange if we set this
    # set_target_properties(${LOCAL_NAME} PROPERTIES
    #   VERSION ${LOCAL_VERSION}
    # )
    add_custom_target(${LOCAL_NAME}.${LOCAL_VERSION} ALL)
    add_custom_command(
      TARGET ${LOCAL_NAME}.${LOCAL_VERSION}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy ${LIB_${LOCAL_NAME}}.${LOCAL_VERSION} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    )
    set(IS_SYMBOLIC true)
    list(APPEND ${LOCAL_NAME}.LIBS ${LIB_${LOCAL_NAME}}.${LOCAL_VERSION})
  endif()

  # If SOVERSION is not empty
  if(NOT "${LOCAL_SOVERSION}" STREQUAL "")
    # Things will get strange if we set this
    # set_target_properties(${LOCAL_NAME} PROPERTIES
    #   SOVERSION ${LOCAL_SOVERSION}
    # )
    add_custom_target(${LOCAL_NAME}.${LOCAL_SOVERSION} ALL)
    add_custom_command(
      TARGET ${LOCAL_NAME}.${LOCAL_SOVERSION}
      POST_BUILD
      COMMAND cp -af ${LIB_${LOCAL_NAME}}.${LOCAL_SOVERSION} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    )
    add_dependencies(${LOCAL_NAME}.${LOCAL_SOVERSION} ${LOCAL_NAME}.${LOCAL_VERSION})
    set(IS_SYMBOLIC true)
    list(APPEND ${LOCAL_NAME}.LIBS ${LIB_${LOCAL_NAME}}.${LOCAL_SOVERSION})
  endif()

  if(${IS_SYMBOLIC})
    add_custom_command(
      TARGET ${LOCAL_NAME}
      POST_BUILD
      COMMAND cp -af ${LIB_${LOCAL_NAME}} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    )
  else()
    add_custom_command(
      TARGET ${LOCAL_NAME}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy ${LIB_${LOCAL_NAME}} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    )
  endif()
  list(APPEND ${LOCAL_NAME}.LIBS ${LIB_${LOCAL_NAME}})
endmacro()

macro(install_prebuilt_library)
  cmake_parse_arguments(LOCAL "" "" "NAME;DESTINATION" ${ARGN})

  install(
    FILES ${${LOCAL_NAME}.LIBS}
    DESTINATION ${LOCAL_DESTINATION}
  )
endmacro()
