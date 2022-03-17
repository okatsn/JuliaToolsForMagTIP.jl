@testset "isgeomagdatavalid.jl" begin
    nms = (:year, :month, :day, :hour, :minute, :second, :data)
    @test !isgeomagdatavalid(NamedTuple{nms}([2022, 12, 12, 3, 51, 46, 99999.99]))
    @test !isgeomagdatavalid(NamedTuple{nms}([2022, 6, 31, 3, 51, 46, 99.23]))
    @test isgeomagdatavalid(NamedTuple{nms}([2022, 1, 29, 23, 59, 32, 99.23]))
    @test !isgeomagdatavalid(NamedTuple{nms}([2022, 1, 29, 23, 59, 32, 100000]))
end