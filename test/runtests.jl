include("setup.jl")

@testset verbose=true "TestRunner tests" begin
    # include("runtests_tests.jl")
    # include("testnames_tests.jl")
    runtests()
end
