---DimDate Insert
SET NOCOUNT ON
TRUNCATE TABLE [Coronavirus].[dbo].[CZAS_DIM]
DECLARE @CurrentDate DATE = '2020-01-01'
DECLARE @EndDate DATE = '2020-12-31'

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO [Coronavirus].[dbo].[CZAS_DIM] (
      [id_czas],
      [dzien],
      [miesiac_nazwa],
	  [miesiac],
      [rok]
      )
   SELECT [id_czas] = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
      [dzien] = DAY(@CurrentDate),
	  [miesiac_nazwa] = DATENAME(mm, @CurrentDate),
      [miesiac] = MONTH(@CurrentDate),
      [rok] = YEAR(@CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

---FirstDetection Insert
SET NOCOUNT ON
TRUNCATE TABLE [Covid].[DimFirstDetection]
DECLARE @i int = 0

WHILE @i < 10000
BEGIN
	INSERT INTO [Covid].[DimFirstDetection] (
		[DaysFromFirstDetection]
		)
		SELECT [DaysFromFirstDetection] = @i
	SET @i = @i + 1
END