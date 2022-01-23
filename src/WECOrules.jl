module WECOrules

using DataFrames
using Statistics
using DataStructures
using Requires

export weco, shewhart

function __init__()
    # defines the shewhart method to plot the data
    @require Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004" include("gadfly.jl")
end

function weco(
    df::AbstractDataFrame, # DataFrame containing columns :Date & :Value (or below)
    nominal::Real, # Nominal value for :Value column
    onesigma::Real; # Nominal 1σ variation in :Value column
    timestamp::Union{Symbol,AbstractString}=:Date, # Alternative to :Date
    value::Union{Symbol,AbstractString}=:Value, # Alternative to :Value
    result::Union{Missing,Function}=missing
)::DataFrame
    same(cb) = all(cb) || (!any(cb))
    res = sort(df, timestamp)
    # Some of the rules can be computed using stateless methods (only the current value), others require state based on previous values
    # 1) A single data point more than three standard deviations from the nominal value.
    begin
        rule1 = map(r-> abs(r[value]-nominal)<3*onesigma, eachrow(res))
        insertcols!(res, :Rule1 => rule1)
    end
    # 2) Nine sequential data points above (or below) the nominal value.
    begin
        cb2 = CircularBuffer{Bool}(9) # true=above, false=below
        rule2 = map(eachrow(res)) do r
            push!(cb2, r[value] > nominal)
            isfull(cb2) ? !same(cb2) : missing
        end
        insertcols!(res, :Rule2 => rule2)
    end
    # 3) Six sequential data points monotonically increasing (decreasing).
    begin
        cb3, prev = CircularBuffer{Int}(6), missing
        rule3 = map(eachrow(res)) do r
            (!ismissing(prev)) && push!(cb3, r[value] < prev ? -1 : (r[value] > prev ? +1 : 0))
            prev = r[value]
            isfull(cb3) ? !(sum(cb3)==6 || sum(cb3)==-6) : missing
        end
        insertcols!(res, :Rule3 => rule3)
    end
    # 4) Sixteen sequential data points alternating up and down.
    begin
        cb4, prev = CircularBuffer{Bool}(15), missing
        alternating(cb) = all(i->cb[i] ≠ cb[i-1], 2:length(cb))
        rule4 = map(eachrow(res)) do r
            (!ismissing(prev)) && push!(cb4, r[value] - prev > 0)
            prev = r[value]
            isfull(cb4) ? !alternating(cb4) : missing
        end
        insertcols!(res, :Rule4 => rule4)
    end
    # 5) Two of three data points above (or below) that are over two standard deviations from the nominal value.
    begin
        cb5p, cb5n = CircularBuffer{Bool}(3), CircularBuffer{Bool}(3)
        rule5 = map(eachrow(res)) do r
            push!(cb5p, r[value]-nominal > 2*onesigma)
            push!(cb5n, r[value]-nominal < -2*onesigma)
            isfull(cb5p) ? !(count(cb5p) >= 2 || count(cb5n) >= 2) : missing
        end
        insertcols!(res, :Rule5 => rule5)
    end
    # 6) Four of five data points above (or below) that are more than one standard deviation from the nominal value.
    begin
        cb6p, cb6n = CircularBuffer{Bool}(5), CircularBuffer{Bool}(5)
        rule6 = map(eachrow(res)) do r
            push!(cb6p, r[value]-nominal > onesigma)
            push!(cb6n, r[value]-nominal < -onesigma)
            isfull(cb6p) ? !(count(cb6p) >= 4 || count(cb6n) >= 4) : missing
        end
        insertcols!(res, :Rule6 => rule6)
    end
    # 7) Fifteen data points within one standard deviaiton of the nominal value.
    begin
        cb7 = CircularBuffer{Bool}(15)
        rule7 = map(eachrow(res)) do r
            push!(cb7, abs(r[value]-nominal) <= onesigma)
            isfull(cb7) ? !all(cb7) : missing
        end
        insertcols!(res, :Rule7 => rule7)
    end
    # 8) Eight sequential data points that are more than one standard deviation from the nominal value. 
    begin
        cb8 = CircularBuffer{Bool}(8)
        rule8 = map(eachrow(res)) do r
            push!(cb8, abs(r[value]-nominal)>onesigma)
            isfull(cb8) ? !all(cb8) : missing
        end
        insertcols!(res, :Rule8 => rule8)
    end
    mot(v) = ismissing(v) || v
    allrules(r) = all(mot.((r[:Rule1], r[:Rule2], r[:Rule3], r[:Rule4], r[:Rule5], r[:Rule6], r[:Rule7], r[:Rule8])))
    result = ismissing(result) ? allrules : result
    insertcols!(res, :Passes=>map(result, eachrow(res)))
    return res
end

end
