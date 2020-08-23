use master
go
IF EXISTS (select name from sys.databases where name = 'Rezervacije')
Drop database Rezervacije
go
Create database Rezervacije
go
use Rezervacije
go
  -----------------------------------------------Kreiranje tabela-------------------------------------
Create table Gost
(
  JMBG varchar(13) primary key,
  Ime nvarchar(20) NOT NULL,
  Prezime nvarchar(20) NOT NULL,
  Kontakt nvarchar(20) NOT NULL
);

Create table Radnik
(
  Sifra int primary key,
  Ime nvarchar(20) NOT NULL,
  Prezime nvarchar(20) NOT NULL,
  Plata int NOT NULL,
  Bonus int NOT NULL,
);

Create table RadnoMesto
(
  Sifra_RM int primary key,
  Naziv nvarchar(20) NOT NULL,
  Rukovodilac int NOT NULL,
  
  Foreign key(Rukovodilac) references Radnik(Sifra) 
);

Create table RadiNa
(
   SifraRadnika int NOT NULL,
   SifraRM int NOT NULL,
   DatumZaposljenja date NOT NULL,

   Primary key(SifraRadnika,SifraRM),
   Foreign key(SifraRadnika) references Radnik(Sifra),
   Foreign key(SifraRM) references RadnoMesto(Sifra_RM)
);

Create table Cenovnik
(
  SifraCenovnika int primary key,
  DatumOD date NOT NULL,
  DatumDO date 
);

Create table Usluga
(
  Sifra int primary key,
  Opis nvarchar(50) NOT NULL 
);

Create table StavkaCenovnika
(
  RedniBR int NOT NULL,
  SifraCenovnika int NOT NULL,
  Cena int NOT NULL,
  SifraUsluge int NOT NULL,

  Primary key(RedniBR,SifraCenovnika),
  Foreign key(SifraCenovnika) references Cenovnik(SifraCenovnika),
  Foreign key(SifraUsluge) references Usluga(Sifra)
);

Create table Porez
(
  SifraPoreza int primary key,
  Naziv nvarchar(20) NOT NULL,
  Iznos int NOT NULL
);

Create table Popust
(
  SifraPopusta int primary key,
  Naziv nvarchar(20) NOT NULL,
  Iznos int NOT NULL
);

Create table NacinPlacanja
(
  SifraP int primary key,
  Naziv nvarchar(20) NOT NULL
);

Create table Racun
(
  SifraRacuna int primary key,
  SifraPoreza int NOT NULL,
  SifraPopusta int NOT NULL,
  SifraP int NOT NULL,
  JMBG varchar(13) NOT NULL,

  Foreign key(SifraPoreza) references Porez(SifraPoreza),
  Foreign key(SifraPopusta) references Popust(SifraPopusta),
  Foreign key(SifraP) references NacinPlacanja(SifraP), 
  Foreign key(JMBG) references Gost(JMBG) ON DELETE CASCADE
);

Create table StavkaRacuna
(
  RedniBR int NOT NULL,
  SifraCenovnika int NOT NULL,
  SifraStavkeCenovnika int NOT NULL,
  SifraRacuna int NOT NULL,

  Primary key(RedniBR,SifraRacuna),
  Foreign key(SifraRacuna) references Racun(SifraRacuna) ON DELETE CASCADE,
  Foreign key(SifraStavkeCenovnika,SifraCenovnika) references StavkaCenovnika(RedniBR,SifraCenovnika)
);

Create table VrstaSobe
(
  Sifra int primary key,
  Naziv nvarchar(20),
  Constraint "vrsta" check (Naziv in ('jednokrevetna','dvokrevetna','apartman'))
);

Create table Sprat
(
  BrSprata int primary key,
  BrojSoba int NOT NULL
);

Create table PaketUsluga
(
  SifraPaketa int primary key,
  NazivPaketa nvarchar(20) NOT NULL
);

