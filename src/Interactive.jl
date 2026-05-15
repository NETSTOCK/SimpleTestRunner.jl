module Interactive

using TOML

const DEFAULT_PKG_PATH = joinpath("..", "Project.toml")

function project_name_from_toml(pkg_path::String)
    if !isfile(pkg_path)
        return nothing
    end
    try
        data = TOML.parsefile(pkg_path)
        name = get(data, "name", nothing)
        return isa(name, String) && !isempty(name) ? name : nothing
    catch
        return nothing
    end
end

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
function setup(pkg_path::String=DEFAULT_PKG_PATH)
    if normpath(pkg_path) == normpath(DEFAULT_PKG_PATH)
        cwd_project = joinpath(abspath(pwd()), "Project.toml")
        pkg_path = isfile(cwd_project) ? cwd_project : abspath(pkg_path)
    else
        pkg_path = abspath(pkg_path)
    end
    if basename(dirname(pkg_path)) == "test"
        pkg_path = abspath(joinpath(pkg_path, "..", "..", "Project.toml"))
    end
    pkg_name = something(project_name_from_toml(pkg_path), basename(dirname(pkg_path)))
    setup(pkg_name, pkg_path)
end

function setup(pkg_name::String, pkg_path::String)
    test = joinpath(dirname(pkg_path), "test")
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
        println(io, "# Julia 1.10 compatibility shim: when invoked from the package project,")
        println(io, "# add test deps without replacing the active project.")
        println(io, "# Newer Pkg features (`[sources]`, `[workspace]`) can reduce this need,")
        println(io, "# but this keeps subset test workflows working on Julia 1.10.")
        println(io, "let test_dir = @__DIR__, test_project = joinpath(@__DIR__, \"Project.toml\")")
        println(io, "    if isfile(test_project) && !(test_dir in LOAD_PATH)")
        println(io, "        pushfirst!(LOAD_PATH, test_dir)")
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
