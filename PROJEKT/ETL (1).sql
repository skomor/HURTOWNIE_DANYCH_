use Coronavirus;
GO

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

alter table tmp
add dynamika_zakazen float;
GO

update tmp
set dynamika_zakazen=0
from tmp;
GO

create table tmp2 (id_czas date, kraj varchar(255), liczba_zakazen bigint, liczba_zgonow bigint, wyzdrowiali bigint, nowe_przypadki bigint, dynamika_zakazen float);
insert into tmp2
select *
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


insert into STATYSTYKI_FACT
select tmp.id, tmp.id_czas, tmp.kraj, tmp.liczba_zakazen, tmp.liczba_zgonow, tmp.wyzdrowiali, tmp.nowe_przypadki, tmp.aktywne_przypadki, tmp.dynamika_zakazen
from tmp
left join STATYSTYKI_FACT
on tmp.id = STATYSTYKI_FACT.id_statystyki
where STATYSTYKI_FACT.id_statystyki is null;
GO

drop table tmp2;
GO

drop table tmp;
GO
