# SimpleTestRunner

Provides a `runtests()` function that does most of the work of a Julia project's `test/runtests.jl`:

It assumes that it will be called from a directory that contains files with names ending in `_tests.jl`
and may contain directory trees that themselves may contain files so named. It includes each file in
a `@testset` named after the file.

So, given this directory structure:

```
MyPackage
├── src
│   └── MyPackage.jl
└── test
    ├── bar_tests.jl
    ├── baz_tests.jl
    ├── child
    │   ├── alice_tests.jl
    │   ├── bob_tests.jl
    │   ├── grandchild
    │   │   ├── carol_tests.jl
    │   │   ├── carol_tests.jl.bak
    │   │   └── wrong_suffix_test.jl
    │   └── notes.md
    ├── foo_tests.jl
    ├── readme.md
    ├── runtests.jl
    └── setup.jl
```

If `test/setup.jl` contains the following:

```julia
using MyPackage
using SimpleTestRunner
```

And `test/runtests.jl` contains the following:

```julia
include("test/setup.jl")

@testset "MyPackage tests" begin
    runtests()
end
```

Then full test output will look something like this:

```
Test Summary:                  | Pass  Total  Time
MyPackage tests                |   22     22  1.3s
  bar tests                    |    8      8  0.6s
  baz tests                    |    4      4  0.1s
  foo tests                    |    6      6  0.2s
  child/alice tests            |    1      1  0.0s
  child/bob tests              |    2      2  0.1s
  child/grandchild/carol tests |    1      1  0.3s
```

## Usage

The function grew out of the [Julia Workflow for Testing Packages](https://docs.julialang.org/en/v1/stdlib/Test/#Workflow-for-Testing-Packages) documentation and Erik Engheim's article on [Julia Test Running: Best Practices](https://erikexplores.substack.com/p/julia-testing-best-pratice). So it supports a variety of workflows:

* Infrequent and Correct Testing
* Regular Slow Testing
* Rapid Iteration Testing

### Infrequent and Correct Testing

Notice that `Pkg.test()` creates an isolated, temporary environment.

```
$ julia --project=. -e 'using Pkg; Pkg.test()'
```

This is equivalent to the commonly documented interactive pattern:

```
$ julia
julia> # Press ]
(Example) pkg> activate .
(Example) pkg> test
(Example) pkg> # Press backspace
julia> # Press Ctrl-D
$ 
```

### Regular Slow Testing

Notice that this runs in the default environment (which may include dependencies that are missing from the package).

```
$ julia --project=. test/runtests.jl
```

To run a subset of test files:

```
$ julia --project=. test/runtests.jl foo child/alice
```

### Rapid Iteration Testing

This is all about staying and working from a single Julia REPL process to avoid Julia startup time.

First, install the `Revise` globally:

```
$ julia -e 'using Pkg; Pkg.add("Revise")'
```

Now arrange for the `Revise` package to be loaded into your Julia REPL early:

`~/.julia/config/startup.jl`:
```
if isinteractive()
    try
        using Revise
    catch e
        @warn "Could not initialize Revise" exception=(e, catch_backtrace())
    end
end
```

Now start an interactive Julia REPL in the project environment:

```
$ julia --project=.
```

You can now repeatedly edit/test/repeat without Julia startup overhead.

Run all tests with:

```
julia> include("test/runtests.jl");
```

The semicolon suppresses display of the test set data structure.

Individual test files can be run separately, but only after `test/setup.jl` has been run at least once
in this interactive session:

```
julia> include("test/setup.jl");
julia> include("test/child/alice_tests.jl");
```

Because of the way setup is handled, you can't run individual test files directly from the command-line.
But remember that the runner supports command-line arguments that select the test files you want, e.g.

```
$ julia --project=. test/runtests.jl foo child/alice
```

Individual tests are most easily run with copy and paste into the Julia REPL, again relying
on `test/setup.jl` having been run at least once in this interactive session:

```
julia> include("test/setup.jl");
julia> @test "Hello world!" == greet()
Test Passed
```

VS Code users may find it productive to assign a keybind to _Terminal: Run Selected Text In Active Terminal_
in the Command Palette. This allows test cases to be built up on the fly very quickly.
