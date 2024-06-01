/*
ESERCIZIO 1

GUIDA(*CodGuida, Nome, Cognome, Nazionalità)
TIPO_VISITA(*CodTipoVisita, Monumento, Durata, Città)
GRUPPO(*CodGR, NumeroPartecipanti, Lingua)
VISITA_GUIDATA_EFFETTUATA(*CodGR, *Data, *OraI, CodTipoVisita, CodGuida)

a) Tra i monumenti per cui sono state effettuate almeno 10 visite guidate,
visualizzare il monumento che è stato visitato complessivamente dal maggior
numero di persone
*/


WITH visitatoriPerMonumento AS(
    SELECT T.Monumento, SUM(G.NumeroPartecipanti) AS totVisitatori
    FROM GRUPPO G, VISITA_GUIDATA_EFFETTUATA V, TIPO_VISITA T
    WHERE G.CodGR = V.CodGR
    AND V.CodTipoVisita = T.CodTipoVisita
    GROUP BY Monumento
    HAVING COUNT(V.CodGR, V.Data, V.OraI) >= 10),
SELECT Monumento
FROM visitatoriPerMonumento AS CTE1
WHERE totVisitatori = (
    SELECT MAX(totVisitatori)
    FROM visitatoriPerMonumento);

/*
ESERCIZIO 2

RAGAZZO(*CodFiscale, Nome, Cognome, DataNascita, CittàResidenza)
ATTIVITA’(*CodAttività, NomeA, Descrizione, Categoria)
CAMPO_ESTIVO(*CodCampo, NomeCampo, Città)
ISCRIZIONE_PER_ATTIVITA’_IN_CAMPO_ESTIVO(*CodFiscale, *CodAttività, *CodCampo, *DataIscrizione)

b) Visualizzare il nome e cognome del ragazzo che ha partecipato al maggior
numero di campi estivi per l’attività della categoria «Tennis».
*/

-- Per ogni codice fiscale contare il numero di campi estivi di tennis

WITH CTE1 AS (
    SELECT I.CodFiscale, R.Nome, R.Cognome, COUNT(DISTINCT I.CodCampo) AS numeroCampi
    FROM ISCRIZIONE_PER_ATTIVITA’_IN_CAMPO_ESTIVO I, ATTIVITA’ A, RAGAZZO R
    WHERE I.CodAttività = A.CodAttività
    AND I.CodFiscale = R.CodFiscale
    AND A.Categoria = 'Tennis'
    GROUP BY I.CodFiscale, R.Nome, R.Cognome),
SELECT Nome, Cognome
FROM CTE1
WHERE numeroCampi = (
    SELECT MAX(numeroCampi)
    FROM CTE1);

/*
ESERCIZIO 3

OFFICINA (*OID, Nome, Indirizzo, Città)
VEICOLO (*Targa, Modello, Marca, Categoria, Alimentazione, AnnoImmatricolazione, $CodFiscale)
CLIENTE (*CodFiscale, Nome, Cognome, DataNascita, Indirizzo, Città)
REVISIONE (*Targa, *OID, *Data, Costo)

Per le officine che hanno effettuato revisioni di almeno 200 veicoli diversi intestati a persone nate tra
il 1970 e il 1980, visualizzare il nome e l’indirizzo dell’officina che ha eseguito il maggior numero di
revisioni (considerando tutte le revisioni effettuate) tra le officine ubicate nella stessa città.
Visualizzare anche il costo totale delle revisioni effettuate dall’officina e il numero di modelli di
veicoli diversi revisionati.
*/

WITH CTE1 AS (
    SELECT R.OID, O.Nome, O.Indirizzo, O.Città, COUNT(DISTINCT R.Targa) AS revisioniDistinte, SUM(R.Costo) AS costoTotale, COUNT(DISTINCT V.Modello) AS modelliDistinti
    FROM REVISIONE R, OFFICINA O, VEICOLO V
    WHERE O.OID = R.OID
    AND R.Targa = V.Targa
    GROUP BY R.OID, O.Nome, O.Indirizzo, O.Città),
SELECT *
FROM CTE1
WHERE OID IN (
    SELECT R.OID
    FROM REVISIONE R, VEICOLO V, CLIENTE C
    WHERE R.Targa = V.Targa
    AND C.CodFiscale = V.CodFiscale
    AND C.DataNascita >= '01/01/1970' AND C.DataNascita <= '31/12/1980'
    GROUP BY R.OID
    HAVING COUNT(DISTINCT R.Targa) >= 200)
AND revisioniDistinte = (
    SELECT MAX(revisioniDistinte)
    FROM CTE1 T
    WHERE T.Città = CTE1.Città);

