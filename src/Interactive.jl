module Interactive

"""
    setup()

Set up SimpleTestRunner for package.

Creates setup.jl and runtests.jl in the test directory of the package.

For example, to create a new project from scratch:

```
using Pkg
Pkg.generate("Foo")
cd("Foo")

mkpath("test");
cd("test")
Pkg.activate(".")

Pkg.add("SimpleTestRunner")
using SimpleTestRunner
SimpleTestRunner.Interactive.setup()
```
"""
function setup(pkg_path::String="../Project.toml")
    pkg_name = basename(dirname(abspath(pkg_path)))
    if pkg_name == "test"
        pkg_path = abspath(joinpath(pkg_path, "..", "..", "Project.toml"))
        pkg_name = basename(dirname(abspath(pkg_path)))
    end
    setup(pkg_name, pkg_path)
end

function setup(pkg_name::String, pkg_path::String)
    test = test = joinpath(dirname(pkg_path), "test")
    mkpath(test)
    setup_file = joinpath(test, "setup.jl")
    @info "Creating $(setup_file)"
    if ispath(setup_file)
        error("File already exists: $(setup_file)")
    end
    open(setup_file; write=true) do io
        println(io, "using $(pkg_name)")
        println(io, "using SimpleTestRunner")
    end
    runtests_file = joinpath(test, "runtests.jl")
    if ispath(runtests_file)
        error("File already exists: $(runtests_file)")
    end
    @info "Creating $(runtests_file)"
    open(runtests_file; write=true) do io
        println(io, "# If invoked as `julia --project=. test/runtests.jl`, switch to test/Project.toml")
        println(io, "let test_project = joinpath(@__DIR__, \"Project.toml\")")
        println(io, "    parent_project = abspath(joinpath(@__DIR__, \"..\", \"Project.toml\"))")
        println(io, "    active_project = try")
        println(io, "        Base.active_project()")
        println(io, "    catch")
        println(io, "        nothing")
        println(io, "    end")
        println(io, "    if isfile(test_project) && active_project !== nothing && abspath(active_project) == parent_project")
        println(io, "        using Pkg")
        println(io, "        Pkg.activate(@__DIR__)")
        println(io, "    end")
        println(io, "end")
        println(io)
        println(io, "include(\"setup.jl\")")
        println(io)
        println(io, "@testset verbose=true \"$(pkg_name) tests\" begin")
        println(io, "    runtests()")
        println(io, "end")
    end
end

end # module Interactive