Create table Soba
(
  BrSobe int primary key,
  Dostupnost bit NOT NULL,
  BrSprata int NOT NULL,
  VrstaSobe int NOT NULL,
  SifraPaketa int NOT NULL,

  Foreign key(BrSprata) references Sprat(BrSprata),
  Foreign key(VrstaSobe) references VrstaSobe(Sifra),
  Foreign key(SifraPaketa) references PaketUsluga(SifraPaketa),
);

Create table Rezervacija
(
  SifraRezervacije int primary key,
  DatumDolaska date NOT NULL,
  DatumOdlaska date,
  BrSobe int NOT NULL,
  Gost varchar(13) NOT NULL,
  
  Foreign key(BrSobe) references Soba(BrSobe),
  Foreign key(Gost) references Gost(JMBG)
);

Create table Verbalna
(
  SifraRezervacije int primary key,
  Ocena int NOT NULL,
  SifraRadnika int NOT NULL,

  Foreign key(SifraRezervacije) references Rezervacija(SifraRezervacije) ON DELETE CASCADE,
  Foreign key(SifraRadnika) references Radnik(Sifra)
);

Create table Elektronska
(
   SifraRezervacije int primary key,
   Sajt nvarchar(40) NOT NULL,

   Foreign key(SifraRezervacije) references Rezervacija(SifraRezervacije) ON DELETE CASCADE
);

Create table UslugaUPaket
(
 SifraPaketa int NOT NULL,
 SifraUsluge int NOT NULL,

 Primary key(SifraPaketa,SifraUsluge),
 Foreign key(SifraPaketa) references PaketUsluga(SifraPaketa),
 Foreign key(SifraUsluge) references Usluga(Sifra)
);

 ---------------------------------------------Inicijalizacija baze-----------------------------------------------
--> Tabela Gost
Insert Gost (JMBG,Ime,Prezime,Kontakt)
Values ('2209999211007', 'David', 'Gudovic', '0612295011')
Insert Gost (JMBG,Ime,Prezime,Kontakt)
Values ('1203996212032', 'Savo', 'Terzic', '0691293228')
Insert Gost (JMBG,Ime,Prezime,Kontakt)
Values ('0102999216016', 'Marko', 'Nikcevic', '0623256178')
Insert Gost (JMBG,Ime,Prezime,Kontakt)
Values ('0101991212008', 'Dusko', 'Markovic', '0673214871')
Insert Gost (JMBG,Ime,Prezime,Kontakt)
Values ('1297981245006', 'Marinko', 'Madzgalj', '0602424031')

--> Tabela Radnik

Insert Radnik (Sifra,Ime,Prezime,Plata,Bonus)
Values(1, 'Milos', 'Kostic', 25000, 0)
Insert Radnik (Sifra,Ime,Prezime,Plata,Bonus)
Values(2, 'Sreten', 'Bozovic', 35000, 3000)
Insert Radnik (Sifra,Ime,Prezime,Plata,Bonus)
Values(3, 'Dragan', 'Dragic', 20000, 2000)
Insert Radnik (Sifra,Ime,Prezime,Plata,Bonus)
Values(4, 'Danijel', 'Alibabic', 25000, 0)
Insert Radnik (Sifra,Ime,Prezime,Plata,Bonus)
Values(5, 'Janko', 'Jankovic', 55000, 250)

--> Tabela Cenovnik
Insert Cenovnik( SifraCenovnika,DatumOD,DatumDO)
Values (1,CAST(N'2010-03-27'As date),CAST(N'2012-03-27'As date))
Insert Cenovnik( SifraCenovnika,DatumOD,DatumDO)
Values (2,CAST(N'2012-03-27'As date),CAST(N'2014-03-27'As date))
Insert Cenovnik( SifraCenovnika,DatumOD,DatumDO)
Values (3,CAST(N'2014-03-27'As date),CAST(N'2016-03-27'As date))
Insert Cenovnik( SifraCenovnika,DatumOD,DatumDO)
Values (4,CAST(N'2016-03-27'As date),CAST(N'2018-03-27'As date))
Insert Cenovnik( SifraCenovnika,DatumOD,DatumDO)
Values (5,CAST(N'2018-03-27'As date),CAST(N'2022-03-27'As date))

