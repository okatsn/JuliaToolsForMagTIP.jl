"""
`datenum(d::Dates.DateTime)` converts a Julia DateTime to a MATLAB style DateNumber. Also see: `toordinal`
"""
function datenum(dt::DateTime)
    dnum = Dates.datetime2epochms(dt)/(1000*60*60*24) + 1
    return dnum
end

"""
`datenum(v...)` does `datenum(DateTime(v...))`.
"""
function datenum(v...)
    dt = DateTime(v...)
    return datenum(dt)
end

"""
`toordinal(dt::DateTime)`converts a Julia DateTime to a python style DateNumber. Also see `datenum`.
"""
function toordinal(dt::DateTime)
    return datenum(dt) - 366
end

"""
`toordinal(v...)` does `toordinal(DateTime(v...))`.
"""
function toordinal(v...)
    dt = DateTime(v...)
    return toordinal(dt)
end

"""
`chkdatetime(v...)` use `try ... catch ...` to check if a vector `[yyyy, mm, dd, hh, MM, ss]` is a valid datetime. 
"""
function chkdatetime(v...)
    dtisvalid = true
    try
        DateTime(v...)
    catch
        dtisvalid = false
    end
    return dtisvalid
end
