#------ test program: Fortran Complex Double Precision ----------
add_executable(f_esprit_cmpl RunSubspace.f90)
target_link_libraries(f_esprit_cmpl PRIVATE subspace::subspace)
add_test(NAME fortran:complex:esprit COMMAND f_esprit_cmpl)
#------ test program: Fortran Real Single Precision -------------
add_executable(f_esprit_real RunSubspace_realsp.f90)
target_link_libraries(f_esprit_real PRIVATE subspace::subspace)
add_test(NAME fortran:real:esprit COMMAND f_esprit_real)
#------ test program: C Real Single -----------------------------
add_executable(c_esprit cSubspace.c)
target_include_directories(c_esprit PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_link_libraries(c_esprit PRIVATE subspace::subspace)
target_compile_features(c_esprit PRIVATE c_std_11)
set_property(TARGET c_esprit PROPERTY LINKER_LANGUAGE C)
add_test(NAME c:esprit COMMAND c_esprit)
#------ test program: C++ Real Single ---------------------------
add_executable(cpp_esprit cppSubspace.cpp)
target_include_directories(cpp_esprit PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_link_libraries(cpp_esprit PRIVATE subspace::subspace)
target_compile_features(cpp_esprit PRIVATE cxx_std_11)
add_test(NAME cpp:esprit COMMAND cpp_esprit)