-->Tabela Porez
Insert Porez(SifraPoreza,Naziv,Iznos)
Values (1,'PDV',20)
Insert Porez(SifraPoreza,Naziv,Iznos)
Values (2,'PND',14)
Insert Porez(SifraPoreza,Naziv,Iznos)
Values (3,'PNDH',15)
Insert Porez(SifraPoreza,Naziv,Iznos)
Values (4,'PNI',27)
Insert Porez(SifraPoreza,Naziv,Iznos)
Values (5,'PNO',12)

-->Tabela Popust
Insert Popust(SifraPopusta,Naziv,Iznos)
Values(1,'Popust za decu',20)
Insert Popust(SifraPopusta,Naziv,Iznos)
Values(2,'Popust za penzionere',20)
Insert Popust(SifraPopusta,Naziv,Iznos)
Values(3,'Popust za stalne',30)
Insert Popust(SifraPopusta,Naziv,Iznos)
Values(4,'Popust za nove goste',10)
Insert Popust(SifraPopusta,Naziv,Iznos)
Values(5,'Popust za zaposlene',50)

-->Tabela NacinPlacanja
Insert NacinPlacanja(SifraP,Naziv)
Values (1, 'Kes')
Insert NacinPlacanja(SifraP,Naziv)
Values (2, 'Kreditna Kartica')
Insert NacinPlacanja(SifraP,Naziv)
Values (3, 'Debitna Kartica')
Insert NacinPlacanja(SifraP,Naziv)
Values (4, 'Na Rate')
Insert NacinPlacanja(SifraP,Naziv)
Values (5, 'Cek')

--> Tabela VrstaSobe
Insert VrstaSobe(Sifra,Naziv)
Values (1,'jednokrevetna')
Insert VrstaSobe(Sifra,Naziv)
Values (2,'dvokrevetna')
Insert VrstaSobe(Sifra,Naziv)
Values (3,'apartman')

--> Tabela Sprat
Insert Sprat(BrSprata,BrojSoba)
Values(1,10)
Insert Sprat(BrSprata,BrojSoba)
Values(2,15)
Insert Sprat(BrSprata,BrojSoba)
Values(3,15)
Insert Sprat(BrSprata,BrojSoba)
Values(4,15)
Insert Sprat(BrSprata,BrojSoba)
Values(5,10)

-->Tabela PaketUsluga
Insert PaketUsluga(SifraPaketa,NazivPaketa)
Values(1,'polupansion')
Insert PaketUsluga(SifraPaketa,NazivPaketa)
Values(2,'pansion')
Insert PaketUsluga(SifraPaketa,NazivPaketa)
Values(3,'fitness')
Insert PaketUsluga(SifraPaketa,NazivPaketa)
Values(4,'VIP')
Insert PaketUsluga(SifraPaketa,NazivPaketa)
Values(5,'standard')

--> Tabela Usluga
Insert Usluga(Sifra,Opis)
Values(1,'dorucak')
Insert Usluga(Sifra,Opis)
Values(2,'rucak')
Insert Usluga(Sifra,Opis)
Values(3,'teretana')
Insert Usluga(Sifra,Opis)
Values(4,'bazen')
Insert Usluga(Sifra,Opis)
Values(5,'ciscenje sobe')

-->Tabela UslugaUPaket
Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(1,1)
Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(1,5)

Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(2,1)
Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(2,2)
Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(2,5)

Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(3,3)
Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(3,5)

Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(4,4)
Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(4,5)

Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(5,5)

