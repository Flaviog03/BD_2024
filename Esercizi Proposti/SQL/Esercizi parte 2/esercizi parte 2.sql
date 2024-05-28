/*
-- ESERCIZIO 1
GARA (CodG, Luogo, Data, Disciplina)
ATLETA (CodA, Nome, Nazione, DataNascita)
PARTECIPAZIONE (CodG, CodA,PosizioneArrivo, Tempo)
*/

-- Trovare il nome e la data di nascita degli atleti italiani che non hanno partecipato a
-- nessuna gara di discesa libera.

SELECT A.Nome, A.DataNascita
FORM ATLETA A
WHERE A.Nazione = 'Italia'
AND A.CodA NOT IN 
    (SELECT P.CodA
    FROM PARTECIPAZIONE P, GARA G
    WHERE G.CodG = P.CodG
    AND Disciplina = 'Discesa libera');

-- Trovare le nazioni per cui concorrono almeno 5 atleti nati prima del 1980, ciascuno dei
-- quali abbia partecipato ad almeno 10 gare di sci di fondo.

-- PRIMA SOLUZIONE (MIA)
WITH CTE1 AS    -- Trovo atleti che hanno partecipato ad almeno 10 gare di scii di fondo
    (SELECT P.CodA
    FROM PARTECIPAZIONE P, GARA G
    WHERE P.CodG = G.CodG
    AND G.Disciplina = 'sci di fondo'
    GROUP BY P.CodA
    HAVING COUNT(P.*) >= 10)
SELECT A.Nazione    -- Nazioni che hanno almeno 5 atleti nati prima del 1980
FROM ATLETA A, CTE1
WHERE A.CodA = CTE1.CodA
AND A.DataNascita < '01/01/1980'
GROUP BY A.Nazione
HAVING COUNT(A.CodA) >= 5;

-- Seconda soluzione (DOPO AVER VISTO QUELLA DEI RISULTATI)
SELECT Nazione
FROM ATLETA
WHERE DataNascita < '01/01/1980'
AND CodA IN(
    SELECT P.CodA
    FROM PARTECIPAZIONE P, GARA G
    WHERE P.CodG = G.CodG
    AND G.Disciplina = 'Sci di fondo'
    GROUP BY P.CodA
    HAVING COUNT(*) >= 10)
GROUP BY Nazione
HAVING COUNT(*) >= 5;

/*
-- Esercizio 2

EDITORE (*CodE, NomeEditore, Indirizzo, Città)
PUBBLICAZIONE (*CodP, Titolo, NomeAutore, CodE)
LIBRERIA (*CodL, NomeLibreria, Indirizzo, Città)
VENDITA (*CodP, *CodL, *Data, CopieVendute)
*/

-- A) Trovare il nome delle librerie in cui non è stata venduta nessuna pubblicazione di editori
-- con sede a Torino
SELECT NomeLibreria
FROM LIBRERIA
WHERE CodL NOT IN(
    SELECT V.CodL
    FROM VENDITA V, PUBBLICAZIONE P, EDITORE E
    WHERE V.CodP = P.CodP AND E.CodE = P.CodE
    AND E.Città = 'Torino'
    GROUP BY V.CodL);

-- B) Trovare il nome degli editori per cui almeno 10 pubblicazioni sono state vendute nel
-- 2002 nelle librerie di Roma in più di 2.000 copie.

SELECT E.NomeEditore
FROM EDITORE E, PUBBLICAZIONE P
WHERE E.CodE = P.CodE
AND P.CodP IN(
    SELECT CodP
    FROM VENDITA V, LIBRERIA L
    WHERE Data >= '01/01/2002' AND Data <= '31/12/2002'
    AND Città = 'Roma'
    AND V.CodL = L.CodL
    AND CopieVendute > 2000)
GROUP BY E.NomeEditore
HAVING COUNT(P.CodP) >= 10;

/*
-- Esercizio 3

QUIZ (CodQuiz, Argomento, Punteggio)
STUDENTE (Matricola, Nome, Indirizzo, Città)
RISULTATO_TEST (Matricola, CodQuiz, RispostaCorretta)

*/

-- A) Trovare il nome degli studenti che non hanno risposto correttamente 
--    a nessun quiz di matematica.
SELECT Nome
FROM STUDENTE
WHERE Matricola NOT IN(
    SELECT R.Matricola  -- Seleziono le mat. degli studenti che hanno risposto correttamente ad almeno un quiz di matematica
    FROM RISULTATO_TEST R, QUIZ Q
    WHERE R.CodQuiz = Q.CodQuiz
    AND Argomento = 'Matematica'
    AND RispostaCorretta = 'Si');

