@testset "gettag.jl" begin
    strvec = [
        "stn[CS]dt[20140325]type[full].mat",
        "stn[CS]dt[20140328]type[full].mat",
        "stn[CS]dt[20140327]type[full].mat",
        "stn[CS]dt[20140329]type[full].mat",
        "stn[CS]dt[20140330]type[full].mat",
        "stn[CS]dt[20140326]type[full].mat",
        "stn[TT]dt[20200716]type[full].mat",
        "stn[TT]dt[20200717]type[full].mat",
        "stn[TT]dt[20200718]type[full].mat",
        "stn[TT]dt[20200719]type[full].mat",
        "stn[TT]dt[20200720]type[full].mat"]
    dtstr = broadcast(x -> x.match, match.(r"(?<=dt\[)\d+?(?=\])", strvec))
    dtstr2 = gettag.("dt", strvec)
    @test isequal(dtstr, dtstr2)
    @test "TSUG" == gettag("stn","[Hello]stn[TSUG]dt[20220105].mat")
    @test "TS_U465-G" == gettag("stn","[Hello]stn[TS_U465-G]dt[20220105].mat")
end