/*;
E1  Trovare i dati relativi a tutti i fattorini della ditta.
*/

SELECT *
FROM FATTORINO;

/*;
E2  Trovare gli identificativi di tutte le aziende che hanno usufruito dei servizi 
    di fattorini della ditta
*/

SELECT A.AID 
FROM AZIENDA A, FATTORINO F 
WHERE A.FID = F.FID;

/*;
E3  Trovare il nome e il codice di ogni fattorino il cui nome (campo NOME) inizia con la lettera ’B’.
*/

SELECT NOME, FID
FROM FATTORINO 
WHERE NOME LIKE 'B%';

/*;
E4  Trovare il nome, il sesso e il codice identificativo dei fattorini il cui interno (campo TEL) è diverso da 8467 oppure non esiste.
*/

SELECT NOME, SESSO, FID
FROM FATTORINO
WHERE TEL NOT LIKE '%8467%' 
OR TEL IS NULL;

/*;
E5  Trovare il nome e la città di residenza dei fattorini che hanno ricevuto almeno una multa.
*/

SELECT F.NOME, F.CITTA 
FROM FATTORINO F, MULTE M 
WHERE F.FID = M.FID 
ORDER BY F.FID;

/*;
E6  Trovare i nomi e le iniziali (campo INIZIALI) dei referenti di azienda che hanno ricevuto almeno una multa dopo il 31/12/2000 ordinati in ordine alfabetico rispetto al nome
*/

SELECT DISTINCT F.NOME, F.INIZIALI 
FROM FATTORINO F, AZIENDA A, MULTE M 
WHERE F.FID = M.FID 
AND M.FID = A.FID 
AND M.DATA > TO_DATE ('31/12/2000 ','DD/MM/ YYYY ')
ORDER BY F.NOME;

/*;
E7  Trovare gli identificativi delle coppie formate da un’azienda e un fattorino residente a Stratford tra cui ci sono stati almeno due ritiri e una consegna
*/

SELECT F.FID, C.AID
FROM FATTORINO F, CONSEGNA C
WHERE F.CITTA = 'Stratford' AND F.FID = C.FID AND NUMCONSEGNE >= 1 AND NUMRITIRI >=2;

/*;
E8  Trovare gli identificativi dei fattorini (in ordine decrescente) nati dopo il 1982 che hanno effettuato almeno una consegna a una compagnia avente il referente al primo mandato.
*/

SELECT F.FID
FROM FATTORINO F, CONSEGNA C, AZIENDA A
WHERE F.ANNO_NASCITA >= 1982 AND C.NUMCONSEGNE >= 1 AND A.INCARICO = 'primo' AND F.FID = C.FID AND C.AID = A.AID
ORDER BY F.FID DESC;

/*;
E9  Trovare il nome dei fattorini residenti a Inglewood o Stratford che si sono recati presso almeno 2 aziende.
*/

SELECT DISTINCT F.NOME
FROM FATTORINO F, CONSEGNA C
WHERE (F.CITTA = 'Inglewood' OR F.CITTA = 'Stratford') 
AND C.FID = F.FID
GROUP BY F.FID, NOME
HAVING COUNT(DISTINCT C.AID) > 1;

/*;
E10 Per tutti i fattorini di Inglewood che hanno preso almeno due multe, trovare il codice del fattorino e l’importo totale delle multe ricevute.
*/

SELECT F.FID AS CODICE_FATTORINO, SUM(M.COSTO) AS TOTALE_MULTE
FROM FATTORINO F, MULTE M
WHERE F.CITTA = 'Inglewood' 
AND F.FID = M.FID
GROUP BY F.FID
HAVING COUNT(M.MID) > 1;

/*;
E11 Per tutti i fattorini che hanno ricevuto almeno 2 multe e non più di 4, trovare il nome del fattorino e la multa minima pagata.	
*/

SELECT F.NOME, MIN(M.COSTO)
FROM FATTORINO F, MULTE M
WHERE F.FID = M.FID
GROUP BY F.NOME
HAVING COUNT(M.MID) >=2 AND COUNT(M.MID) <= 4;

/*;
E12 Trovare il numero totale di consegne e il numero totale di ritiri effettuati da fattorini non residenti a Stratford il cui cognome (campo NOME) inizia con ’B’.
*/

SELECT SUM(C.NUMCONSEGNE) AS CONSEGNE_TOTALI, SUM(C.NUMRITIRI) AS RITIRI_TOTALI
FROM CONSEGNA C, FATTORINO F
WHERE F.FID = C.FID
AND F.CITTA <> 'Stratford'
AND F.NOME LIKE 'B%';

/*;
E13 Trovare codice identificativo, nome e iniziali (campo INIZIALI) dei fattorini che non hanno mai preso multe.
*/

SELECT DISTINCT F.FID, F.NOME, F.INIZIALI
FROM FATTORINO F, MULTE M
WHERE F.FID NOT IN (SELECT M.FID FROM MULTE M);

/*;
E14 Trovare il codice identificativo di tutti i fattorini che hanno ricevuto almeno una multa da 25 euro e almeno una multa da 30 euro.
*/

SELECT FID
FROM MULTE
WHERE COSTO = 25 
AND FID IN (SELECT FID FROM MULTE WHERE COSTO = 30);

/*;
E15	Trovare codice identificativo e nome dei fattorini che nella stessa data hanno ricevuto più di una multa Trovare il codice identificativo di tutti i fattorini che hanno ricevuto almeno una multa da 25 euro e almeno una multa da 30 euro.
*/

SELECT DISTINCT F.FID, F.NOME
FROM FATTORINO F, MULTE M
WHERE F.FID = M.FID 
GROUP BY F.FID, DATA, F.NOME
HAVING COUNT(M.MID) > 1;

/*;
E16	Trovare per ogni fattorino che ha preso almeno due multe il codice identificativo del fattorino, la data della prima multa e la data dell’ultima multa che ha preso.
*/

SELECT F.FID, MIN(M.DATA), MAX(M.DATA)
FROM FATTORINO F, MULTE M
WHERE F.FID = M.FID
GROUP BY F.FID
HAVING COUNT(M.MID) >= 2;

/*;
E17	Trovare il codice identificativo dei fattorini che si sono recati presso tutte le aziende presenti nella tabella AZIENDA (nota: i fattorini “recatisi” presso un’azienda sono quelli che hanno fatto almeno una consegna o un ritiro presso l’azienda in esame).
*/

SELECT FID
FROM CONSEGNA
GROUP BY FID
HAVING COUNT (*) = (SELECT COUNT (*)
                    FROM AZIENDA)
;

/*;
E18	Trovare il codice identificato dei fattorini che hanno fatto consegne (o ritiri) in almeno un’azienda in cui il fattorino 57 ha fatto delle consegne (o dei ritiri).
*/

SELECT DISTINCT FID
FROM CONSEGNA
WHERE FID <> 57
AND AID IN 
    (SELECT AID 
    FROM CONSEGNA WHERE 
    FID = 57);