using WECOrules
using Test
using DataFrames, CSV, Dates

@testset "WECOrules.jl" begin
    test = CSV.read(joinpath(@__DIR__,"tests.csv"),DataFrame)

    res = WECOrules.weco(test[:,[:Date, :Value]], 10.0, 1.0)
    display(res[1:5,:])
    display(res[6:10,:])
    # CSV.write(joinpath(@__DIR__,"result.csv"), res)

    @test all(test[:,:Rule1].==res[:,:Rule1])

    @test all(ismissing.(res[1:8,:Rule2]))
    @test all(test[9:end,:Rule2].==res[9:end,:Rule2])
    
    @test all(ismissing.(res[1:6,:Rule3]))
    @test all(test[7:170,:Rule3] .== res[7:170, :Rule3])

    for ri in 170:nrow(test)
        @show ri, test[ri,:Rule3], res[ri, :Rule3]
        @test test[ri,:Rule3] == res[ri, :Rule3]
    end
    #@test all(test[7:end,:Rule3].==res[7:end,:Rule3])

    @test all(ismissing.(res[1:15,:Rule4]))
    @test all(test[16:end,:Rule4] .== res[16:end, :Rule4])

    @test all(ismissing.(res[1:2,:Rule5]))
    @test all(test[3:end,:Rule5].==res[3:end,:Rule5])

    @test all(ismissing.(res[1:4,:Rule6]))
    @test all(test[5:end,:Rule6].==res[5:end,:Rule6])

    @test all(ismissing.(res[1:14,:Rule7]))
    @test all(test[15:end,:Rule7].==res[15:end,:Rule7])

    @test all(ismissing.(res[1:7,:Rule8]))
    @test all(test[8:end,:Rule8].==res[8:end,:Rule8])
end
