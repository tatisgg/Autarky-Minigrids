# Wrapper script for HSL_jll for x86_64-linux-musl-libgfortran3
export libhsl

using CompilerSupportLibraries_jll
using MPICH_jll
using METIS_jll
using OpenBLAS32_jll
JLLWrappers.@generate_wrapper_header("HSL")
JLLWrappers.@declare_library_product(libhsl, "libhsl.so")
function __init__()
    JLLWrappers.@generate_init_header(CompilerSupportLibraries_jll, MPICH_jll, METIS_jll, OpenBLAS32_jll)
    JLLWrappers.@init_library_product(
        libhsl,
        "lib/x86_64-linux-musl-libgfortran3/libhsl.so",
        RTLD_LAZY | RTLD_DEEPBIND,
    )

    JLLWrappers.@generate_init_footer()
end  # __init__()
