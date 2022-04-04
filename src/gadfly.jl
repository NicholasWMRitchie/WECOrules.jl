using .Gadfly


"""
    shewhart(
        df::AbstractDataFrame, # DataFrame containing columns :Date & :Value (or below)
        nominal::Real, # Nominal value for :Value column
        onesigma::Real; # Nominal 1σ variation in :Value column
        timestamp::Union{Symbol,AbstractString}=:Date, # Alternative to :Date
        value::Union{Symbol,AbstractString}=:Value, # Alternative to :Value
        result::Union{Missing,Function}=missing,
        color::Bool=true # Use only color vs only black and white
    )

Plot a Shewhart-style control chart from the data in `df`.  The `DataFrame` is evaluated using
the `weco(...)` function to compute the WECO rules based on the specified `nominal` (mean value)
and `onesigma` (standard-deviation).

`color` controls whether the data is plotted in colors (green=>meets, red=>fails, red line=>3σ, yellow line=>2σ)
or black-and-white (white fill=>meets, black fill=>fails, long dashed gray line=>3σ, short dash gray line=>2σ)
"""
function shewhart(
    df::AbstractDataFrame, # DataFrame containing columns :Date & :Value (or below)
    nominal::Real, # Nominal value for :Value column
    onesigma::Real; # Nominal 1σ variation in :Value column
    timestamp::Union{Symbol,AbstractString}=:Date, # Alternative to :Date
    value::Union{Symbol,AbstractString}=:Value, # Alternative to :Value
    result::Union{Missing,Function}=missing,
    color::Bool=true, # Use colors vs only black and white
    title::Union{AbstractString,Nothing}=nothing,
)
    df = sort(df, timestamp)
    res = weco(df, nominal, onesigma, timestamp=timestamp, value=value, result=result)
    gt = isnothing(title) ? [] : [ Guide.title(title) ]
    if color
        plot(
            layer(yintercept=[3*onesigma, -3*onesigma].+nominal, Geom.hline(color="red")),
            layer(yintercept=[2*onesigma, -2*onesigma].+nominal, Geom.hline(color="yellow")),
            layer(res, x=timestamp, y=value, color=:Passes, Geom.point),
            Scale.color_discrete_manual("lime", "firebrick", levels = [ true, false ]), gt...
        )
    else
        plot(
            layer(yintercept=[3*onesigma, -3*onesigma].+nominal, Geom.hline(color="gray50", style=:dash)),
            layer(yintercept=[2*onesigma, -2*onesigma].+nominal, Geom.hline(color="gray50", style=:dot)),
            layer(res, x=timestamp, y=value, color=:Passes, Geom.point, Theme(discrete_highlight_color=c->"gray50")),
            Scale.color_discrete_manual("gray80", "black", levels = [ true, false ]), gt...
        )
    end
end