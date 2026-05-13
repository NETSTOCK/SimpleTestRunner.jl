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
        @test contains(runtests_text, "if isfile(test_project) && active_project !== nothing && abspath(active_project) == parent_project")
        @test contains(runtests_text, "Pkg.activate(@__DIR__)")
        @test contains(runtests_text, "@testset verbose=true")
        @test contains(runtests_text, "include(\"setup.jl\")")
        @test contains(runtests_text, "runtests()")
    end
end
