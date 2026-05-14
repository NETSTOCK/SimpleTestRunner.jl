# Maintainer note:
#
# This repository intentionally does not include the LOAD_PATH extension block
# that Interactive.setup writes into generated test/runtests.jl files.
#
# Reason: SimpleTestRunner is already in the active environment when developing
# this repository, so the LOAD_PATH extension is unnecessary. Consumers putting
# SimpleTestRunner in test/Project.toml benefit from the generated block.
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
