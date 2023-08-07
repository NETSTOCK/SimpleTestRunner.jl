include("setup.jl")

@testset verbose=true "SimpleTestRunner tests" begin
    # include("runtests_tests.jl")
    # include("testnames_tests.jl")
    runtests()
end