-->Tabela RadnoMesto
Insert RadnoMesto(Sifra_RM,Naziv,Rukovodilac)
Values(1,'Menadzment',5)
Insert RadnoMesto(Sifra_RM,Naziv,Rukovodilac)
Values(2,'Recepcija',3)
Insert RadnoMesto(Sifra_RM,Naziv,Rukovodilac)
Values(3,'Teretana',2)
Insert RadnoMesto(Sifra_RM,Naziv,Rukovodilac)
Values(4,'Restoran',1)
Insert RadnoMesto(Sifra_RM,Naziv,Rukovodilac)
Values(5,'Bezbednost',1)

--Tabela RadiNa
Insert RadiNa(SifraRadnika,SifraRM,DatumZaposljenja)
Values(1,2,CAST(N'2019-12-01'As date))
Insert RadiNa(SifraRadnika,SifraRM,DatumZaposljenja)
Values(2,1,CAST(N'2017-06-02'As date))
Insert RadiNa(SifraRadnika,SifraRM,DatumZaposljenja)
Values(3,3,CAST(N'2011-05-17'As date))
Insert RadiNa(SifraRadnika,SifraRM,DatumZaposljenja)
Values(4,5,CAST(N'2016-03-17'As date))
Insert RadiNa(SifraRadnika,SifraRM,DatumZaposljenja)
Values(5,4,CAST(N'2015-10-22'As date))

--Tabela StavkaCenovnika
Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(1,1,1023,1)
Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(2,1,1599,2)

Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(1,2,2000,3)
Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(2,2,2150,4)

Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(1,3,10230,5)
Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(2,3,10231,1)

Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(1,4,25010,1)
Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(2,4,123010,2)

Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(1,5,61213,4)
Insert StavkaCenovnika(RedniBR,SifraCenovnika,Cena,SifraUsluge)
Values(2,5,10123,1)

-->Tabela Racun
Insert Racun(SifraRacuna,SifraPoreza,SifraPopusta,SifraP,JMBG)
Values(1,2,3,4,'2209999211007')
Insert Racun(SifraRacuna,SifraPoreza,SifraPopusta,SifraP,JMBG)
Values(2,4,3,2,'1203996212032')
Insert Racun(SifraRacuna,SifraPoreza,SifraPopusta,SifraP,JMBG)
Values(3,5,1,2,'0102999216016')
Insert Racun(SifraRacuna,SifraPoreza,SifraPopusta,SifraP,JMBG)
Values(4,1,4,3,'0101991212008')
Insert Racun(SifraRacuna,SifraPoreza,SifraPopusta,SifraP,JMBG)
Values(5,5,2,1,'1297981245006')

-->Tabela StavkaRacuna
Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(1,1,1,1)
Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(2,1,1,2)

Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(1,2,2,1)
Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(2,2,2,2)

Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(1,3,4,1)
Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(2,3,4,2)

Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(1,4,3,1)
Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(2,4,3,2)

Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(1,5,5,1)
Insert StavkaRacuna(RedniBR,SifraRacuna,SifraCenovnika,SifraStavkeCenovnika)
Values(2,5,5,2)

-->Tabela Soba
Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(1,0,1,1,1)
Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(2,1,1,3,1)

Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(15,0,2,2,3)
Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(16,1,2,3,5)

Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(23,0,3,2,4)
Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(25,1,3,3,5)

Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(32,0,4,3,2)
Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(36,1,4,2,2)

Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(45,0,5,1,5)
Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(42,1,5,1,5)

--> Tabela Rezervacija
Insert Rezervacija(SifraRezervacije,DatumDolaska,DatumOdlaska,BrSobe,Gost)
Values(1,CAST(N'2020-10-22'As date),CAST(N'2020-10-23'As date),1,'2209999211007')
Insert Rezervacija(SifraRezervacije,DatumDolaska,DatumOdlaska,BrSobe,Gost)
Values(2,CAST(N'2020-10-22'As date),CAST(N'2020-10-24'As date),15,'1203996212032')
Insert Rezervacija(SifraRezervacije,DatumDolaska,DatumOdlaska,BrSobe,Gost)
Values(3,CAST(N'2020-10-22'As date),CAST(N'2020-11-25'As date),23,'0102999216016')
Insert Rezervacija(SifraRezervacije,DatumDolaska,DatumOdlaska,BrSobe,Gost)
Values(4,CAST(N'2020-10-22'As date),CAST(N'2020-10-26'As date),32,'0101991212008')
Insert Rezervacija(SifraRezervacije,DatumDolaska,DatumOdlaska,BrSobe,Gost)
Values(5,CAST(N'2020-10-22'As date),CAST(N'2020-10-27'As date),45,'1297981245006')

