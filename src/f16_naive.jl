"""
    Extremely naive implementation of the 1BRC task.

Credit: https://www.youtube.com/watch?v=utTaPW32gKY
"""
function process_data(filepath::String)
    stats = Dict{String,Dict{String,Float16}}()

    open(filepath) do f
        for row in eachline(f)
            city, temp_str = split(row, ';')
            temp = parse(Float16, temp_str)

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
    end

    return stats
end

function print_stats(stats::Dict{String,Dict{String,Float16}})
    for (city, city_stats) in stats
        min_temp = city_stats["min"]
        max_temp = city_stats["max"]
        avg_temp = city_stats["sum"] / city_stats["count"]
        println("$city;$min_temp;$max_temp;$avg_temp")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    filepath = !isempty(ARGS) ? "data.txt" : ARGS[1]
    @time process_data(filepath) |> print_stats
end
