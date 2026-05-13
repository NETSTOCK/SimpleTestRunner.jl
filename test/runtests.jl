include("setup.jl")

@testset verbose=true "SimpleTestRunner tests" begin
    # include("runtests_tests.jl")
    # include("testnames_tests.jl")
    runtests()
end

if Base.find_package("Aqua") !== nothing
    @info "Running Aqua quality checks"
    using Aqua
    Aqua.test_all(SimpleTestRunner)
else
    @warn "Skipping Aqua quality checks (Aqua not available in active environment)"
end
