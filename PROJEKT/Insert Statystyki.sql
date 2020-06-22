use Coronavirus
insert into STATYSTYKI_FACT(id_czas, kraj, liczba_zakazen, liczba_zgonow, nowe_przypadki)
select date, country_or_region, running_total_cases, running_total_deaths, daily_new_cases 
from FILE_CORONA_STAGE;