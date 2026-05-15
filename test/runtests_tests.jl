@testset "Usage output tests" begin
    args = String["--help"]
    buff = IOBuffer()
    progname = joinpath("test", "runtests.jl")
    runtests(args; io=buff, progname=progname)
    output = String(take!(buff))
    @test contains(output, progname)
end

@testset "default args tests" begin
    mktempdir() do dir
        cd(dir) do
            mkdir("test")
            cd("test") do
                map(["foo", "bar", "baz"]) do test
                    write("$(test)_tests.jl", """touch("$(test)_ran.txt")""")
                end
            end
	    runtests(String[]; progname=joinpath("test", "runtests.jl"))
            @test isfile("foo_ran.txt")
            @test isfile("bar_ran.txt")
            @test isfile("baz_ran.txt")
        end
    end
end

@testset "specified args tests" begin
    mktempdir() do dir
        cd(dir) do
            mkdir("test")
            cd("test") do
                map(["foo", "bar", "baz"]) do test
                    write("$(test)_tests.jl", """touch("$(test)_ran.txt")""")
                end
            end
	    runtests(["foo", "baz"]; progname=joinpath("test", "runtests.jl"))
            @test isfile("foo_ran.txt")
            @test !isfile("bar_ran.txt")
            @test isfile("baz_ran.txt")
        end
    end
end

@testset "filename args tests" begin
    mktempdir() do dir
        cd(dir) do
            mkdir("test")
            cd("test") do
                mkpath("child")
                write("foo_tests.jl", """touch(\"foo_ran.txt\")""")
                write(joinpath("child", "bar_tests.jl"), """touch(\"bar_ran.txt\")""")
            end
            runtests(["foo_tests.jl", joinpath("child", "bar_tests.jl")]; progname=joinpath("test", "runtests.jl"))
            @test isfile("foo_ran.txt")
            @test isfile("bar_ran.txt")
        end
    end
end

@testset "test-dir-prefixed args tests" begin
    mktempdir() do dir
        cd(dir) do
            mkdir("test")
            cd("test") do
                mkpath("child")
                write("foo_tests.jl", """touch(\"foo_ran.txt\")""")
                write(joinpath("child", "bar_tests.jl"), """touch(\"bar_ran.txt\")""")
            end

            runtests([joinpath("test", "foo"), joinpath("test", "child", "bar_tests.jl")]; progname=joinpath("test", "runtests.jl"))
            @test isfile("foo_ran.txt")
            @test isfile("bar_ran.txt")
        end
    end
end

@testset "filename label tests" begin
    @test SimpleTestRunner.testfile("foo") == "foo_tests.jl"
    @test SimpleTestRunner.testfile(joinpath("child", "bar")) == joinpath("child", "bar_tests.jl")
    @test SimpleTestRunner.testfile("foo_tests.jl") == "foo_tests.jl"

    @test SimpleTestRunner.testlabel("foo") == "foo"
    @test SimpleTestRunner.testlabel(joinpath("child", "bar")) == joinpath("child", "bar")
    @test SimpleTestRunner.testlabel("foo_tests.jl") == "foo"
    @test SimpleTestRunner.testlabel(joinpath("child", "bar_tests.jl")) == joinpath("child", "bar")
end