--> Tabela Verbalno
Insert Verbalna(SifraRadnika,SifraRezervacije,Ocena)
Values(1,1,10)
Insert Verbalna(SifraRadnika,SifraRezervacije,Ocena)
Values(1,5,5)

-->Tabela Elektronka
Insert Elektronska(SifraRezervacije,Sajt)
Values(2,'airbnb.com')
Insert Elektronska(SifraRezervacije,Sajt)
Values(3,'sajt.rs')
Insert Elektronska(SifraRezervacije,Sajt)
Values(4,'stannadan.rs')

go
---------------------------------------VIEW----------------------------------------
CREATE VIEW Ocene_Interakcija_Sa_Recepcionarom
AS
Select concat(g.Ime, ' ', g.Prezime) as Gost, concat(rad.Ime, ' ', rad.Prezime) as Radnik, v.Ocena, r.SifraRezervacije as Rezervacija
from ((Verbalna v join Rezervacija r on v.SifraRezervacije = r.SifraRezervacije) join Radnik rad on v.SifraRadnika = rad.Sifra) join Gost g on r.Gost = g.JMBG
go

Select * from Ocene_Interakcija_Sa_Recepcionarom

go

CREATE VIEW Vrsta_Sobe_Usluge_u_Sobi
AS
Select s.BrSobe,vs.Naziv,u.Opis 
from (Soba s join VrstaSobe vs on s.VrstaSobe = vs.Sifra) 
join ((Usluga u join UslugaUPaket uup on u.Sifra = uup.SifraUsluge) join PaketUsluga p on p.SifraPaketa = uup.SifraPaketa) on p.SifraPaketa = s.SifraPaketa
go
Select * from Vrsta_Sobe_Usluge_u_Sobi

go

Create view Bruto_Total
AS
Select r.SifraRacuna, Sum(sc.Cena) as 'Bruto total'
From (StavkaRacuna sr join Racun r on sr.SifraRacuna = r.SifraRacuna) 
join StavkaCenovnika sc on sc.RedniBR = sr.SifraStavkeCenovnika AND sc.SifraCenovnika = sr.SifraCenovnika
Group by r.SifraRacuna
go

----------------------------FUNKCIJE----------------------------------
use Rezervacije
go
CREATE FUNCTION Ostale_Rezervacije_Gosta(@Gost varchar(13))
RETURNS TABLE
AS
return 
select r.SifraRezervacije,r.BrSobe, concat(g.Ime, ' ', g.Prezime) as Gost
from Rezervacija r join Gost g on r.Gost = @Gost AND g.JMBG = @Gost
where r.Gost = @Gost
go
Select * from Ostale_Rezervacije_Gosta('2209999211007')

go
Create Function PaketUsluga_u_Sobi(@BrojSobe int)
RETURNS TABLE
AS
return 
Select us.BrSobe,us.Opis
from Vrsta_Sobe_Usluge_u_Sobi us
where us.BrSobe = @BrojSobe
go
Select * from PaketUsluga_u_Sobi(3)

go
CREATE Function Porez_Popust_NacinPlacanja_za_Racun(@BrojRacuna int)
RETURNS TABLE
AS
return
Select r.SifraRacuna,concat(pop.Naziv, ' ', pop.Iznos,'%') as 'Popust',concat(por.Naziv,' ',por.Iznos,'%') as 'Porez',nap.Naziv as 'Nacin Placanja'
from Racun r join Popust pop on r.SifraPopusta = pop.SifraPopusta join Porez por on por.SifraPoreza = r.SifraPoreza join NacinPlacanja nap on nap.SifraP = r.SifraP
where r.SifraRacuna = @BrojRacuna
go
Select * from Porez_Popust_NacinPlacanja_za_Racun(2)

