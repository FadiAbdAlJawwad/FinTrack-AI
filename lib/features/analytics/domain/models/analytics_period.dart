/// Time period over which analytics are computed.
///
/// Note: [year] represents the "last 12 months" rolling period from the current
/// date, rather than a fixed calendar year (e.g. 2026-01-01 to 2026-12-31).
enum AnalyticsPeriod { week, month, year }
