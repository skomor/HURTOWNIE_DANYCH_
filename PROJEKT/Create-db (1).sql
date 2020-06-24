create database Coronavirus;

use Coronavirus;

create table CZAS_DIM (
id_czas int,
data varchar(255) not null primary key,
dzien int,
miesiac_nazwa varchar(255),
miesiac int,
rok int
);
GO

create table GEOGRAFIA_DIM (
kontynent varchar(255),
kraj varchar(255) not null primary key,
populacja varchar(255),
pkb varchar(255)
);
GO

create table STATYSTYKI_FACT (
id_statystyki varchar(255) not null primary key,
id_czas varchar(255) foreign key references CZAS_DIM(data),
kraj varchar(255) foreign key references GEOGRAFIA_DIM(kraj),
liczba_zakazen bigint,
liczba_zgonow bigint,
wyzdrowiali bigint,
nowe_przypadki bigint,
aktywne_przypadki bigint,
dynamika_zakazen float
);
GO

--create table FILE_CORONA_STAGE (
--date varchar(255),
--country_or_region varchar(255),
--daily_new_cases varchar(255),
--running_total_cases varchar(255),
--running_total_cases_prev_day varchar(255),
--daily_new_deaths varchar(255),
--running_total_deaths varchar(255),
--running_total_deaths_prev_day varchar(255),
--data_source varchar(255),
--lat varchar(255),
--long varchar(255),
--first_case_country_rank varchar(255),
--hundred_case_country_rank varchar(255),
--country_code_2 varchar(255),
--country_code_3 varchar(255),
--country_population_2018 varchar(255),
--country_median_age varchar(255),
--country_running_agg varchar(255)
--)

create table FILE_CORONA_REC_STAGE (
date varchar(255),
country varchar(255),
confirmed varchar(255),
recovered varchar(255),
deaths varchar(255)
);
GO

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
END;
GO

--id_czas varchar(255) foreign key references CZAS_DIM(data),
--kraj varchar(255) foreign key references GEOGRAFIA_DIM(kraj),