create database Coronavirus;

use Coronavirus;

create table CZAS_DIM (
id_czas int not null primary key,
dzien int,
miesiac_nazwa varchar(255),
miesiac int,
rok int
)

create table GEOGRAFIA_DIM (
kontynent varchar(255),
kraj varchar(255) not null primary key,
populacja varchar(255),
pkb varchar(255)
)

create table STATYSTYKI_FACT (
id_statystyki int not null primary key,
id_czas int foreign key references CZAS_DIM(id_czas),
id_geografia int foreign key references GEOGRAFIA_DIM(id_geografia),
liczba_zakazen varchar(255),
liczba_zgonow varchar(255),
liczba_wyleczonych varchar(255),
nowe_przypadki varchar(255),
liczba_zakazonych varchar(255),
dynamika_zakazen varchar(255)
)

create table PACJENT_DIM (
id_pacjent int not null primary key,
id_geografia int foreign key references GEOGRAFIA_DIM(id_geografia),
wiek varchar(255),
plec varchar(255),
stan varchar(255)
)

create table PACJENT_FACT (
id_f_pacjent int not null primary key,
id_pacjent int foreign key references PACJENT_DIM(id_pacjent),
id_czas int foreign key references CZAS_DIM(id_czas)
)

drop table STATYSTYKI_FACT
drop table PACJENT_FACT
drop table CZAS_DIM
drop table PACJENT_DIM
drop table GEOGRAFIA_DIM
