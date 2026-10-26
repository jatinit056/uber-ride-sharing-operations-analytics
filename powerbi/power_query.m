// =====================================================================
// Power Query (M) of powerbi/Uber_NYC.pbix — one block per query.
// DataFolder is a text parameter: the folder that holds the cleaned CSVs (must end with \).
// =====================================================================

// ---------- Parameter: DataFolder ----------
"<path to this project>\data\cleaned\" meta [IsParameterQuery = true, Type = "Text", IsParameterQueryRequired = true]

// ---------- Query: fact_daily ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "trips_daily.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"date", type date}, {"period", type text}, {"trips", Int64.Type}, {"year", Int64.Type}, {"month", type text}, {"weekday", type text}, {"is_weekend", type logical}, {"is_holiday", type logical}, {"partial_day", type logical}}, "en-US")
in
    Typed

// ---------- Query: fact_hourly ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "trips_hourly.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"date", type date}, {"hour", Int64.Type}, {"trips", Int64.Type}, {"period", type text}, {"year", Int64.Type}, {"month", type text}, {"weekday", type text}, {"is_weekend", type logical}, {"is_holiday", type logical}, {"time_band", type text}}, "en-US"),
    Step1 = Table.AddColumn(Typed, "day_type", each if [is_weekend] then "Weekend" else "Weekday", type text),
    Step2 = Table.AddColumn(Step1, "weekday_no", each List.PositionOf({"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}, [weekday]) + 1, Int64.Type)
in
    Step2

// ---------- Query: fact_base_daily ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "trips_daily_base.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"date", type date}, {"base_code", type text}, {"base_name", type text}, {"trips", Int64.Type}}, "en-US")
in
    Typed

// ---------- Query: fact_zone_daily ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "trips_zone_daily_2015.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"date", type date}, {"location_id", Int64.Type}, {"trips", Int64.Type}}, "en-US")
in
    Typed

// ---------- Query: fact_area_hourly ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "trips_area_hourly_2015.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"date", type date}, {"hour", Int64.Type}, {"service_area", type text}, {"trips", Int64.Type}}, "en-US")
in
    Typed

// ---------- Query: fact_foil ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "foil_daily_base.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"date", type date}, {"base_code", type text}, {"base_name", type text}, {"active_vehicles", Int64.Type}, {"trips", Int64.Type}, {"trips_per_vehicle", type number}}, "en-US")
in
    Typed

// ---------- Query: fact_market ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "market_daily_2014.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"date", type date}, {"company", type text}, {"trips", Int64.Type}}, "en-US")
in
    Typed

// ---------- Query: dim_zone ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "dim_zone.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"location_id", Int64.Type}, {"borough", type text}, {"zone", type text}, {"is_airport", type logical}, {"service_area", type text}}, "en-US")
in
    Typed

// ---------- Query: dim_base ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "dim_base.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"base_code", type text}, {"base_name", type text}}, "en-US")
in
    Typed

// ---------- Query: Date ----------
let
    StartDate = #date(2014, 4, 1),
    EndDate = #date(2015, 6, 30),
    Dates = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    AsTable = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),
    Typed = Table.TransformColumnTypes(AsTable, {{"Date", type date}}),
    AddYear = Table.AddColumn(Typed, "Year", each Date.Year([Date]), Int64.Type),
    AddMonthNo = Table.AddColumn(AddYear, "Month Number", each Date.Month([Date]), Int64.Type),
    AddMonthStart = Table.AddColumn(AddMonthNo, "Month Start", each Date.StartOfMonth([Date]), type date),
    AddMonth = Table.AddColumn(AddMonthStart, "Month", each Date.ToText([Date], "MMM yyyy", "en-US"), type text),
    AddMonthName = Table.AddColumn(AddMonth, "Month Name", each Date.ToText([Date], "MMM", "en-US"), type text),
    AddWeekdayNo = Table.AddColumn(AddMonthName, "Weekday Number", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    AddWeekday = Table.AddColumn(AddWeekdayNo, "Weekday", each Date.ToText([Date], "ddd", "en-US"), type text),
    AddDayType = Table.AddColumn(AddWeekday, "Day Type", each if Date.DayOfWeek([Date], Day.Monday) >= 5 then "Weekend" else "Weekday", type text),
    AddPeriod = Table.AddColumn(AddDayType, "Period", each if Date.Year([Date]) = 2014 then "2014 Apr-Sep" else "2015 Jan-Jun", type text)
in
    AddPeriod
