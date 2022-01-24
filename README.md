# WECOrules.jl

A Julia package that implements the Western Electric Company's eight rules for detecting process change. In statistical quality control, these rules are often used along with control charts to determine whether an industrial process remains nominally within process control limits.  Failures are deemed to be reasons to investigate and resolve potential problems with the industrial process.

## The Eight Rules

A process is deemed out-of-control if:

  1) A single data point more than three standard deviations from the nominal value.
  2) Nine sequential data points above (or below) the nominal value.
  3) Six sequential data points monotonically increasing (decreasing).
  4) Sixteen sequential data points alternating up and down.
  5) Two of three data points above (or below) that are over two standard deviations from the nominal value.
  6) Four of five data points above (or below) that are more than one standard deviation from the nominal value.
  7) Fifteen data points within one standard deviaiton of the nominal value.
  8) Eight sequential data points that are more than one standard deviation from the nominal value. 

  where the nominal value is the value deemed optimal for a measured property of the process.  One standard deviation is determined from prior observations of the process.

    weco(
      df::DataFrame, 
      nominal::Real, 
      onesigma::Real; 
      timestamp=:Date, 
      value=:Value, 
      result::Union{Missing,Function}=missing
    )::DataFrame

  * The package takes a `DataFrames` package `DataFrame` containing time-sequence data.
  * The `nominal` and `onesigma` values are specified.
  * The `timestamp` data is by default in the `:Date` column
  * The `value` data is by default in the `:Value` column
  * The `result` argument can be a function that can compute an optional 9th column with a go/no go decision based on the previous eight rule columns.  The function takes a `DataFrame` row argument and can be based on any data in `df` or the `:Rule?` columns.  The default result function returns true if all the rules evaluate true or missing and false otherwise.

Example result function:

    mot(v) = ismissing(v) || v
    allrules(r) = all(mot.((r[:Rule1], r[:Rule2], r[:Rule3], r[:Rule4], r[:Rule5], r[:Rule6], r[:Rule7], r[:Rule8])))


 The method creates a new `DataFrame` with eight additional `Union{Boolean,Missing}` columns - one for each of the tests called `:Rule1`, `:Rule2`, ..., `:Rule8`.  The columns contain `true` if the data point in the row datum is "in control" according to the rule and `false` if the row is "out-of-control" according to the rule.  If there is a reason that the rule can't be evaluated then the value will be `missing`.

If Gadfly has been imported then the method `shewhart(...)` will plot a Shewhart-like control chart.

    shewhart(
      df::AbstractDataFrame, # DataFrame containing columns :Date & :Value (or below)
      nominal::Real, # Nominal value for :Value column
      onesigma::Real; # Nominal 1σ variation in :Value column
      timestamp::Union{Symbol,AbstractString}=:Date, # Alternative to :Date
      value::Union{Symbol,AbstractString}=:Value, # Alternative to :Value
      result::Union{Missing,Function}=missing
    )

The plot method first calls `weco(df,...)` to apply the rules.  It plots "passing" data points in green, "failing" in red according to the `result` function.  It also plots yellow horizontal lines at the nominal±2σ level and red horizontal lines at the nominal±3σ levels.
