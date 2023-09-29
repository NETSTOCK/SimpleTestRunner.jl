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
    test = joinpath(relpath(dirname(pkg_path)), "test")
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
        println(io, "include(\"setup.jl\")")
        println(io)
        println(io, "@testset \"$(pkg_name) tests\" begin")
        println(io, "    runtests()")
        println(io, "end")
    end
end

end # module Interactive
