use Coronavirus;
GO

begin
	declare @PatientAmount as int = (select top 1 sum(nowe_przypadki) from STATYSTYKI_FACT);
	declare @StatystykiAmount as int = (select count(id_statystyki) from STATYSTYKI_FACT);
	declare @DateFirst as varchar(255) = (select top 1 data_zachorowania from PACJENT_FACT order by data_zachorowania desc);
	--declare @DateFirst as varchar(255) = '';
	set @DateFirst = case when @DateFirst = '%' then @DateFirst else (select top 1 id_czas from STATYSTYKI_FACT order by id_czas) end;
	print @DateFirst;
	declare @DateLast as varchar(255) = (select top 1 id_czas from STATYSTYKI_FACT order by id_czas desc);
	print @DateLast;
	declare @DateAmount as int = 1 + DATEDIFF(day, @DateFirst, @DateLast);
	--declare @DateAmount as int = 1 + DATEDIFF(day, @DateFirst, @DateLast);
	print @DateAmount;

	--USUN TO KURWA BO DZIEN ZA MALO BEDZIE

	declare @AllDateAmount as int = (1 + (select top 1 count(id_czas) from STATYSTYKI_FACT group by kraj)); 
	print @AllDateAmount;
	--declare @DateAmount as int = ( (select top 1 count(id_czas) from STATYSTYKI_FACT group by kraj));
	declare @CountryAmount as int = (1 + (select top 1 count(kraj) from STATYSTYKI_FACT group by id_czas));;
	--declare @CounterDate as int = @AllDateAmount - @DateAmount;
	--print @CounterDate

	create table tmpKraj (RowKraj int, kraj varchar(255));
	insert into tmpKraj
	select ROW_NUMBER() over (order by kraj) as RowKraj, kraj from STATYSTYKI_FACT group by kraj;

	create table tmpCzas (RowCzas int, czas varchar(255));
	insert into tmpCzas
	select ROW_NUMBER() over (order by id_czas) as RowCzas, id_czas from STATYSTYKI_FACT group by id_czas;

	declare @CounterDate as varchar(255) = (select top 1 RowCzas from tmpCzas where czas = @DateFirst);
	print @CounterDate;

	while @CounterDate < @DateAmount
	begin
		declare @Date as varchar(255) = (select czas from tmpCzas where RowCzas = @CounterDate);
		declare @CounterCountry as int = 1;
		while @CounterCountry < @CountryAmount
		begin
			--potwierdzone przypadki
			declare @Country as varchar(255) = (select kraj from tmpKraj where RowKraj = @CounterCountry) ;
			declare @DayPatientAmount as int = (select top 1 nowe_przypadki from STATYSTYKI_FACT where kraj = @Country and id_czas = @Date);
			declare @CounterPatient as int = 0;
			while @CounterPatient < @DayPatientAmount
			begin
				insert into PACJENT_DIM (plec, wiek)
				values (CAST(RAND(CHECKSUM(NEWID()))*2 as int), CAST(RAND(CHECKSUM(NEWID()))*90 as int));
				insert into PACJENT_FACT (data_zachorowania, kraj, id_pacjenta, id_stanu)
				values (@Date, @Country, (select top 1 id from PACJENT_DIM order by id desc), 'p');
				--insert into PACJENT (id_czas, kraj, plec, wiek, stan)
				--values (@Date, @Country, CAST(RAND(CHECKSUM(NEWID()))*2 as int), CAST(RAND(CHECKSUM(NEWID()))*90 as int) + 10, 'p');
				set @CounterPatient = @CounterPatient + 1;
			end

			--zgony
			set @CounterPatient = 0;
			declare @DayDeathsAmount as int = (select top 1 nowe_zgony from STATYSTYKI_FACT where kraj = @Country and id_czas = @Date);
			while @CounterPatient < @DayDeathsAmount
			begin
				update PACJENT_FACT set data_zmiany_stanu = @Date, id_stanu = 'z' where id = (select top 1 min(id) from PACJENT_FACT where kraj = @Country and id_stanu = 'p');
				set @CounterPatient = @CounterPatient + 1;
			end
			--wyzdrowiali
			set @CounterPatient = 0;
			declare @DayRecoverAmount as int = (select top 1 nowe_wzydrowienia from STATYSTYKI_FACT where kraj = @Country and id_czas = @Date);
			while @CounterPatient < @DayRecoverAmount
			begin
				update PACJENT_FACT set data_zmiany_stanu = @Date, id_stanu = 'w' where id = (select top 1 min(id) from PACJENT_FACT where kraj = @Country and id_stanu = 'p');
				set @CounterPatient = @CounterPatient + 1;
			end
			set @CounterCountry = @CounterCountry + 1;
		end
		set @CounterDate = @CounterDate + 1;
	end
	drop table tmpCzas;
	drop table tmpKraj;
	update PACJENT_DIM set plec = case when PACJENT_DIM.plec = '1' then 'k' else 'm' end;
end

