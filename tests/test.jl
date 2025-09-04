"""
Test script for validating the successful execution of all Autarky optimization models.

This script performs the following steps for each predefined model folder:
1. Verifies that the corresponding `main.jl` script exists.
2. Executes the model by temporarily switching into its `src` folder.
3. Checks whether the model produces output files in the `results` folder.

Models tested:
- Deterministic Model
- Expected Values Model
- ICC Model
- JCC Model

This script is intended to be used in both local development and continuous integration (CI)
to ensure that the model code is runnable and generates expected output artifacts.
"""

using Test, Dates, Printf

# List of all model folders to test
const MODEL_FOLDERS = [
    "autarky/deterministic",
    "autarky/expected_values",
    "autarky/icc",
    "autarky/jcc_genz",
]

@info("AUTARKY MODEL TESTS")
@info("Starting Autarky model tests at $(now())")

# Iterate through each model and perform checks
for model in MODEL_FOLDERS
    @info("Testing model: $model")

    model_path = joinpath(@__DIR__, "..", model, "src", "main.jl")
    results_path = joinpath(@__DIR__, "..", model, "results")

    @test isfile(model_path)

    try
        @info("Running model: $model ...")

        # Wrap include in a local module to isolate constants/functions
        Core.eval(Main, :(module $(Symbol("Test_$(basename(model))"))
            include($model_path)
        end))

        @info("Successfully ran $model")
    catch e
        @error("Model $model failed to run", exception = e)
        @test false
    end

    outputs = filter(f -> endswith(f, ".csv"), readdir(results_path; join=true))
    @test !isempty(outputs)
    @info("Model $model produced output files: $(join(outputs, ", "))")

    @info("""
    To visualize these results in the Autarky Streamlit app:

    1. Copy the corresponding `inputs/` and `results/` folders from the `$model` directory.
    2. Paste them into your Autarky frontend under: `AutarkyApp/projects/<project_name>/`
    3. Launch the Streamlit app and navigate to the different sections to visualize and compare the results.
    """)
end

@info("All Autarky model tests completed successfully at $(now())")
@info("You can now visualize the results in the Autarky Streamlit app as described above.")
