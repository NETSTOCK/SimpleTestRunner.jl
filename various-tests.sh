#!/bin/sh -ex
#
# A collection of invocations that has been helpful in protecting the various
# workflows.

# Running all the tests in various ways

julia --project=. test/runtests.jl
julia --project=. -e 'using Pkg; Pkg.test()'
julia --project=. -e 'include("test/runtests.jl");'

cd test
julia --project=.. runtests.jl
cd ..
julia --project=. -e 'cd("test"); include("setup.jl"); include("runtests.jl");'


# Running specific test files in various ways

julia --project=. test/runtests.jl runtests testnames
julia --project=. -e 'include("test/setup.jl"); include("test/runtests_tests.jl");'
julia --project=. -e 'include("test/setup.jl"); include("test/testnames_tests.jl");'
