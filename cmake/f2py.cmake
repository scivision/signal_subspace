# CMake >= 3.18

find_package(Python REQUIRED
  COMPONENTS Interpreter Development.Module NumPy)

# Grab the variables from a local Python installation
# F2PY headers
set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

execute_process(
  COMMAND ${Python_EXECUTABLE} -c "import numpy.f2py; print(numpy.f2py.get_include())"
  OUTPUT_VARIABLE F2PY_INCLUDE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE ret
)

if(NOT ret EQUAL 0)
  message(WARNING "Failed to get f2py include dir ${ret}")
  return()
endif()

cmake_path(CONVERT "${F2PY_INCLUDE_DIR}" TO_CMAKE_PATH_LIST F2PY_INCLUDE_DIR)

# Print out the discovered paths
include(CMakePrintHelpers)
cmake_print_variables(Python_INCLUDE_DIRS)
cmake_print_variables(F2PY_INCLUDE_DIR)
cmake_print_variables(Python_NumPy_INCLUDE_DIRS)

# Common variables
set(f2py_module_name "pysubspace")
set(f2py_module_c "${CMAKE_CURRENT_BINARY_DIR}/${f2py_module_name}module.c")

get_property(f2py_src TARGET subspace PROPERTY SOURCES)
message(VERBOSE "f2py ${f2py_module_name} sources: ${f2py_src}")


# Generate sources
add_custom_target(
  genpyf
  DEPENDS "${f2py_module_c}"
)
add_custom_command(
  OUTPUT "${f2py_module_c}"
  COMMAND ${Python_EXECUTABLE}  -m "numpy.f2py"
                   "${fortran_src_file}"
                   -m "${f2py_module_name}"
                   --lower # Important
  DEPENDS ${f2py_src} # Fortran source
)

# Set up target
Python_add_library(${f2py_module_name} MODULE WITH_SOABI
  "${f2py_module_c}" # Generated
  "${F2PY_INCLUDE_DIR}/fortranobject.c" # From NumPy
  "${f2py_src}"
)
