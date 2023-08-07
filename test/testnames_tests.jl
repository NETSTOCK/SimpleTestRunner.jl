@testset "Enumeration tests" begin
    mktempdir() do dir
        cd(dir) do
            mkdir("test")
            cd("test") do
                map(touch, ["README.md", "runtests.jl", "setup.jl", "foo_tests.jl", "bar_tests.jl", "baz_tests.jl"])
                mkdir("child")
                cd("child") do
                    map(touch, ["NOTES.md", "alice_tests.jl", "bob_tests.jl"])
                    mkdir("grandchild")
                    cd("grandchild") do
                        map(touch, ["wrong_suffix_test.jl", "carol_tests.jl", "carol_tests.jl.bak"])
                    end
                end
            end

            names = testnames("test")
            expected_names = ["foo", "bar", "baz", "child/alice", "child/bob", "child/grandchild/carol"]
            for expected in expected_names
                @test expected in names
            end
            @test length(expected_names) == length(names)
        end
    end
end
