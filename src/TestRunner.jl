module TestRunner

using Test

export test_names, testprogram, runtests

"""
    testprogram()

Identify the test program file.

In an interactive session, or if `PROGRAM_FILE` is empty, the program file is the file from
which testprogram()'s caller was called. otherwise, the program file is the value of
`PROGRAM_FILE`.

For example, if `test/runtests.jl` calls `runtests` and then `runtests` calls
`testprogram`:

* In an interactive session, the program file is `test/runtests.jl`.
* If `PROGRAM_FILE` is empty, the program file is `test/runtests.jl`.
* If `PROGRAM_FILE` is not empty in a non-interactive session, the program file is the
  value of `PROGRAM_FILE`.
"""
function testprogram()
    isinteractive() || isempty(PROGRAM_FILE) ? String(stacktrace()[4].file) : PROGRAM_FILE
end

"""
    test_names(dir::String)

List test names found under `dir`.

Test name strings are derived from the relative path of each file under `dir` with a name
ending in `_tests.jl`.

For example, if `dir` contains a file named `foo_tests.jl`, a directory named `bar` and a
file in the `bar` directory named `baz_tests.jl`, then the list of test names would be
`["foo", "bar/baz"]`.
"""
function test_names(dir::String)
    tests = []
    rel = relpath(dir)
    for (root, dirs, files) in walkdir(rel)
        for f in filter(endswith("_tests.jl"), files)
            path = joinpath(root, f)
            name = path[length(rel) + 2:end - length("_tests.jl")]
            push!(tests, name)
        end
    end
    return tests
end

"""
    runtests(args::Vector{String}=ARGS; io::IO=stdout, progname::String=testprogram())

Run tests from some or all test files in a test directory tree.

The root of the tree is taken as the directory in which `progname` exists.

The list of test names is taken from `ARGS` if `ARGS` is non-empty, otherwise from calling
`test_names` for the root of the tree.

The list of test names is then used to construct test file names that are included with
`include`, each include wrapped in its own `@testset`.
"""
function runtests(args::Vector{String}=ARGS; io::IO=stdout, progname::String=testprogram())
    if any(in(args), ["--help", "-h", "-?"])
        println(io, "usage: julia --project=. $(progname) [name...]")
        return
    end
    dir = dirname(abspath(progname))
    desired_tests = isempty(args) ? test_names(dir) : args
    for test in desired_tests
        @testset "$(test) tests" begin
            include(joinpath(pwd(), dir, "$(test)_tests.jl"))
        end
    end
end

end # module TestRunner
