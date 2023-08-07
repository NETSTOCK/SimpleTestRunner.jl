@testset "Usage output tests" begin
    args = String["--help"]
    buff = IOBuffer()
    progname = "test/runtests.jl"
    runtests(@__DIR__, args; io=buff, progname=progname)
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
            runtests("test", String[]; progname="test/runtests.jl")
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
            runtests("test", ["foo", "baz"]; progname="test/runtests.jl")
            @test isfile("foo_ran.txt")
            @test !isfile("bar_ran.txt")
            @test isfile("baz_ran.txt")
        end
    end
end
