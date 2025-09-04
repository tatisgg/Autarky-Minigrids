# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule HSL_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("HSL")
JLLWrappers.@generate_main_file("HSL", UUID("017b0a0e-03f4-516a-9b91-836bbd1904dd"))
end  # module HSL_jll
