module TestRunner

using Test

export test_names, runtests

function test_names()
    test_names(dirname(_progname()))
end

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

function program_or_caller()
    isinteractive() || isempty(PROGRAM_FILE) ? String(stacktrace()[4].file) : PROGRAM_FILE
end

function runtests(args::Vector{String}=ARGS; io::IO=stdout, progname::String=program_or_caller())
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
