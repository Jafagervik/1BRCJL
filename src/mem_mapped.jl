using Mmap

function test(filepath::String)
    open(filepath, "r") do f
        sz = Base.stat(f).size
        data = Mmap.mmap(f, Vector{UInt8}, sz)
        idxs = findall(isequal(0x0a), data)
        vecvec = Vector{Vector{UInt8}}()

        for i in eachindex(idxs)
            if i == 1
                push!(vecvec, data[1:(idxs[i] - 1)])
            else
                push!(vecvec, data[(idxs[i - 1] + 1):(idxs[i] - 1)])
            end
        end
        @show idxs
        @show vecvec

        @. println(String(vecvec))
        #println(data)
        return nothing
    end
end

function process_data(filepath::String)
    stats = Dict{String,Dict{String,Float32}}()

    open(filepath, "r") do io
        f = Mmap.mmap(io)
        idxs = findall(isequal(0x0a), f)
        vecvec = Vector{Vector{UInt8}}()

        for i in eachindex(idxs)
            if i == 1
                push!(vecvec, f[1:(idxs[i] - 1)])
            else
                push!(vecvec, f[(idxs[i - 1] + 1):(idxs[i] - 1)])
            end
        end

        for row in vecvec
            city, temp_str = split(row, ';')
            temp = parse(Float32, temp_str)

            if haskey(stats, city)
                city_stats = stats[city]
                city_stats["min"] = ifelse(
                    temp < city_stats["min"], temp, city_stats["min"]
                )
                city_stats["max"] = ifelse(
                    temp > city_stats["max"], temp, city_stats["max"]
                )
                city_stats["sum"] += temp
                city_stats["count"] += 1
            else
                stats[city] = Dict(
                    "min" => temp, "max" => temp, "sum" => temp, "count" => 1
                )
            end
        end
    end

    return stats
end

function print_stats(stats::Dict{String,Dict{String,Float32}})
    for (city, city_stats) in stats
        min_temp = city_stats["min"]
        max_temp = city_stats["max"]
        avg_temp = city_stats["sum"] / city_stats["count"]
        println("$city;$min_temp;$max_temp;$avg_temp")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    filepath = !isempty(ARGS) ? "weather_stations.csv" : ARGS[1]
    @time print_stats(process_data(filepath))
end
