#------ test program: Fortran Complex Double Precision ----------
add_executable(f_esprit_cmpl RunSubspace.f90)
target_link_libraries(f_esprit_cmpl subspace::subspace)
add_test(NAME fortran:complex:esprit COMMAND $<TARGET_FILE:f_esprit_cmpl>)
#------ test program: Fortran Real Single Precision -------------
add_executable(f_esprit_real RunSubspace_realsp.f90)
target_link_libraries(f_esprit_real subspace::subspace)
add_test(NAME fortran:real:esprit COMMAND $<TARGET_FILE:f_esprit_real>)
#------ test program: C Real Single -----------------------------
add_executable(c_esprit cSubspace.c)
target_link_libraries(c_esprit subspace::subspace)
target_compile_features(c_esprit PRIVATE c_std_11)
set_target_properties(c_esprit PROPERTIES LINKER_LANGUAGE C)
add_test(NAME c:esprit COMMAND $<TARGET_FILE:c_esprit>)
#------ test program: C++ Real Single ---------------------------
add_executable(cpp_esprit cppSubspace.cpp)
target_link_libraries(cpp_esprit subspace::subspace)
target_compile_features(cpp_esprit PRIVATE cxx_std_11)
add_test(NAME cpp:esprit COMMAND $<TARGET_FILE:cpp_esprit>)
