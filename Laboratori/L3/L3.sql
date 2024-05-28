/*E1 Trovare il numero massimo di multe ricevute da un fattorino nella stessa data.*/

SELECT MAX(NumeroMulte)
FROM (SELECT COUNT(*) AS NumeroMulte
 FROM MULTE
 GROUP BY FID, DATA)
;

/*E2 Calcolare il costo totale delle multe ricevute da ciascun fattorino. Quindi, calcolare la
media dei costi totali dei fattorini.*/

SELECT AVG(TOT_MULTE)
FROM (SELECT SUM(M.COSTO) AS TOT_MULTE, F.FID
    FROM MULTE M, FATTORINO F
    WHERE M.FID = F.FID
    GROUP BY F.FID)
    ;

/*;
    E3 Per ogni azienda, trovare l’identificativo del fattorino che ha effettuato più consegne. 
    Divido il problema in due livelli
    - trovare il massimo numero di consegne per azienda
    - trovare il codice del fattorino che ha come numero di consegne il massimo numero di consegne per azienda
*/

SELECT T.AID, C.FID
FROM CONSEGNA C, (SELECT A.AID, MAX(NUMCONSEGNE) AS MAXCONSEGNE
                  FROM CONSEGNA C, AZIENDA A
                  WHERE C.AID = A.AID
                  GROUP BY A.AID) T
WHERE NUMCONSEGNE = T.MAXCONSEGNE
;

/*;
E4  Per ogni azienda, trovare l’identificativo del fattorino maschio e l’identificativo del
    fattorino femmina che hanno effettuato più consegne (se presenti).
    
    Divido il problema in più sottoproblemi:
    - trovare il massimo numero di consegne per azienda per sesso
*/

SELECT T.AID AS CODICE_AZIENDA, C.FID AS CODICE_FATTORINO, T.SESSO, C.NUMCONSEGNE
FROM CONSEGNA C, FATTORINO F, ( SELECT A.AID, F.SESSO, MAX(NUMCONSEGNE) AS MAXCONSEGNE
                    FROM CONSEGNA C, AZIENDA A, FATTORINO F
                    WHERE C.AID = A.AID AND C.FID = F.FID
                    GROUP BY A.AID, F.SESSO) T
WHERE C.AID = T.AID AND F.FID = C.FID AND T.SESSO = F.SESSO
AND C.NUMCONSEGNE = T.MAXCONSEGNE
ORDER BY C.AID ASC;

    /*;
        Tieni a mente che hai controllato che non esistessero fattorini maschi con consegne nella Azienda 2*/

    SELECT *
    FROM CONSEGNA, FATTORINO
    WHERE AID = 2 AND SESSO = 'M' 
    AND FATTORINO.FID = CONSEGNA.FID
    ;

/*;
E5  Selezionare l’identificativo del fattorino, il nome del fattorino e 
    il totale dei costi delle multe ricevute da tutti i fattorini
    per cui il totale dei costi delle multe ricevute è maggiore
    della media dei costi delle multe.

    F.FID, F.NOME, SUM(M.COSTO) TOT_M_RIC
    HAVING TOT_M_RIC > AVG(M.COSTO)
    
    Divido il problema in più sottoproblemi:
    1 trovare il costo medio di ogni multa
        (SELECT AVG(COSTO) AS Costo_medio_multe FROM MULTE)

    2 Per ogni fattorino, l'id, il nome e la somma di tutte le multe che ha preso 

    E mostrarlo se questa è maggiore della media
*/

SELECT F.FID AS CODICE_FATTORINO, F.NOME, SUM(M.COSTO) AS TOTALE_MULTE_PRESE
FROM FATTORINO F, MULTE M
WHERE F.FID = M.FID
GROUP BY F.FID, F.NOME
HAVING SUM(M.COSTO) > (SELECT AVG(COSTO) AS Costo_medio_multe
                             FROM MULTE)
ORDER BY CODICE_FATTORINO ASC;

/*;
E6  Selezionare l’identificativo della multa, la data di ricezione della multa, il costo della
    multa, e il costo medio delle multe nell’anno estratto dalla data di ricezione della multa,
    per tutte le multe per cui il costo è maggiore del costo medio delle multe dell’anno di
    ricezione della multa.

    Divido il problema in più sottoproblemi:
    - Costo medio delle multe per anno
    - Il resto
*/

