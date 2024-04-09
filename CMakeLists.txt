# TODO: auto-generate this with fgen instead (I think that makes more sense because fgen can actually set the
# dependency files , install paths etc. correctly, related to https://gitlab.com/magicc/fgen/-/issues/2)
cmake_minimum_required(VERSION 3.17.2...3.26)

project(
  ${SKBUILD_PROJECT_NAME}
  LANGUAGES C
            Fortran
)

list(
  APPEND
  CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
)

find_package(
  "fgen"
  REQUIRED
)

# Get information about the current python installation
find_package(
  Python
  COMPONENTS
    Interpreter
    Development.Module
    NumPy
    REQUIRED
)

# Find f2py header files
execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -c "import numpy.f2py; print(numpy.f2py.get_include())"
  OUTPUT_VARIABLE F2PY_INCLUDE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Variables to hold the identified sources
set(ANCILLARY_FORTRAN_SOURCES)
set(WRAPPED_FORTRAN_SOURCES)

# ~~~
# Find the required sources to build the extension.
# This also generates the required wrapper code
# and adds the required sources to
# ANCILLARY_FORTRAN_SOURCES and WRAPPED_FORTRAN_SOURCES
# (implicitly, so this could be considered to be a side-effect).
# ~~~
include(src/fgen_example/_lib/CMakeLists.txt)

# ------------------------------------
# TODO: discuss and document the below (xref
# https://gitlab.com/magicc/copier-fgen-based-repository/-/merge_requests/4#note_1696739902)
#
# extension_module_name: the name of the extension module that will be available from Python, usually a more
# generic name like _lib

# _lib build

add_library(
  ${SKBUILD_PROJECT_NAME}-lib
  STATIC
  ${ANCILLARY_FORTRAN_SOURCES}
)

# TODO: add explanation of why this is useful (somewhat related to
# https://gitlab.com/magicc/copier-fgen-based-repository/-/issues/6)
set_target_properties(
  ${SKBUILD_PROJECT_NAME}-lib
  PROPERTIES POSITION_INDEPENDENT_CODE
             ON
)

add_custom_command(
  OUTPUT ${EXTENSION_MODULE_NAME}module.c
         ${EXTENSION_MODULE_NAME}-f2pywrappers2.f90
  DEPENDS ${WRAPPED_FORTRAN_SOURCES}
  VERBATIM
  COMMAND "${Python_EXECUTABLE}" -m numpy.f2py ${WRAPPED_FORTRAN_SOURCES} -m ${EXTENSION_MODULE_NAME} --lower
  COMMENT "Run f2py to generate Python-Fortran interface files"
)

# when linking _lib, search for fgen here
target_link_directories(
  ${SKBUILD_PROJECT_NAME}-lib
  PUBLIC
  ${FGEN_LIB_DIR}
)

# when linking _lib, use libfgen (CMake info https://cmake.org/cmake/help/v3.17/guide/tutorial/index.html)
target_link_libraries(${SKBUILD_PROJECT_NAME}-lib PUBLIC "fgen::fgen")

# Create a compiled Python extension using the f2py generated code
python_add_library(
  ${EXTENSION_MODULE_NAME}
  MODULE
  "${CMAKE_CURRENT_BINARY_DIR}/${EXTENSION_MODULE_NAME}module.c"
  "${CMAKE_CURRENT_BINARY_DIR}/${EXTENSION_MODULE_NAME}-f2pywrappers2.f90"
  ${WRAPPED_FORTRAN_SOURCES}
  "${F2PY_INCLUDE_DIR}/fortranobject.c"
  WITH_SOABI
)
target_link_libraries(
  ${EXTENSION_MODULE_NAME}
  PUBLIC Python::NumPy
         "fgen::fgen"
)
target_include_directories(${EXTENSION_MODULE_NAME} PUBLIC "${F2PY_INCLUDE_DIR}")

# If you are interested, here is an incredibly helpful page to understand why some inclusions/links are public
# and others are private:
# https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#transitive-usage-requirements Our
# translation: the extension module doesn't have any `use fgen` statement, but it won't run without fgen i.e.
# fgen is used by its implementation, but the extension module doesn't use any fgen header files hence
# private. In contrast, the extension module needs numpy's header files so in this we have to use the public
# identifier.
target_link_libraries(${EXTENSION_MODULE_NAME} PRIVATE "${SKBUILD_PROJECT_NAME}-lib")

# Installation location configuration (i.e. where should things be installed) Known limitation of
# scikit-build-core: it doesn't really work with editable installs in expected way always. See
# https://scikit-build-core.readthedocs.io/en/latest/configuration.html#editable-installs
install(TARGETS ${EXTENSION_MODULE_NAME} DESTINATION ${SKBUILD_PROJECT_NAME})
