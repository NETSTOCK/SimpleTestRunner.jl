@testset "Interactive.setup output tests" begin
    mktempdir() do dir
        pkgdir = joinpath(dir, "DemoPkg")
        mkpath(joinpath(pkgdir, "src"))
        pkg_path = joinpath(pkgdir, "Project.toml")
        touch(pkg_path)

        SimpleTestRunner.Interactive.setup("DemoPkg", pkg_path)

        setup_path = joinpath(pkgdir, "test", "setup.jl")
        runtests_path = joinpath(pkgdir, "test", "runtests.jl")

        @test isfile(setup_path)
        @test isfile(runtests_path)

        setup_text = read(setup_path, String)
        @test contains(setup_text, "using DemoPkg")
        @test contains(setup_text, "using SimpleTestRunner")

        runtests_text = read(runtests_path, String)
        @test contains(runtests_text, "let test_dir = @__DIR__, test_project = joinpath(@__DIR__, \"Project.toml\")")
        @test contains(runtests_text, "if isfile(test_project) && !(test_dir in LOAD_PATH)")
        @test contains(runtests_text, "pushfirst!(LOAD_PATH, test_dir)")
        @test contains(runtests_text, "@testset verbose=true")
        @test contains(runtests_text, "include(\"setup.jl\")")
        @test contains(runtests_text, "runtests()")
    end
end

@testset "Interactive.setup default path from package root" begin
    mktempdir() do dir
        pkgdir = joinpath(dir, "DemoPkg")
        mkpath(joinpath(pkgdir, "src"))
        touch(joinpath(pkgdir, "Project.toml"))
        mkpath(joinpath(pkgdir, "test"))
        touch(joinpath(pkgdir, "test", "Project.toml"))

        cd(pkgdir) do
            SimpleTestRunner.Interactive.setup()
        end

        @test isfile(joinpath(pkgdir, "test", "setup.jl"))
        @test isfile(joinpath(pkgdir, "test", "runtests.jl"))
        @test !ispath(joinpath(dir, "test", "setup.jl"))
        @test !ispath(joinpath(dir, "test", "runtests.jl"))
    end
end

@testset "Interactive.setup uses Project.toml package name" begin
    mktempdir() do dir
        pkgdir = joinpath(dir, "ia-pkg-julia-rpc")
        mkpath(joinpath(pkgdir, "src"))
        write(joinpath(pkgdir, "Project.toml"), "name = \"RabbitRpcServer\"\n")
        mkpath(joinpath(pkgdir, "test"))
        touch(joinpath(pkgdir, "test", "Project.toml"))

        cd(pkgdir) do
            SimpleTestRunner.Interactive.setup()
        end

        setup_text = read(joinpath(pkgdir, "test", "setup.jl"), String)
        runtests_text = read(joinpath(pkgdir, "test", "runtests.jl"), String)

        @test contains(setup_text, "using RabbitRpcServer")
        @test !contains(setup_text, "using ia-pkg-julia-rpc")
        @test contains(runtests_text, "@testset verbose=true \"RabbitRpcServer tests\"")
    end
end
