# Trying to append dataframe and save it as matfile
using DataFrames
using Dates
using MAT
using FileTools, DataFrameTools
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

## ^^^^^^^^^Above code is the same as those in data_report.jl^^^^^^^^^^ 
function MAT.matopen(fname::AbstractString, mode::AbstractString; compress::Bool = false)
    mode == "r"  ? matopen(fname, true , false, false, false, false, false)    :
    mode == "r+" ? matopen(fname, true , true , false, false, false, compress) :
    mode == "w"  ? matopen(fname, false, true , true , true , false, compress) :
    mode == "w+" ? matopen(fname, true , true , true , true , false, compress) :
    mode == "a"  ? matopen(fname, false, true , true , false, true, compress)  :
    mode == "a+" ? matopen(fname, true , true , true , false, true, compress)  :
    throw(ArgumentError("invalid open mode: $mode"))
end




df3 = filter(:date => x -> (Date(2017,10,1) > x > Date(2010,9,30)) ,df2)
gd_stn = groupby(df3, [:station])
targetfolder = raw"D:\GeoMag (main)\GeoMag4HMM"
extrema(df3.date) # (Date("2010-10-01"), Date("2017-09-30"))
for df_i in gd_stn
    stnm = df_i.station[1]
    fname = "D_$(stnm)_ti1.mat"
    fpath = joinpath(targetfolder, fname);
    if isfile(fpath)
        continue
    end
    sort!(df_i, :date)
    try 
        target = matopen(fpath, "w"; compress=true)
        df000 = DataFrame();
        for path in df_i.fullpath
            file = matopen(path)
            M = read(file, "M")
            close(file)
            dfm = DataFrame(M[:,1:7], 
                    [:year, :month,:day,:hour,:minute,:second,:data])
            
            filter!(AsTable(:) => (nt -> isgeomagdatavalid(nt)) , dfm)

            select!(dfm, 
            [:year, :month,:day,:hour,:minute,:second] => ByRow((yyyy,mm,dd,hh,MM,ss) -> toordinal(yyyy,mm,dd,hh,MM,ss)) => :ordinaldate, :data)

            append!(df000, dfm)


            
        end
        write(target, "M", Matrix(dfm2))
        close(target)
    catch e
        rm(fpath);
        @warn "Error occurred while loading $path, writing to $fpath. $fpath has been deleted."
        rethrow(e)
    end
end


