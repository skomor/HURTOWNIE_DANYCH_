UPDATE       FILE_CORONA_REC_STAGE
SET                country = 'South Korea', 
					confirmed =  recovered ,
						recovered = left(deaths, charindex(',', deaths) - 1) ,
						deaths = RIGHT(deaths,LEN(deaths) - CHARINDEX(',',deaths)-1)


WHERE        (country = '"Korea')
;
UPDATE       FILE_CORONA_REC_STAGE
SET deaths=0
where deaths = '';



use Coronavirus
delete from FILE_CORONA_REC_STAGE



;