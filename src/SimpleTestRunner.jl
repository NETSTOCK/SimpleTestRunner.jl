module SimpleTestRunner

using Reexport
@reexport using Test

export runtests, testdir, testnames, testprogram

include("Interactive.jl")

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
    testprogram()

Identify the test directory.

This is simply the relative directory name of the absolute path of `progname`.
"""
function testdir(progname::String=testprogram())
    relpath(dirname(abspath(progname)))
end

"""
    testnames(dir::String)

List test names found under `dir`.

Test name strings are derived from the relative path of each file under `dir` with a name
ending in `_tests.jl`.

For example, if `dir` contains a file named `foo_tests.jl`, a directory named `bar` and a
file in the `bar` directory named `baz_tests.jl`, then the list of test names would be
`["foo", "bar/baz"]`.
"""
function testnames(dir::String)
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

testfile(test::String) = endswith(test, "_tests.jl") ? test : "$(test)_tests.jl"

testlabel(test::String) = endswith(test, "_tests.jl") ? test[1:end - length("_tests.jl")] : test

function strip_testdir_prefix(path::String, dir::String)
    path_parts = splitpath(normpath(path))
    dir_parts = splitpath(normpath(dir))
    if length(path_parts) >= length(dir_parts) && path_parts[1:length(dir_parts)] == dir_parts
        rest = path_parts[length(dir_parts) + 1:end]
        return isempty(rest) ? "" : joinpath(rest...)
    end
    return path
end

function normalized_testname(test::String, dir::String)
    normalized = strip_testdir_prefix(test, dir)
    return endswith(normalized, "_tests.jl") ? normalized[1:end - length("_tests.jl")] : normalized
end

"""
    runtests(args::Vector{String}=ARGS; io::IO=stdout, progname::String=testprogram())

Run tests from some or all test files in a test directory tree.

The root of the tree is taken as the directory in which `progname` exists.

The list of test names is taken from `ARGS` if `ARGS` is non-empty, otherwise from calling
`testnames` for the root of the tree.

The list of test names is then used to construct test file names that are included into
module `Main` with `Base.include`, each include wrapped in its own `@testset`.
"""
function runtests(args::Vector{String}=ARGS; io::IO=stdout, progname::String=testprogram())
    if any(in(args), ["--help", "-h", "-?"])
        println(io, "usage: julia --project=. $(progname) [name...]")
        return
    end
    dir = testdir(progname)
    desired_tests = isempty(args) ? testnames(dir) : args
    for test in desired_tests
        name = normalized_testname(test, dir)
        @testset "$(name) tests" begin
            Base.include(Main, joinpath(pwd(), dir, testfile(name)))
        end
    end
end

end # module SimpleTestRunner