/*
ESERCIZIO 4

TECNICO (*Matricola, Nome, Cognome, DataNascita, Sesso, Tipo)
INTERVENTO (*CodI, Nome, Descrizione, Costo_orario)
STRUTTURA (*CodS, Indirizzo, Città, Provincia, Regione, Tipologia)
EFFETTUA_INTERVENTO (*Matricola, *CodI, *Data, $CodS, Durata)

Considerando solo le strutture situate nella provincia di Torino, visualizzare la data nel mese di
Marzo 2022 in cui è stato effettuato complessivamente il maggior numero di interventi nelle strutture
considerate.
*/

-- Numero interventi per ogni data del mese di marzo nelle strutture di Torino
WITH INTERVENTI_DATA AS (
    SELECT E.Data, COUNT(*) AS interventiPerData
    FROM STRUTTURA S, EFFETTUA_INTERVENTO E
    WHERE S.CodS = E.CodS
    AND S.Provincia = 'Torino'
    AND E.Data >= '01/03/2022'
    AND E.Data <= '31/3/2022'
    GROUP BY E.Data),
SELECT I.Data
FROM INTERVENTI_DATA I
WHERE interventiPerData = (
    SELECT MAX(interventiPerData)
    FROM INTERVENTI_DATA);

/*
ESERCIZIO 5

LUOGO (*CodL, Nome, Città, Regione, CapienzaMax)
EVENTO (*CodE, Titolo, Tipo)
EDIZIONE (*CodE, *Data, $CodL, NumeroPartecipanti)

Tra gli eventi per cui sono state organizzate edizioni in almeno 3 città diverse, visualizzare il titolo
dell’evento a cui hanno (considerando tutte le edizioni dell’evento) partecipato complessivamente il
maggior numero di persone
*/

-- Oracle 
WITH TIT_EV_PARTECIPANTI AS (
    SELECT EV.CodE, EV.Titolo, SUM(NumeroPartecipanti) AS totPartecipanti
    FROM EVENTO EV, EDIZIONE ED
    WHERE EV.CodE = ED.CodE
    AND EV.CodE IN (
        SELECT CodE
        FROM EDIZIONE E, LUOGO L
        WHERE L.CodL = E.CodL
        GROUP BY CodE
        HAVING COUNT(DISTINCT L.Città) >= 3)
    GROUP BY EV.CodE, EV.Titolo),
SELECT Titolo
FROM TIT_EV_PARTECIPANTI
WHERE totPartecipanti = (
    SELECT MAX(totPartecipanti)
    FROM TIT_EV_PARTECIPANTI);

/*
ESERCIZIO 6

FILM (*CodF, Titolo, Data_uscita, Genere, DurataMinuti)
CINEMA (*CodC, Nome, Indirizzo, Città)
SALA (*CodC, *NumeroSala, Capienza)
PROIEZIONE (*CodC, *NumeroSala, *Data, *OraInizio, OraFine, CodF)

Visualizzare il titolo di ciascun film che ha una durata inferiore della durata media dei film
appartenenti allo |stesso genere|, e che è stato proiettato un numero di volte maggiore del numero
medio di proiezioni dei film appartenenti allo |stesso genere|.
*/

-- PER OGNI FILM IL NUMERO DI PROIEZIONI
WITH FILM_nPROIEZIONI AS (
    SELECT F.CodF, F.Titolo, F.DurataMinuti, F.Genere, COUNT(P.CodC, P.NumeroSala, P.Data, P.OraInizio) AS NumeroProiezioni
    FROM FILM F, PROIEZIONE P
    WHERE F.CodF = P.CodF
    GROUP BY F.CodF, F.Titolo, F.DurataMinuti, F.Genere),
SELECT Titolo
FROM FILM_nPROIEZIONI CTE1
WHERE DurataMinuti < (
    SELECT AVG(CTE2.DurataMinuti)
    FROM FILM_nPROIEZIONI CTE2
    WHERE CTE1.Genere = CTE2.Genere)
AND NumeroProiezioni > (
    SELECT AVG(NumeroProiezioni)
    FROM FILM_nPROIEZIONI CTE3
    WHERE CTE3.Genere = CTE1.Genere);

-- soluzione corretta
WITH PROIEZIONI_FILM AS(
    SELECT F.CodF, Titolo, Genere, COUNT (*) AS N
    FROM PROIEZIONE P, FILM F
    WHERE P.CodF=F.CodF
    GROUP BY F.CodF, Genere)
DURATA_GENERE AS(
    SELECT Genere, AVG(Durata) AS DurataMedia
    FROM FILM F
    GROUP BY Genere)
PROIEZIONI_GENERE AS (
    SELECT Genere, AVG(N) AS MediaGenere
    FROM PROIEZIONI_FILM
    GROUP BY Genere),
SELECT Titolo
FROM PROIEZIONI_FILM P, DURATA_GENERE D, PROIEZIONI_GENERE G
WHERE D.Genere = F.Genere
AND G.Genere = P.Genere 
AND Durata < DurataMedia
AND N > MediaGenere;