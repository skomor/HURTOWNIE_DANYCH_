use Coronavirus;
GO

begin
	declare @PatientAmount as int = (select top 1 sum(nowe_przypadki) from STATYSTYKI_FACT);
	declare @StatystykiAmount as int = (select count(id_statystyki) from STATYSTYKI_FACT);
	declare @DateFirst as varchar(255) = (select top 1 data_zachorowania from PACJENT_FACT order by data_zachorowania desc);
	print @DateFirst;
	declare @DateLast as varchar(255) = (select top 1 id_czas from STATYSTYKI_FACT order by id_czas desc);
	print @DateLast;
	--set @DateLast = '2020-01-30';
	declare @DateAmount as int = DATEDIFF(day, @DateFirst, @DateLast);
	--declare @DateAmount as int = 1 + DATEDIFF(day, @DateFirst, @DateLast);
	print @DateAmount;

	declare @AllDateAmount as int = (1 + (select top 1 count(id_czas) from STATYSTYKI_FACT group by kraj)); 
	print @AllDateAmount;
	--declare @DateAmount as int = ( (select top 1 count(id_czas) from STATYSTYKI_FACT group by kraj));
	declare @CountryAmount as int = (1 + (select top 1 count(kraj) from STATYSTYKI_FACT group by id_czas));;
	--declare @CounterDate as int = @AllDateAmount - @DateAmount;
	--print @CounterDate

	create table tmpKraj3 (RowKraj int, kraj varchar(255));
	insert into tmpKraj3
	select ROW_NUMBER() over (order by kraj) as RowKraj, kraj from STATYSTYKI_FACT group by kraj;

	create table tmpCzas3 (RowCzas int, czas varchar(255));
	insert into tmpCzas3
	select ROW_NUMBER() over (order by id_czas) as RowCzas, id_czas from STATYSTYKI_FACT group by id_czas;

	create table PACJENT_FACT_tmp (
	id bigint,
	data_zachorowania varchar(255),
	data_zmiany_stanu varchar(255),
	kraj varchar(255),
	id_pacjenta bigint,
	id_stanu char
	);

	create table PACJENT_FACT_tmp2 (
	id bigint,
	data_zachorowania varchar(255),
	data_zmiany_stanu varchar(255),
	kraj varchar(255),
	id_pacjenta bigint,
	id_stanu char
	);

	declare @CounterDate as varchar(255) = (1+ (select top 1 RowCzas from tmpCzas3 where czas = @DateFirst));

	while @CounterDate < @AllDateAmount
	begin
		declare @Date as varchar(255) = (select czas from tmpCzas3 where RowCzas = @CounterDate);
		declare @CounterCountry as int = 1;
		while @CounterCountry < @CountryAmount
		begin
			--potwierdzone przypadki
			declare @Country as varchar(255) = (select kraj from tmpKraj3 where RowKraj = @CounterCountry) ;
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
				--update PACJENT_FACT set data_zmiany_stanu = @Date, id_stanu = 'z' where id = (select top 1 min(id) from PACJENT_FACT where kraj = @Country and id_stanu = 'p');
				insert into PACJENT_FACT_tmp (data_zmiany_stanu, kraj, id_stanu)
				values (@Date, @Country, 'z');
				set @CounterPatient = @CounterPatient + 1;
			end
			--wyzdrowiali
			set @CounterPatient = 0;
			declare @DayRecoverAmount as int = (select top 1 nowe_wzydrowienia from STATYSTYKI_FACT where kraj = @Country and id_czas = @Date);
			while @CounterPatient < @DayRecoverAmount
			begin
				insert into PACJENT_FACT_tmp (data_zmiany_stanu, kraj, id_stanu)
				values (@Date, @Country, 'w');
				set @CounterPatient = @CounterPatient + 1;
			end
			-----------------------------------------------------------------
			create table tmp4 (rownum bigint, id bigint, data_zachorowania varchar(255), kraj varchar(255), id_pacjenta bigint);
			insert into tmp4(rownum, id, data_zachorowania, kraj, id_pacjenta) select top (select count(*) from PACJENT_FACT_tmp where @Country = PACJENT_FACT_tmp.kraj and id_stanu <> 'p' and PACJENT_FACT_tmp.data_zmiany_stanu = @Date) ROW_NUMBER() over (order by data_zachorowania) as rownum, id, data_zachorowania, kraj, id_pacjenta from PACJENT_FACT where PACJENT_FACT.kraj = @Country and id_stanu = 'p' order by PACJENT_FACT.data_zachorowania;
			--select * from tmp4;
			create table tmp5 (rownum bigint, data_zmiany_stanu varchar(255), id_stanu char);
			insert into tmp5 (rownum, data_zmiany_stanu, id_stanu) select ROW_NUMBER() over (order by data_zmiany_stanu) as rownum, data_zmiany_stanu, id_stanu from PACJENT_FACT_tmp where @Country = PACJENT_FACT_tmp.kraj and id_stanu <> 'p' and PACJENT_FACT_tmp.data_zmiany_stanu = @Date order by PACJENT_FACT_tmp.data_zmiany_stanu;
			--select * from tmp5;

			create table tmp6 (id bigint, data_zachorowania varchar(255), kraj varchar(255), id_pacjenta bigint, data_zmiany_stanu varchar(255), id_stanu char);
			insert into tmp6 (id, data_zachorowania, kraj, id_pacjenta, data_zmiany_stanu, id_stanu)
			select tmp4.id, tmp4.data_zachorowania, tmp4.kraj, tmp4.id_pacjenta, tmp5.data_zmiany_stanu, tmp5.id_stanu from tmp4 inner join tmp5 on tmp4.rownum = tmp5.rownum;
			--select * from tmp6;
			--update PACJENT_FACT_tmp
			--set PACJENT_FACT_tmp.data_zmiany_stanu = tmp6.data_zmiany_stanu, PACJENT_FACT_tmp.id_stanu = tmp6.id_stanu where tmp6.id = PACJENT_FACT_tmp.id;
			--insert into PACJENT_FACT_tmp2 (id, data_zachorowania, kraj, id_pacjenta, data_zmiany_stanu, id_stanu)
			--select tmp4.id, tmp4.data_zachorowania, tmp4.kraj, tmp4.id_pacjenta, tmp5.data_zmiany_stanu, tmp5.id_stanu from tmp4 inner join tmp5 on tmp4.rownum = tmp5.rownum;
			update p
			set p.data_zmiany_stanu = t.data_zmiany_stanu, p.id_stanu = t.id_stanu from PACJENT_FACT as p inner join tmp6 as t on t.id = p.id;


			drop table tmp4;
			drop table tmp5;
			drop table tmp6;
			set @CounterCountry = @CounterCountry + 1;
		end
		set @CounterDate = @CounterDate + 1;
	end
	
	update PACJENT_DIM set plec = case when (PACJENT_DIM.plec = '1' or PACJENT_DIM.plec = 'k') then 'k' else 'm' end;

	drop table tmpCzas3;
	drop table tmpKraj3;
	drop table PACJENT_FACT_tmp;
	drop table PACJENT_FACT_tmp2;
end
