using DataFrames
using Dates
using Gadfly
# using VegaLite
using FileTools, DataFrameTools
using Colors, ColorSchemes

using MAT
using CSV

using Revise
using JuliaToolsForMagTIP
dir = raw"D:\GeoMag (main)\GeoMag_1"
allpaths = filelistall(r"\.mat",dir);
dtstr = gettag.("dt", allpaths)
dt = Date.(dtstr, dateformat"yyyymmdd")
stn = gettag.("stn", allpaths)
typ = gettag.("type", allpaths)

df = DataFrame(:filename => basename.(allpaths), :date => dt, :fullpath=>allpaths, :station=>stn, :color => 1, :type => typ)
filter!(:type => x -> occursin(r"(full|Full)", x), df)


sort!(df, :date)
unique!(df, :filename)

fulldt = df.date[1]:Day(1):df.date[end] |> collect
gd = groupby(df, :station)

dfs = []
for dfi in gd
    fulldf = DataFrame(:date=> fulldt);
    push!(dfs, outerjoin(dfi, fulldf, on=:date))
end

df2 = vcat(dfs...)
dropmissing!(df2, :station)
if !isequal(sort(df2,[:date,:station]), df) 
    error("They should be identical")
end


select!(df2, Not(:color), :color =>ByRow(x -> ismissing(x) ? 0 : 1); renamecols=false)

transform!(df2, :date => ByRow(x -> floor(x, Dates.Month)) => :month)
gd_stnmon = groupby(df2, [:station, :month])
daycount_inmonth_stn = combine(gd_stnmon, nrow => :counts)

rt0t1 = floor.(extrema(fulldt), Dates.Month)

mycs = ColorScheme(range(colorant"white", stop=colorant"lightgreen", length=100)) # range(HSV(0,1,1), stop=HSV(250,1,1), length=100)
# platettef = Scale.lab_gradient(...)

set_default_plot_size(9inch,2.5inch)
p = plot(daycount_inmonth_stn, x=:month, y=:station, color=:counts, 
Geom.rectbin, 
# Coord.cartesian(xmin=rt0t1[1], xmax=rt0t1[2]), # this makes xtick label protrude
Guide.xticks(ticks=DateTime.(collect(rt0t1[1]:Dates.Month(3):rt0t1[2]))), 
# Scale.x_continuous(;minticks=10, maxticks=50), 
Scale.color_continuous(colormap=p->get(mycs, p),minvalue=0, maxvalue=30),
)
# A vector of `Date` needs to be converted to `DateTime` to avoid a conversion error (trying to get the `hour` in Showoff.jl).

# df2 |> 
# @vlplot(
#     :rect, x={:date, bin={maxbins=100}}, y=:station, color=:color,
#     width=400, height=200
# )
 
df3 = filter(:date => x -> (Date(2017,10,1) > x > Date(2010,9,30)) ,df2)
gd_stn = groupby(df3, [:station])
targetfolder = raw"D:\GeoMag (main)\GeoMag4HMM"
extrema(df3.date) # (Date("2010-10-01"), Date("2017-09-30"))
for df_i in gd_stn
    stnm = df_i.station[1]
    fname = "D_$(stnm)_ti1.csv"
    fpath = joinpath(targetfolder, fname);
    if isfile(fpath)
        continue
    end
    sort!(df_i, :date)
    try 
        for path in df_i.fullpath
            file = matopen(path)
            M = read(file, "M")
            dfm = DataFrame(M[:,1:7], 
                    [:year, :month,:day,:hour,:minute,:second,:data])
            
            filter!(AsTable(:) => (nt -> isgeomagdatavalid(nt)) , dfm)

            select!(dfm, 
            [:year, :month,:day,:hour,:minute,:second] => ByRow((yyyy,mm,dd,hh,MM,ss) -> toordinal(yyyy,mm,dd,hh,MM,ss)) => :ordinaldate, :data)

            CSV.write(fpath, dfm; writeheader=false, append=true,compress=true)
            close(file)
        end
    catch e
        rm(fpath);
        @warn "Error occurred while loading $path, writing to $fpath. $fpath has been deleted."
        rethrow(e)
    end
end

