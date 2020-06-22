--SET NOCOUNT ON
--TRUNCATE TABLE [Coronavirus].[dbo].[CZAS_DIM]
--DELETE FROM [Coronavirus].[dbo].[STATYSTYKI_FACT]
--DBCC CHECKIDENT ('Coronavirus.dbo.STATYSTYKI_FACT',RESEED, 0)
use Coronavirus;
DECLARE @CurrentDate DATE = '2020-01-01'
DECLARE @EndDate DATE = '2020-12-31'

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO [Coronavirus].[dbo].[CZAS_DIM] (
      [id_czas],
	  [data],
      [dzien],
      [miesiac_nazwa],
	  [miesiac],
      [rok]
      )
   SELECT [id_czas] = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
	  [data] = @CurrentDate,
      [dzien] = DAY(@CurrentDate),
	  [miesiac_nazwa] = DATENAME(mm, @CurrentDate),
      [miesiac] = MONTH(@CurrentDate),
      [rok] = YEAR(@CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END
