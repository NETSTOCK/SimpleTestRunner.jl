# Maintainer note:
#
# This repository intentionally does not include the auto-activation block that
# Interactive.setup writes into generated test/runtests.jl files.
#
# Reason: this package's own test/setup.jl does `using SimpleTestRunner` from
# the working checkout. For this repository, forcing activation of
# test/Project.toml can hide that checkout package and break direct workflows.
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
