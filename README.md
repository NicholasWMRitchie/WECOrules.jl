# WECOrules

Implements the Western Electric Company's eight rules for detecting process change.  The rules are used along with control charts to determine whether a process remains under control.

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

    weco(df::DataFrame, nominal::Real, onesigma::Real; timestamp=:Date, value=:Value, result::Union{Missing,Function}=missing)::DataFrame

  * The package takes a `DataFrames` package `DataFrame` containing time-sequence data.
  * The `nominal` and `onesigma` values are specified.
  * The `timestamp` data is by default in the `:Date` column
  * The `value` data is by default in the `:Value` column
  * The `result` argument can be a function that can compute an optional 9th column with a go/no go decision based on the previous eight rule columns.  The function takes a `DataFrame` row argument and can be based on any data in `df` or the `:Rule?` columns.

 The method creates a new `DataFrame` with eight additional `Union{Boolean,Missing}` columns - one for each of the tests called `:Rule1`, `:Rule2`, ..., `:Rule8`.  The columns contain `true` if the data point in the row datum is "in control" according to the rule and `false` if the row is "out-of-control" according to the rule.  If there is a reason, the rule can't be evaluated then the value will be `missing`.

 