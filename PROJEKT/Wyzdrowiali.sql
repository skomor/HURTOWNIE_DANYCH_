use Coronavirus;
GO

create table tmp (id varchar(255), id_czas varchar(255), kraj varchar(255), liczba_zakazen varchar(255), liczba_zgonow varchar(255), nowe_przypadki varchar(255), wyzdrowiali varchar(255), aktywne_przypadki varchar(255));
GO

alter table FILE_CORONA_STAGE
add id varchar(255) default '0';
GO

update FILE_CORONA_STAGE
set id = concat(date, country_or_region);
GO

alter table FILE_CORONA_REC_STAGE
add id varchar(255) default '0';
GO

update FILE_CORONA_REC_STAGE
set id = concat(date, country);
GO

insert into tmp (id, id_czas, kraj, liczba_zakazen, liczba_zgonow, nowe_przypadki)
select id, date, country_or_region, running_total_cases, running_total_deaths, daily_new_cases 
from FILE_CORONA_STAGE;
GO

create table tmp2 (id varchar(255), id_czas varchar(255), kraj varchar(255), liczba_zakazen varchar(255), liczba_zgonow varchar(255), nowe_przypadki varchar(255), wyzdrowiali varchar(255), aktywne_przypadki varchar(255));
GO

insert into tmp2 (id, id_czas, kraj, liczba_zakazen, liczba_zgonow, nowe_przypadki, wyzdrowiali)
select tmp.id, tmp.id_czas, tmp.kraj, tmp.liczba_zakazen, tmp.liczba_zgonow, tmp.nowe_przypadki, recovered 
from FILE_CORONA_REC_STAGE inner join tmp
on tmp.id = FILE_CORONA_REC_STAGE.id;
GO

alter table tmp2
alter column liczba_zakazen bigint;
alter table tmp2
alter column liczba_zgonow bigint;
alter table tmp2
alter column nowe_przypadki float;
alter table tmp2
alter column nowe_przypadki bigint;
alter table tmp2
alter column wyzdrowiali bigint;
alter table tmp2
alter column aktywne_przypadki bigint;
GO

create table tmp3 (id varchar(255), id_czas varchar(255), kraj varchar(255), liczba_zakazen bigint, liczba_zgonow bigint, nowe_przypadki bigint, wyzdrowiali bigint, aktywne_przypadki bigint);
GO

insert into tmp3 (id, id_czas, kraj, liczba_zakazen, liczba_zgonow, nowe_przypadki, wyzdrowiali, aktywne_przypadki)
select id, id_czas, kraj, liczba_zakazen, liczba_zgonow, nowe_przypadki, wyzdrowiali, (liczba_zakazen - liczba_zgonow) - wyzdrowiali
from tmp2;
GO

insert into STATYSTYKI_FACT
select tmp3.id, tmp3.id_czas, tmp3.kraj, tmp3.liczba_zakazen, tmp3.liczba_zgonow, tmp3.nowe_przypadki, tmp3.wyzdrowiali, tmp3.aktywne_przypadki
from tmp3
left join STATYSTYKI_FACT
on tmp3.id = STATYSTYKI_FACT.id_statystyki
where STATYSTYKI_FACT.id_statystyki is null;
GO

drop table tmp;
drop table tmp2;
drop table tmp3;
GO