-- B) Trovare il nome degli studenti di Torino che hanno conseguito il punteggio massimo
-- possibile nei quiz di matematica
WITH CTE1 AS(
    SELECT SUM(Punteggio) AS maxPunteggio
    FROM QUIZ
    WHERE Argomento = 'Matematica')
-- Per ogni matricola mostrare il punteggio ottenuto nei quiz di matematica
SELECT S.Nome
FROM STUDENTE S, RISULTATO_TEST R, QUIZ Q, CTE1
WHERE R.CodQuiz = Q.CodQuiz AND R.Matricola = S.Matricola
AND Q.Argomento = 'Matematica'
AND RispostaCorretta = 'Si'
AND S.Città = 'Torino'
GROUP BY S.Nome
HAVING SUM(Punteggio) = maxPunteggio

/*
AEREI (*Matr, Modello, NumPosti)
ORARIO (*Sigla, ParteDa, Destinaz, OraPart, OraArr)
VOLI (*Sigla, *Matr, Data, *PostiPren)

a) Trovare la sigla e l’ora di partenza dei voli in partenza da Milano per Napoli il 1
ottobre 1993, che dispongono ancora di posti liberi e la cui durata (differenza tra
l’ora di arrivo e l’ora di partenza) è inferiore alla durata media dei voli da Milano
a Napoli.
*/


SELECT O.Sigla, O.OraPart
FROM ORARIO O, VOLI V, AEREI A
WHERE A.Matr = V.Matr AND O.Sigla = V.Sigla
AND V.PostiPren < A.NumPosti
AND ParteDa = 'Milano' AND Destinaz = 'Napoli'
AND Data = '01/10/1993'
GROUP BY O.Sigla, O.OraPart
HAVING (OraArr - OraPart) < (SELECT AVG(OraArr - OraPart) -- Durata media voli da milano
                            FROM ORARIO
                            WHERE ParteDa = 'Milano' AND Destinaz = 'Napoli');

/*
ESERCIZIO 4)

MECCANICO (*MatrM, NomeM)
SA_RIPARARE (*MatrM, *TipoGuasto)
EFFETTUA_RIPARAZIONE (*CodR, *MatrM, Targa, Data, Durata, TipoGuasto)
*/

-- A) Trovare il nome dei meccanici che hanno effettuato almeno una riparazione di
-- un guasto che non sapevano riparare

-- Estraggo da EFFETTUA_RIPARAZIONE (MATRM, TIPOGUASTO) con il costruttore di tupla
-- Conto quante tuple sono presenti in SA_RIPARARE con i valori estratti
-- HAVING COUNT(RIS) = 0    // Significa che non poteva fare la riparazione

SELECT NomeM
FROM MECCANICO M, SA_RIPARARE S
WHERE M.MatrM = S.MatrM
AND (S.MatrM, S.TipoGuasto) NOT IN
    (SELECT (MatrM, TipoGuasto)
    FROM EFFETTUA_RIPARAZIONE);

/*
Per le autovetture per cui sono state necessarie riparazioni effettuate da almeno
3 meccanici diversi nello stesso giorno, visualizzare la targa dell’autovettura, la
data delle riparazioni e i tipi di guasto che si sono verificati, ordinando il risultato
in ordine crescente di targa e decrescente di data.
*/

-- voglio estrarre la coppia (targa, data) dalle tuple di EFFETTUA_RIPARAZIONE 
-- che hanno COUNT(DISTINCT MatrM) >= 3, per garantire che le riparazioni si riferiscano tutte allo
-- stesso giorno raggruppo per (targa, data)

SELECT Targa, Data, TipoGuasto
FROM EFFETTUA_RIPARAZIONE
WHERE (Targa, Data) IN(
    SELECT (Targa, Data)
    FROM EFFETTUA_RIPARAZIONE
    GROUP BY Targa, Data
    HAVING COUNT(DISTINCT MatrM) >= 3)
ORDER BY Targa ASC, Data DESC;

