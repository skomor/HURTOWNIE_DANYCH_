use Coronavirus;
GO
ALTER TABLE  STATYSTYKI_FACT drop column IF EXISTS IleOdPierwszego;
UPDATE       FILE_CORONA_REC_STAGE
SET                country = 'South Korea', 
					confirmed =  recovered ,
						recovered = left(deaths, charindex(',', deaths) - 1) ,
						deaths = RIGHT(deaths,LEN(deaths) - CHARINDEX(',',deaths))


WHERE        (country = '"Korea')
;

UPDATE       FILE_CORONA_REC_STAGE
SET deaths=0
where deaths = '';

DROP TABLE IF EXISTS tmp;
DROP TABLE IF EXISTS tmp2;

create table tmp (id_czas varchar(255), kraj varchar(255), liczba_zakazen varchar(255), liczba_zgonow varchar(255), wyzdrowiali varchar(255));
GO

insert into tmp (id_czas, kraj, liczba_zakazen, wyzdrowiali, liczba_zgonow)
select * 
from FILE_CORONA_REC_STAGE;
GO

alter table tmp
alter column id_czas date;
alter table tmp
alter column liczba_zakazen bigint;
alter table tmp
alter column wyzdrowiali bigint;
alter table tmp
alter column liczba_zgonow bigint;
GO

alter table tmp
add nowe_przypadki bigint;
GO

alter table tmp
add nowe_wyzdrowienia bigint;
GO

alter table tmp
add nowe_zgony bigint;
GO

update tmp
set tmp.nowe_przypadki=tmp.liczba_zakazen
from tmp;
GO

update tmp
SET tmp.nowe_przypadki=tmp.liczba_zakazen-FILE_CORONA_REC_STAGE.confirmed
FROM FILE_CORONA_REC_STAGE 
WHERE FILE_CORONA_REC_STAGE.country=tmp.kraj 
AND tmp.id_czas=DATEADD(day, 1, FILE_CORONA_REC_STAGE.date);
GO

update tmp
set tmp.nowe_wyzdrowienia=tmp.wyzdrowiali
from tmp;
GO

update tmp
SET tmp.nowe_wyzdrowienia=tmp.wyzdrowiali-FILE_CORONA_REC_STAGE.recovered
FROM FILE_CORONA_REC_STAGE 
WHERE FILE_CORONA_REC_STAGE.country=tmp.kraj 
AND tmp.id_czas=DATEADD(day, 1, FILE_CORONA_REC_STAGE.date);
GO

update tmp
set tmp.nowe_zgony=tmp.liczba_zgonow
from tmp;
GO

update tmp
SET tmp.nowe_zgony=tmp.liczba_zgonow-FILE_CORONA_REC_STAGE.deaths
FROM FILE_CORONA_REC_STAGE 
WHERE FILE_CORONA_REC_STAGE.country=tmp.kraj 
AND tmp.id_czas=DATEADD(day, 1, FILE_CORONA_REC_STAGE.date);
GO

alter table tmp
add dynamika_zakazen float;
GO

update tmp
set dynamika_zakazen=0
from tmp;
GO

create table tmp2 (id_czas date, kraj varchar(255), liczba_zakazen bigint, liczba_zgonow bigint, wyzdrowiali bigint, nowe_przypadki bigint, dynamika_zakazen float);
insert into tmp2
select id_czas, kraj, liczba_zakazen, liczba_zgonow, wyzdrowiali, nowe_przypadki, dynamika_zakazen
from tmp;
GO

alter table tmp
alter column nowe_przypadki float;
GO

alter table tmp2
alter column nowe_przypadki float;
GO

update tmp
SET tmp.dynamika_zakazen=ISNULL(tmp.nowe_przypadki/NULLIF(tmp2.nowe_przypadki,0),tmp.nowe_przypadki)
FROM tmp2 
WHERE tmp.kraj=tmp2.kraj 
AND tmp.id_czas=DATEADD(day, 1, tmp2.id_czas);
GO

alter table tmp
add id varchar(255);
GO

update tmp
SET id = concat(id_czas, kraj);
GO

alter table tmp
add aktywne_przypadki bigint;
GO

update tmp
set aktywne_przypadki = (liczba_zakazen - liczba_zgonow) - wyzdrowiali;
GO

alter table tmp
add dzien_od_pierwszego_zakazenia int;
GO

insert into STATYSTYKI_FACT
select tmp.id, tmp.id_czas, tmp.kraj, tmp.liczba_zakazen, tmp.liczba_zgonow, tmp.wyzdrowiali, tmp.nowe_przypadki, tmp.aktywne_przypadki, tmp.dynamika_zakazen, tmp.nowe_zgony, tmp.nowe_wyzdrowienia, tmp.dzien_od_pierwszego_zakazenia
from tmp
left join STATYSTYKI_FACT
on tmp.id = STATYSTYKI_FACT.id_statystyki
where STATYSTYKI_FACT.id_statystyki is null;
GO

update STATYSTYKI_FACT
SET dzien_od_pierwszego_zakazenia = 1 + DATEDIFF(DAY, b.czasPierwszegoWykrycia,STATYSTYKI_FACT.id_czas) 
from (
select  kraj, min([id_czas]) as czasPierwszegoWykrycia
from  STATYSTYKI_FACT 
where nowe_przypadki <> 0 
Group by kraj 
) as b
where STATYSTYKI_FACT.kraj = b.kraj  ;
GO

update STATYSTYKI_FACT
SET dzien_od_pierwszego_zakazenia = 0
from STATYSTYKI_FACT
where dzien_od_pierwszego_zakazenia < 0;
GO

update STATYSTYKI_FACT
set dynamika_zakazen = 0
from STATYSTYKI_FACT
where dynamika_zakazen < 0;
GO

drop table tmp2;
GO

drop table tmp;
GO
