macro(add_prebuilt_executable)
  cmake_parse_arguments(LOCAL "" "" "NAME;PATH;LINKER_LANGUAGE" ${ARGN})

  find_program(EXEC_${LOCAL_NAME}
    NAMES ${LOCAL_NAME}
    PATHS ${LOCAL_PATH}
    NO_DEFAULT_PATH
  )

  add_executable(${LOCAL_NAME} EXCLUDE_FROM_ALL ${EXEC_${LOCAL_NAME}})
  set_target_properties(${LOCAL_NAME} PROPERTIES LINKER_LANGUAGE ${LOCAL_LINKER_LANGUAGE})

  if("${CMAKE_RUNTIME_OUTPUT_DIRECTORY}" STREQUAL "")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CATKIN_DEVEL_PREFIX}/lib/${PROJECT_NAME})
  endif()

  add_custom_command(
    TARGET ${LOCAL_NAME}
    POST_BUILD
    COMMAND cp -af ${EXEC_${LOCAL_NAME}} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
  )
endmacro()

macro(install_prebuilt_executable)
  cmake_parse_arguments(LOCAL "" "" "NAME;DESTINATION" ${ARGN})

  install(PROGRAMS ${EXEC_${LOCAL_NAME}}
    DESTINATION ${LOCAL_DESTINATION}
  )
endmacro()
