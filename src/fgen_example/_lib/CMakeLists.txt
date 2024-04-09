# ~~~
# The name of the extension modules to build, excluding file extensions.
# It is required that the yaml and the f90 file share the same name and are in the same folder
# (i.e. they only differ by file extension).
# fgen will raise an error if this isn't the case.
# ~~~
set(
  EXTENSION_MODULES
  derived_type
  operations
)

# Helper variables to shorten the file definitions
set(py_project_directory ${CMAKE_CURRENT_SOURCE_DIR}/src/fgen_example)
set(extension_directory ${py_project_directory}/_lib)

foreach(module ${EXTENSION_MODULES})
  # ~~~
  # Run fgen generate on a module.
  # This will only be run if the YAML/fortran files changes.
  # TODO: this currently ignores the fact that a python file is generated as
  # it doesn't play a role in the build process
  # ~~~

  # cmake-format: off
  add_custom_command(
    OUTPUT "${extension_directory}/${module}_manager.f90"
           "${extension_directory}/${module}_wrapped.f90"
    COMMAND fgen generate -f ${extension_directory}/${module}.yaml
      --extension fgen_example._lib
      --wrapper-directory ${extension_directory}/
      --python-directory ${py_project_directory}/
    DEPENDS "${extension_directory}/${module}.f90"
             "${extension_directory}/${module}.yaml"
    VERBATIM
  )
  # cmake-format: on

  list(
    APPEND
    ANCILLARY_FORTRAN_SOURCES
    "${extension_directory}/${module}.f90"
    "${extension_directory}/${module}_manager.f90"
  )
  list(
    APPEND
    WRAPPED_FORTRAN_SOURCES
    "${extension_directory}/${module}_wrapped.f90"
  )
endforeach()
