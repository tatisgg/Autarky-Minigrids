# Wrapper script for HSL_jll for x86_64-w64-mingw32-libgfortran5
export libhsl

using CompilerSupportLibraries_jll
using MicrosoftMPI_jll
using METIS_jll
using OpenBLAS32_jll
JLLWrappers.@generate_wrapper_header("HSL")
JLLWrappers.@declare_library_product(libhsl, "libhsl.dll")
function __init__()
    JLLWrappers.@generate_init_header(CompilerSupportLibraries_jll, MicrosoftMPI_jll, METIS_jll, OpenBLAS32_jll)
    JLLWrappers.@init_library_product(
        libhsl,
        "bin\\x86_64-w64-mingw32-libgfortran5\\libhsl.dll",
        RTLD_LAZY | RTLD_DEEPBIND,
    )

    JLLWrappers.@generate_init_footer()
end  # __init__()
