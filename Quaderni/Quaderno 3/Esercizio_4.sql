/*
PRENOTAZIONE_TAGLIANDO (*CodR, Targa, Modello, Marca, DataRichiesta)
DISPONIBILITA’_PRENOTAZIONE (*Data, OraApertura, OraChiusura, NumeroPostiDisponibili)
INTERVENTI_RICHIESTI (*Targa, *TipoIntervento)
COSTO_INTERVENTI (*TipoIntervento, *Marca, *Modello, Costo)
NOTIFICA_INFO_TAGLIANDO(*CodR, Targa, DataTagliando, OrarioApertura, OrarioChiusura, CostoTotale)


Si scriva il trigger per gestire le prenotazioni per un intervento di revisione dei veicoli presso
una officina specializzata.
Viene inserita la richiesta di prenotazione per la revisione di un veicolo 
(inserimento di un record nella tabella PRENOTAZIONE_TAGLIANDO),
specificando il tipo di veicolo (marca e modello) e la data in cui si vorrebbe poter effettuare
la revisione (attributo DataRichiesta).

Il trigger deve svolgere le seguenti operazioni.
Si deve selezionare la prima data (successiva o uguale a quella richiesta) 
in cui ci sono ancora posti disponibili. 
La tabella DISPONIBILITA’_PRENOTAZIONE indica, per ogni data,
l’orario di apertura e chiusura al pubblico dell’officina, 
e il numero di posti ancora disponibili per effettuare la revisione del veicolo in quella data.

Se in nessuna data ci sono posti disponibili, la richiesta di prenotazione deve essere annullata. 

Altrimenti si devono svolgere le seguenti operazioni.
Deve essere aggiornato il numero di posti disponibili nella data selezionata

Si deve calcolare il costo totale della revisione.
La tabella INTERVENTI_RICHIESTI memorizza l’elenco dei tipi di intervento
richiesti per il veicolo per cui è prenotata la revisione.
La tabella COSTO_INTERVENTI memorizza il costo di per ogni tipo di intervento in base alla marca
e il modello dei veicolo.

Si deve notificare l’avvenuta prenotazione inserendo un nuovo record nella tabella 
NOTIFICA_INFO_TAGLIANDO, fornendo le indicazioni sulla data selezionata e l’orario di apertura 
e chiusura nella data, e il costo totale per la revisione. 
*/

/*
EVENTO:
•	inserimento di un record nella tabella PRENOTAZIONE_TAGLIANDO
CONDIZIONE:
•	Nessuna
MODALITÀ:
•	Immediata
•	AFTER - regola di Business
GRANULARITÀ:
•	Livello di Tupla
AZIONE:
•   Selezionare la prima data disponibile che abbia NumeroPostiDisponibili != 0 dalla tabella DISPONIBILITA’_PRENOTAZIONE
•	Se vi è almeno una data disponibile:
        - aggiornare numero posti nella data selezionata
        - calcolare il costo dell'intervento
        - inserire un record nella tabella NOTIFICA_INFO_TAGLIANDO

•	Se non vi è nessuna data disponibile: cancellare la richiesta
*/

CREATE OR REPLACE TRIGGER ES4
AFTER INSERT ON PRENOTAZIONE_TAGLIANDO
FOR EACH ROW 
DECLARE
    nDateDisponibili NUMBER;
    DataPrenotazione VARCHAR(10)
    costoTot NUMBER;
    OC NUMBER;
    OA NUMBER;
BEGIN
-- selezionare la prima data (successiva o uguale a quella richiesta) in cui ci sono ancora posti disponibili.
SELECT COUNT(Data) INTO nDateDisponibili
FROM DISPONIBILITA’_PRENOTAZIONE
WHERE Data >= :NEW.DataRichiesta
AND NumeroPostiDisponibili > 0;

IF (nDateDisponibili < > 0) THEN
    SELECT MIN(Data) INTO DataPrenotazione
    FROM DISPONIBILITA’_PRENOTAZIONE
    WHERE Data >= :NEW.DataRichiesta
    AND NumeroPostiDisponibili > 0;

    SELECT OraChiusura, OraApertura INTO OC, OA
    FROM DISPONIBILITA’_PRENOTAZIONE
    WHERE Data = DataPrenotazione;

    UPDATE DISPONIBILITA’_PRENOTAZIONE
    SET NumeroPostiDisponibili = NumeroPostiDisponibili - 1;
    WHERE Data = DataPrenotazione;

    SELECT SUM(Costo) INTO costoTot
    FROM INTERVENTI_RICHIESTI I, PRENOTAZIONE_TAGLIANDO P, COSTO_INTERVENTI C
    WHERE I.Targa = P.Targa AND C.TipoIntervento = I.TipoIntervento
    AND C.Marca = :NEW.Marca AND C.Modello = :NEW.Modello AND I.Targa = :NEW.Targa;

    NOTIFICA_INFO_TAGLIANDO(*CodR, Targa, DataTagliando, OrarioApertura, OrarioChiusura, CostoTotale)
    INSERT INTO NOTIFICA_INFO_TAGLIANDO(CodR, Targa, DataTagliando, OrarioApertura, OrarioChiusura, CostoTotale)
    VALUES (:NEW.CodR, :NEW.Targa, DataPrenotazione, OA, OC, costoTot);

ELSE
    DELETE FROM PRENOTAZIONE_TAGLIANDO
    WHERE CodR = :NEW.CodR;
END IF;
END;