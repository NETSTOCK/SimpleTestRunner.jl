@testset "end-to-end package workflow tests" begin
    mktempdir() do dir
        pkgdir = joinpath(dir, "Foo")
        testdir = joinpath(pkgdir, "test")
        pkgsrc = abspath(joinpath(@__DIR__, ".."))

        function runj(code::String; dir::String=dir)
            cd(dir) do
                run(Cmd([Base.julia_cmd().exec..., "-e", code]))
            end
        end

        runj("using Pkg; Pkg.generate($(repr(pkgdir)))")

        mkpath(testdir)
        runj("using Pkg; Pkg.activate($(repr(testdir))); Pkg.develop(path=$(repr(pkgsrc)))")
        runj(
            "using Pkg; Pkg.activate($(repr(testdir))); using SimpleTestRunner; SimpleTestRunner.Interactive.setup()";
            dir=testdir,
        )

        write(joinpath(testdir, "alpha_tests.jl"), "touch(\"alpha_ran.txt\")\n")
        write(joinpath(testdir, "beta_tests.jl"), "touch(\"beta_ran.txt\")\n")

        cd(pkgdir) do
            run(Cmd([Base.julia_cmd().exec..., "--project=.", "-e", "using Pkg; Pkg.test()"]))
        end

        cd(pkgdir) do
            run(Cmd([Base.julia_cmd().exec..., "--project=.", joinpath("test", "runtests.jl")]))
        end
        @test isfile(joinpath(pkgdir, "alpha_ran.txt"))
        @test isfile(joinpath(pkgdir, "beta_ran.txt"))

        rm(joinpath(pkgdir, "alpha_ran.txt"))
        rm(joinpath(pkgdir, "beta_ran.txt"))

        cd(pkgdir) do
            run(Cmd([Base.julia_cmd().exec..., "--project=.", joinpath("test", "runtests.jl"), "alpha"]))
        end
        @test isfile(joinpath(pkgdir, "alpha_ran.txt"))
        @test !isfile(joinpath(pkgdir, "beta_ran.txt"))

        rm(joinpath(pkgdir, "alpha_ran.txt"))

        cd(pkgdir) do
            run(Cmd([Base.julia_cmd().exec..., "--project=.", joinpath("test", "runtests.jl"), "alpha", "beta"]))
        end
        @test isfile(joinpath(pkgdir, "alpha_ran.txt"))
        @test isfile(joinpath(pkgdir, "beta_ran.txt"))

        rm(joinpath(pkgdir, "alpha_ran.txt"))
        rm(joinpath(pkgdir, "beta_ran.txt"))

        cd(pkgdir) do
            run(Cmd([Base.julia_cmd().exec..., "--project=.", "-e", "include(\"test/runtests.jl\")"]))
        end
        @test isfile(joinpath(pkgdir, "alpha_ran.txt"))
        @test isfile(joinpath(pkgdir, "beta_ran.txt"))

        rm(joinpath(pkgdir, "alpha_ran.txt"))
        rm(joinpath(pkgdir, "beta_ran.txt"))

        cd(pkgdir) do
            run(Cmd([Base.julia_cmd().exec..., "--project=.", joinpath("test", "runtests.jl"), "alpha_tests.jl", "beta_tests.jl"]))
        end
        @test isfile(joinpath(pkgdir, "alpha_ran.txt"))
        @test isfile(joinpath(pkgdir, "beta_ran.txt"))
    end
end