go

----------------------------- procedure -------------------------

Go
CREATE PROCEDURE Novi_Nacin_Placanja_Za_Racun
@NacinPlacanja varchar(20),
@BrojRacuna int,
@NazivPoreza varchar(20),
@IznosPoreza int
as 
begin try
SET XACT_ABORT ON
BEGIN TRANSACTION

Declare @nPlacanjaID int
Select @nPlacanjaID = Count(*) + 1 from NacinPlacanja
Declare @PorezID int
Select @PorezID = Count(*) + 1 from Porez

Insert NacinPlacanja(SifraP,Naziv)
Values(@nPlacanjaID,@NacinPlacanja)

Insert Porez(SifraPoreza,Naziv,Iznos)
Values(@PorezID,@NazivPoreza,@IznosPoreza)

Update Racun
set SifraPoreza = @PorezID
where SifraRacuna = @BrojRacuna

Update Racun
set SifraP = @nPlacanjaID
where SifraRacuna = @BrojRacuna

COMMIT TRANSACTION
END TRY
BEGIN CATCH
PRINT  'Doslo je do greske '
ROLLBACK TRANSACTION;
END CATCH;
GO
exec Novi_Nacin_Placanja_Za_Racun 'Bitcoin',2,'PN-Kriptovalute',12

use Rezervacije
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Otkazivanje_Rezervacije
@BrojRezervacije int
as 
begin try
SET XACT_ABORT ON
BEGIN TRANSACTION
Declare @gost varchar(13)
Select @gost = r.Gost
from Rezervacija r
where r.SifraRezervacije = @BrojRezervacije

UPDATE Soba
set Dostupnost = 'true'
where Soba.BrSobe = (Select s.BrSobe from Soba s join Rezervacija r on r.BrSobe = s.BrSobe where r.SifraRezervacije = @BrojRezervacije);

Delete Rezervacija 
where SifraRezervacije = @BrojRezervacije

IF NOT EXISTS(Select * from Rezervacija r where r.Gost = @gost)
BEGIN
 Delete Gost
 where Gost.JMBG = @gost
END


COMMIT TRANSACTION
END TRY
BEGIN CATCH
PRINT  'Doslo je do greske'
ROLLBACK TRANSACTION;
END CATCH;
GO

exec Otkazivanje_Rezervacije 2



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Dodavanje_Sobe_Sa_Novim_Paketom_Usluga
@BrojSobe int,
@BrojSprata int,
@VrstaSobe int,
@OpisUsluge nvarchar(50),
@NazivPaketa nvarchar(20)
as 
begin try
SET XACT_ABORT ON
BEGIN TRANSACTION

DECLARE @UslugaID int
Select @UslugaID = Count(*) + 1 from Usluga 

DECLARE @PaketID int
Select @PaketID = Count(*) + 1 from PaketUsluga

Insert Usluga(Sifra,Opis)
Values(@UslugaID,@OpisUsluge)

Insert PaketUsluga(SifraPaketa,NazivPaketa)
Values(@PaketID,@NazivPaketa)

Insert UslugaUPaket(SifraPaketa,SifraUsluge)
Values(@PaketID,@UslugaID)

IF NOT EXISTS(Select * from Soba where BrSobe = @BrojSobe)
BEGIN
Insert Soba(BrSobe,Dostupnost,BrSprata,VrstaSobe,SifraPaketa)
Values(@BrojSobe,'true',@BrojSprata,@VrstaSobe,@PaketID)
END 
Else
Throw 77777,'Soba vec postoji',1;

COMMIT TRANSACTION
END TRY
BEGIN CATCH
PRINT  'Greska: ' + Error_Message()
ROLLBACK TRANSACTION;
END CATCH;
GO

exec Dodavanje_Sobe_Sa_Novim_Paketom_Usluga 3,1,3,'Sve usluge','all inclusive'
