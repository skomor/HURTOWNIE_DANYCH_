use Coronavirus;
GO

begin
	declare @PatientAmount int;
	set @PatientAmount = (select top 1 sum(nowe_przypadki) from STATYSTYKI_FACT);
	declare @StatystykiAmount int;
	set @StatystykiAmount = (select count(id_statystyki) from STATYSTYKI_FACT);
	declare @DateAmount int; 
	set @DateAmount = (1 + (select top 1 count(id_czas) from STATYSTYKI_FACT group by kraj));
	declare @CountryAmount int;
	set @CountryAmount = (1 + (select top 1 count(kraj) from STATYSTYKI_FACT group by id_czas));
	declare @CounterDate int;
	set @CounterDate = 1;
	

	create table tmpKraj (RowKraj int, kraj varchar(255));
	insert into tmpKraj
	select ROW_NUMBER() over (order by kraj) as RowKraj, kraj from STATYSTYKI_FACT group by kraj;

	create table tmpCzas (RowCzas int, czas varchar(255));
	insert into tmpCzas
	select ROW_NUMBER() over (order by id_czas) as RowCzas, id_czas from STATYSTYKI_FACT group by id_czas;

	while @CounterDate < @DateAmount
	begin
		declare @Date as varchar(255) = (select czas from tmpCzas where RowCzas = @CounterDate);
		declare @CounterCountry as int = 1;
		while @CounterCountry < @CountryAmount
		begin
			declare @Country as varchar(255) = (select kraj from tmpKraj where RowKraj = @CounterCountry) ;
			declare @DayPatientAmount as int = (select top 1 nowe_przypadki from STATYSTYKI_FACT where kraj = @Country and id_czas = @Date);
			declare @CounterPatient as int = 0;
			while @CounterPatient < @DayPatientAmount
			begin
				insert into PACJENT (id_czas, kraj, plec, wiek, stan)
				values (@Date, @Country, CAST(RAND(CHECKSUM(NEWID()))*2 as int), CAST(RAND(CHECKSUM(NEWID()))*90 as int) + 10, 'p');
				set @CounterPatient = @CounterPatient + 1;
			end
			set @CounterCountry = @CounterCountry + 1;
		end
		set @CounterDate = @CounterDate + 1;
	end
	drop table tmpCzas;
	drop table tmpKraj;
	update PACJENT set plec = case when PACJENT.plec = '1' then 'k' else 'm' end;
end
