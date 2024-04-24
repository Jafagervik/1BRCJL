using CSV

function process_data(filepath::String)
    stats = []

    csv_reader = CSV.File(
        filepath;
        delim=';',
        header=["city", "temp"],
        ignoreemptyrows=true,
        skipto=3,
        limit=1_000,
        types=[String, Float32],
    )

    for (city, temp) in csv_reader
        index = findfirst(x -> x[1] == city, stats)
        if index !== nothing
            city_stats = stats[index][2]
            city_stats[1] = min(city_stats[1], temp)
            city_stats[2] = max(city_stats[2], temp)
            city_stats[3] += temp
            city_stats[4] += 1
        else
            push!(stats, (city, [temp, temp, temp, 1]))  # (city, [min, max, sum, count])
        end
    end

    return stats
end

function print_stats(stats)
    for (city, city_stats) in stats
        min_temp = city_stats[1]
        max_temp = city_stats[2]
        avg_temp = city_stats[3] / city_stats[4]
        println("$city;$min_temp;$max_temp;$avg_temp")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    filepath = !isempty(ARGS) ? "weather_stations.csv" : ARGS[1]
    @time print_stats(process_data(filepath))
end
