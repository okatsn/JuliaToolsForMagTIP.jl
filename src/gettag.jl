"""
`gettag(tag, str)` obtain the `tag` from `str` that is embraced by `[]`. For example, `gettag("dt", "stn[NC]dt[20210101].mat")`
"""
function gettag(tag, str)
    expr = Regex("(?<=$tag\\[).*?(?=\\])")
    return match(expr, str).match
end
