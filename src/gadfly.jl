using Gadfly

function shewhart(
    df::AbstractDataFrame, # DataFrame containing columns :Date & :Value (or below)
    nominal::Real, # Nominal value for :Value column
    onesigma::Real; # Nominal 1σ variation in :Value column
    timestamp::Union{Symbol,AbstractString}=:Date, # Alternative to :Date
    value::Union{Symbol,AbstractString}=:Value, # Alternative to :Value
    result::Union{Missing,Function}=missing
)
    res = weco(df,nominal,onesigma,timestamp=timestamp, value=value, result=result)
    ranges = DataFrame(
        :ymax => ( 3*onesigma, 2*onesigma, 1*onesigma, -1*onesigma, -2*onesigma ), 
        :ymin => ( 2*onesigma, 1*onesigma, -1*onesigma, -2*onesigma, -3*onesigma ),
        :color => ( "pink", "khaki1", "lightgreen", "khaki1", "pink")
    )
    #Geom.hline[(; color=nothing, size=nothing, style=nothing)]
    plot(
        layer(yintercept=[3*onesigma, -3*onesigma].+nominal, Geom.hline(color="red")),
        layer(yintercept=[2*onesigma, -2*onesigma].+nominal, Geom.hline(color="yellow")),
        layer(res, x=timestamp, y=value, color=:Passes, Geom.point),
        Scale.color_discrete_manual("lime", "firebrick", levels = [ true, false ]),
    )
end