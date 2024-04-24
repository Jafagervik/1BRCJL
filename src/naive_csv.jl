using CSV

function process_data(filepath::String)
    stats = Dict{String,Dict{String,Float32}}()

    csv_reader = CSV.File(
        filepath;
        delim=';',
        header=["city", "temp"],
        ignoreemptyrows=true,
        skipto=3,
        types=[String, Float32],
    )

    for (city, temp) in csv_reader
        if haskey(stats, city)
            city_stats = stats[city]
            # ifelse is faster than min/max
            city_stats["min"] = ifelse(temp < city_stats["min"], temp, city_stats["min"])
            city_stats["max"] = ifelse(temp > city_stats["max"], temp, city_stats["max"])
            city_stats["sum"] += temp
            city_stats["count"] += 1
        else
            stats[city] = Dict("min" => temp, "max" => temp, "sum" => temp, "count" => 1)
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
