ALTER TABLE Coronavirus.dbo.STATYSTYKI_FACT
ADD CONSTRAINT id_czas FOREIGN KEY (id_czas)
      REFERENCES CZAS_DIM(id_czas)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;