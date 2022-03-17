"""
`isgeomagdatavalid(nt::NamedTuple)` returns `true` if `DateTime(nt.year, nt.month, nt.day, nt.hour, nt.minute, nt.second)` won't raise an error, and `nt.data` is not `99999.99` or `100000.0` (by `isapporx`).

Also refer to `qualitycontrol()` in `src/statind.m`.

"""
function isgeomagdatavalid(nt::NamedTuple)
    return chkdatetime(nt.year, nt.month, nt.day, nt.hour, nt.minute, nt.second) && 
    !isapprox(nt.data, 99999.99) && !isapprox(nt.data, 100000.0)
end