/*
SALA_RIUNIONI (*CodS, NumeroMaxPosti, Proiettore)
PRENOTAZIONE_SALA (*CodS, *Data, *OraInizio, OraFine, CodDip)
DIPENDENTE (*CodDip, Nome, Cognome, DataNascita, Città)

a) Visualizzare il codice e il numero massimo di posti delle sale dotate di proiettore che sono state
prenotate almeno 15 volte per riunioni che iniziano prima delle ore 15:00, ma non sono mai
state prenotate per riunioni che cominciano dopo le ore 20:00.
*/

-- Query finale
SELECT CodS, NumeroMaxPosti
FROM SALA_RIUNIONI
WHERE Proiettore = 'Si'
AND CodS IN
    (SELECT CodS    -- seleziona da PRENOTAZIONE_SALA il Codice Sale con almeno 15 record dove OraInizio < 15:00
    FROM PRENOTAZIONE_SALA
    WHERE OraInizio < '15:00'
    GROUP BY CodS
    HAVING COUNT(*) >= 15)
AND CodS NOT IN(
    SELECT CodS -- seleziona da PRENOTAZIONE_SALA il Codice Sale dove OraInizio > 20:00
    FROM PRENOTAZIONE_SALA
    WHERE OraInizio > '20:00');

/*
B) Visualizzare per ogni sala il codice della sala, il numero massimo di posti e il
numero di prenotazioni considerando solo l’ultima data in cui la sala è stata
prenotata
*/

SELECT S.CodS, S.NumeroMaxPosti, COUNT(P1.*) AS nPrenotazioni
FROM SALA_RIUNIONI S, PRENOTAZIONE_SALA P1
WHERE S.CodS = P1.CodS
AND P1.Data = (SELECT MAX(P2.Data)
              FROM PRENOTAZIONE_SALA P2
              WHERE P2.CodS = S.CodS)
GROUP BY S.CodS, S.NumeroMaxPosti;

/*
GUIDA (*CodGuida, Nome, Cognome, Nazionalità)
TIPO_VISITA (*CodTipoVisita, Monumento, Durata, Città)
GRUPPO (*CodGR, NumeroPartecipanti, Lingua)
VISITA_GUIDATA_EFFETTUATA (*CodGR, *Data, *OraI, CodTipoVisita, CodGuida)
*/

-- Tra i monumenti per cui sono state effettuate almeno 10 visite guidate,
-- visualizzare il monumento che è stato visitato complessivamente dal maggior
-- numero di persone

-- Per ogni monumento trovare il numero di persone che l'anno visitato
WITH visitorsPerMonument AS (
    SELECT Monumento, SUM(NumeroPartecipanti) AS totalVisitors
    FROM TIPO_VISITA T, VISITA_GUIDATA_EFFETTUATA V, GRUPPO G
    WHERE T.CodTipoVisita = V.CodTipoVisita
    AND G.CodGR = V.CodGR
    GROUP BY Monumento
    HAVING COUNT(V.*) >= 10),
MaxTotVisitors AS(
    SELECT Monumento, MAX(totalVisitors)
    FROM visitorsPerMonument)
SELECT visitorsPerMonument.Monumento
FROM visitorsPerMonument, MaxTotVisitors
WHERE totalVisitors = MaxTotVisitors.Monumento;

/*
RAGAZZO(*CodFiscale, Nome, Cognome, DataNascita, CittàResidenza)
ATTIVITA’(*CodAttività, NomeA, Descrizione, Categoria)
CAMPO_ESTIVO(*CodCampo, NomeCampo, Città)
ISCRIZIONE_PER_ATTIVITA’_IN_CAMPO_ESTIVO(CodFiscale, CodAttività, CodCampo, DataIscrizione)

b) Visualizzare il nome e cognome del ragazzo che ha partecipato al maggior
numero di campi estivi per l’attività della categoria «Tennis».
*/

WITH CTE1 AS (
    SELECT CodFiscale, COUNT(DISTINCT A.CodAttività) AS numCampiEstivi
    FROM ATTIVITA’ A, ISCRIZIONE_PER_ATTIVITA’_IN_CAMPO_ESTIVO T
    WHERE A.CodAttività = T.CodAttività
    AND A.Categoria = 'Tennis'
    GROUP BY CodFiscale),
CTE2 AS (
    SELECT MAX(numCampiEstivi) AS MAXCAMPIESTIVI
    FROM CTE1)
SELECT R.Nome, R.Cognome
FROM CTE1, RAGAZZO R, CTE2
WHERE CTE1.CodFiscale = R.CodFiscale
AND CTE1.numCampiEstivi = MAXCAMPIESTIVI;