WITH AVG_FINE_COST_PER_YEAR AS (SELECT AVG(COSTO) AS COSTO_MEDIO, EXTRACT(YEAR FROM DATA) AS ANNO_RIF
                                FROM MULTE
                                GROUP BY(EXTRACT(YEAR FROM DATA)))
SELECT M.MID, M.DATA, M.COSTO, T.COSTO_MEDIO
FROM MULTE M, AVG_FINE_COST_PER_YEAR T
WHERE EXTRACT(YEAR FROM DATA) = T.ANNO_RIF
AND M.COSTO > T.COSTO_MEDIO
ORDER BY M.MID DESC;

/*;
E7  (1) Trovare il numero totale di consegne effettuate da ciascun fattorino. 

    (2) Calcolare la media del numero totale di consegne per tutti i fattorini e
    la media di consegne effettuate dai fattorini per ciascuna città.

    (3) Selezionare le città per cui la media delle consegne dei fattorini
    di quella città è minore della media del numero totale di
    consegne per tutti i fattorini.

    Assunzioni
    - Se vi è un fattorino con Stesso FID, NOME ma AID diverso allora sono due fattorini diversi
*/

WITH ConsegnePerFattorino AS (SELECT FID, SUM(NUMCONSEGNE) AS TOT_CONSEGNE
                              FROM CONSEGNA
                              GROUP BY FID),
MEDIA_CONSEGNE_PER_FATTORINO AS (SELECT AVG(ConsegnePerFattorino.TOT_CONSEGNE) AS MEDIA_CONSEGNE_F
                                 FROM ConsegnePerFattorino),
MEDIA_CONSEGNE_PER_CITTA AS (SELECT F.CITTA, AVG(ConsegnePerFattorino.TOT_CONSEGNE) AS MEDIA_CONSEGNE_C
                             FROM ConsegnePerFattorino, FATTORINO F
                             WHERE F.FID = ConsegnePerFattorino.FID
                             GROUP BY F.CITTA)
SELECT C.CITTA, C.MEDIA_CONSEGNE_C, B.MEDIA_CONSEGNE_F
FROM MEDIA_CONSEGNE_PER_FATTORINO B, MEDIA_CONSEGNE_PER_CITTA C
WHERE C.MEDIA_CONSEGNE_C < B.MEDIA_CONSEGNE_F
ORDER BY C.CITTA ASC;

/*;
E8  Trovare il numero totale di ritiri effettuati da ciascun fattorino. 
    Quindi, individuare l’anno di nascita dei fattorini con la media più alta di ritiri effettuati.
*/

WITH RitiriPerFattorino AS (SELECT FID, SUM(NUMRITIRI) AS NumRitiri
                            FROM CONSEGNA
                            GROUP BY FID
                            ORDER BY FID),
MediaRitiriPerAnno AS (SELECT F.ANNO_NASCITA, AVG(R.NumRitiri) AS MediaRitiri
                            FROM RitiriPerFattorino R, FATTORINO F
                            WHERE F.FID = R.FID
                            GROUP BY F.ANNO_NASCITA
                            ORDER BY F.ANNO_NASCITA)
SELECT M.ANNO_NASCITA
FROM MediaRitiriPerAnno M
WHERE M.MediaRitiri = (SELECT MAX(MediaRitiri)
                       FROM MediaRitiriPerAnno)
                       ;

/*;
E9  Identificare (il genere e il numero di multe) ricevute dal genere dei fattorini con il maggior
    numero di multe presenti nella base dati.

    Divido il problema:
    - Qual è il genere con il maggior numero di multe?
*/

WITH SessoMulte AS (SELECT F.SESSO, COUNT(*) AS NumeroMulte
FROM MULTE M, FATTORINO F
WHERE M.FID = F.FID
GROUP BY F.SESSO)
SELECT SessoMulte.SESSO, SessoMulte.NumeroMulte
FROM SessoMulte
WHERE SessoMulte.NumeroMulte = (SELECT MAX(NumeroMulte)
                                FROM SessoMulte);

/*;
E10 Trovare (il genere e il numero di consegne effettuate) dal genere che ha effettuato il
    maggior numero di consegne.
*/

WITH SessoConsegne AS (
    SELECT F.SESSO, SUM(C.NUMCONSEGNE) AS ConsegneTotali
    FROM FATTORINO F, CONSEGNA C
    WHERE F.FID = C.FID
    GROUP BY F.SESSO
)
SELECT S.SESSO, S.ConsegneTotali
FROM SessoConsegne S
WHERE S.ConsegneTotali = (SELECT MAX(ConsegneTotali)
                          FROM SessoConsegne);