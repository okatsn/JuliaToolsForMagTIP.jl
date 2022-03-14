@testset "datenum.jl" begin
    using Dates
    # see https://gist.github.com/RobBlackwell/913b129d8d91e72e9879b20cb38fd529
    MATLAB_EPOCH = Dates.DateTime(-0001,12,31)

    """
         datenum(d::Dates.DateTime)
    Converts a Julia DateTime to a MATLAB style DateNumber.
    MATLAB represents time as DateNumber, a double precision floating
    point number being the the number of days since January 0, 0000
    Example
        datenum(now())
    """
    function datenum_RobBlackwell(d::Dates.DateTime)
        Dates.value(d - MATLAB_EPOCH) /(1000 * 60 * 60 * 24)
    end
    dt = DateTime(2006,11,14,9,15,37);
    @test isequal(datenum(dt), datenum_RobBlackwell(dt))
    dt = DateTime(2033,5,1,23,59,59);
    @test isequal(datenum(dt), datenum_RobBlackwell(dt))
    dt = DateTime(1,2,28,0,13,59);
    @test isequal(datenum(dt), datenum_RobBlackwell(dt))
    dt = DateTime(1999,12,31,23,59,59);
    @test isequal(datenum(dt), datenum_RobBlackwell(dt))
    @test isequal(toordinal(1970,1,1), 719163);
end