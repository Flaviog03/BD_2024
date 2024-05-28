/*
    Controllo se l'impiegato inserito fa un lavoro che non esiste ancora:
    - Se il lavoro è nuovo:
        * Inserisco il nuovo lavoro in SUMMARY
    - Se il lavoro esiste già:
        * Aggiorno NUM di SUMMARY con JOB = :NEW.JOB
*/

CREATE OR REPLACE TRIGGER InserimentoImpiegato
AFTER INSERT ON IMP
FOR EACH ROW
DECLARE
    nImpiegati NUMBER;
BEGIN
--- Trovo il numero di impiegati con lo stesso lavoro
    SELECT NUM INTO nImpiegati
    FROM SUMMARY
    WHERE JOB = :NEW.JOB;

--- Se il lavoro è nuovo
    IF(nImpiegati = 0) THEN
        INSERT INTO SUMMARY(JOB, NUM)
        VALUES (:NEW.JOB, 1);
--- Se il lavoro esiste gia'
    ELSE
        UPDATE SUMMARY
        SET NUM = NUM + 1
        WHERE JOB = :NEW.JOB
    END IF;
END;

/*
    Aggiornamento del campo JOB in IMP

    Se il nuovo JOB non esiste ancora 
        - Inserisco nella tabella SUMMARY un nuovo lavoro

    Se il nuovo JOB esiste già 
        - Incremenento il numero di lavoratori
    
    Conto quanti lavoratori ci sono nella OLD.JOB
    - Se > 1 => Decremento il numero di lavoratori della OLD.JOB
    - Sennò CANCELLO Il record 
*/

CREATE OR REPLACE TRIGGER AggiornamentoImpiegato
AFTER UPDATE OF JOB ON IMP
FOR EACH ROW
DECLARE
    N NUMBER;
    M NUMBER;
BEGIN
--- Conto quanti impiegati fanno il nuovo lavoro
    SELECT NUM INTO N
    FROM SUMMARY
    WHERE JOB = :NEW.JOB;
-- Se il numero di impiegati con il nuovo lavoro è pari a zero
    IF(N = 0) THEN
        INSERT INTO SUMMARY(JOB, NUM)
        VALUES (:NEW.JOB, 1);
-- Sennò
    ELSE
        UPDATE SUMMARY
        SET NUM = NUM + 1
        WHERE JOB = :NEW.JOB;
    END IF;
-- Conto quanti lavoratori ci sono con il vecchio lavoro
    SELECT NUM INTO M
    FROM SUMMARY
    WHERE JOB = :OLD.JOB;

    IF(M > 1) THEN
        UPDATE SUMMARY
        SET NUM = NUM - 1
        WHERE JOB = :OLD.JOB;
    ELSE
        DELETE FROM SUMMARY
        WHERE JOB = :OLD.JOB;
    END IF;
END;