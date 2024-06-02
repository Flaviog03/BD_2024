/*
EVENTO(*CodE, NomeEvento, CategoriaEvento, CostoEvento, DurataEvento)
CALENDARIO_EVENTI(*CodE, *Data, OraInizio, Luogo)
SOMMARIO_CATEGORIA(*CategoriaEvento, *Data, NumeroTotaleEventi, CostoComplessivoEventi)
*/

/*
(1) Aggiornamento della tabella SOMMARIO_CATEGORIA. 
La tabella SOMMARIO_CATEGORIA riporta, per ogni categoria di evento e per ogni data,
il numero complessivo di eventi previsti e il costo complessivo per la loro realizzazione.

Si scriva il trigger per propagare le modifiche alla tabella SOMMARIO_CATEGORIA quando viene
inserito un nuovo evento a calendario (inserimento nella tabella CALENDARIO_EVENTI). 
*/

/*
EVENTO:
    - Inserimento di un record nella tabella CALENDARIO_EVENTI (tabella mutante)
CONDIZIONE:
    - Nessuna
MODALITÀ:
•	Immediata
•	AFTER - regola di Business
GRANULARITÀ:
•	Livello di Tupla
AZIONE:
    - Propagare la modifica alla tabella SOMMARIO_CATEGORIA
*/

CREATE OR REPLACE TRIGGER nuovoEvento
AFTER INSERT ON CALENDARIO_EVENTI
FOR EACH ROW
DECLARE
    catEvento VARCHAR(30);
    costoEvento INTEGER;
    X INTEGER;
BEGIN
-- Ottengo la categoria di appartenenza dell'evento
    SELECT CategoriaEvento, CostoEvento INTO catEvento, costoEvento
    FROM EVENTO
    WHERE CodE = :NEW.CodE;

-- Conto quanti eventi ci sono nel SOMMARIO_CATEGORIA con la nuova data e la categoria dell'evento
    SELECT COUNT(*) INTO X
    FROM SOMMARIO_CATEGORIA
    WHERE Data = :NEW.Data
    AND CategoriaEvento = catEvento;

    IF(X > 0) THEN
        UPDATE SOMMARIO_CATEGORIA
        SET NumeroTotaleEventi = NumeroTotaleEventi + 1,
            CostoComplessivoEventi = CostoComplessivoEventi + costoEvento
        WHERE CategoriaEvento = catEvento AND Data = :NEW.Data;
    ELSE
        INSERT INTO SOMMARIO_CATEGORIA(CategoriaEvento, Data, NumeroTotaleEventi, CostoComplessivoEventi)
        VALUES (catEvento, :NEW.Data, 1, costoEvento);
    END IF;
END;

/*
(2) Vincolo di integrità sul costo massimo dell’evento.
Il costo di un evento della categoria proiezione cinematografica (attributo CategoriaEvento) 
non può essere superiore a 1500 euro. 

Se un valore di costo superiore a 1500 è inserito nella tabella EVENTO, all’attributo CostoEvento
deve essere assegnato il valore 1500.

Si scriva il trigger per la gestione del vincolo di integrità. 
*/

/*
EVENTO:
    - Inserimento o aggiornamento di una tupla nella tabella EVENTO
CONDIZIONE:
    - CostoEvento > 1500
    - Categoria = 'proiezione cinematografica'
MODALITÀ:
    - Immediata
    - BEFORE - Business Rule
GRANULARITÀ:
    - Di Tupla
AZIONE:
    - Modifica del prezzo a 1500
*/

CREATE OR REPLACE TRIGGER costoMaxEventoCinema
BEFORE INSERT OR UPDATE CostoEvento, CategoriaEvento ON EVENTO
FOR EACH ROW
WHEN (:NEW.CategoriaEvento = 'proiezione cinematografica' AND :NEW.CostoEvento > 1500)
BEGIN
    :NEW.CostoEvento := 1500;
END;

/*
(3) Vincolo sul numero massimo di eventi per data. 
In ogni data non possono essere pianificati più di 10 eventi.

Ogni modifica della tabella CALANDARIO_EVENTI che causa la violazione del vincolo non
deve essere eseguita.

EVENTO:
    - Inserimento o aggiornamento di una tupla nella tabella CALENDARIO_EVENTI (TAB MUTANTE)
CONDIZIONE:
    - Nessuna
MODALITÀ:
    - Immediata
    - AFTER - Azione correttiva
GRANULARITÀ:
    - Di Istruzione
AZIONE:
    - Se avviene violazione raise_application_error
*/

CREATE OR REPLACE TRIGGER maxEventiPerData
AFTER INSERT OR UPDATE ON CALENDARIO_EVENTI
DECLARE
    catEvento VARCHAR(30);
    nEventiInData NUMBER;
BEGIN
    -- Trovo quanti eventi ci sono nella data Data
    SELECT COUNT(*) INTO nEventiInData
    FROM SOMMARIO_CATEGORIA
    WHERE Data = :NEW.Data

    IF(nEventiInData > 10)
        raise_application_error(xxx, 'Nella data selezionata sono già presenti 10 eventi');
    END IF;
END;
