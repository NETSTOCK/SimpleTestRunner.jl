include("setup.jl")

@testset verbose=true "TestRunner tests" begin
    # include("runtests_tests.jl")
    # include("test_names_tests.jl")
    runtests()
end
