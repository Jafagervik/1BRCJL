using CSV
using DataFrames
using Statistics: mean

function process_data(filepath::String; limit::Int=30)
    df = DataFrame(
        CSV.File(
            filepath;
            delim=';',
            header=["city", "temp"],
            ignoreemptyrows=true,
            skipto=3,
            types=[String, Float32],
        ),
    )

    summary_stats(x) = (min_temp=minimum(x), max_temp=maximum(x), avg_temp=mean(x))

    return combine(groupby(df, :city), :temp => summary_stats => [:min, :max, :avg])
end

function print_stats(stats_df::DataFrame)
    for city_stat in eachrow(stats_df)
        println(
            "$(city_stat[:city]);$(city_stat[:min]);$(city_stat[:max]);$(city_stat[:avg])"
        )
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    filepath = !isempty(ARGS) ? "weather_stations.csv" : ARGS[1]
    @time print_stats(process_data(filepath))
end
