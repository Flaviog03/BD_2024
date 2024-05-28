/*
ESERCIZIO 1)

STUDENTE (MatrS*, NomeS, Città)
CORSO (CodC*, NomeC, MatrD)
DOCENTE (MatrD*, NomeD)
ESAME (CodC*, MatrS*, Data, Voto)
*/

--1a) Per ogni studente, visualizzare la matricola e il voto massimo, minimo e medio conseguito negli esami
SELECT S.MatrS, MAX(E.Voto), MIN(E.Voto), AVG(E.Voto)
FROM STUDENTE S, ESAME E
WHERE S.MatrS = E.MatrS
GROUP BY S.MatrS;

-- 1c) Per ogni studente che ha una media voti superiore al 28, visualizzare la matricola, il
--     nome e il voto massimo, minimo e medio conseguito negli esami
SELECT S.MatrS, S.NomeS, MAX(E.Voto), MIN(E.Voto), AVG(E.Voto)
FROM STUDENTE S, ESAME E
WHERE S.MatrS = E.MatrS
GROUP BY S.MatrS, S.NomeS
HAVING AVG(E.Voto) > 28;

-- 1D) Per ogni studente della città di Torino che ha una media voti superiore al 28 e
-- ha sostenuto esami in almeno 10 date diverse, visualizzare la matricola,
-- il nome e il voto massimo, minimo e medio conseguito negli esami
SELECT S.MatrS, S.NomeS, MAX(E.Voto), MIN(E.Voto), AVG(E.Voto)
FROM STUDENTE S, ESAME E
WHERE S.MatrS = E.MatrS AND Città = 'Torino'
GROUP BY S.MatrS, S.NomeS
HAVING AVG(E.Voto) > 28 AND COUNT(DISTINCT E.Data) > 10;

/*
ESERCIZIO 2)

PERSONA (*CodFisc, NomeP, DataNascita)
ISTRUTTORE (*CodI, NomeI)
LEZIONE_PRIVATA (*CodFisc, *Data, *Ora, CodI)
*/

-- 2A) Per ogni persona visualizzare il codice fiscale e il numero di lezioni frequentate
SELECT P.CodFisc, COUNT(L.*)
FROM PERSONA P, LEZIONE_PRIVATA L
WHERE P.CodF = L.CodF
GROUP BY P.CodFisc;

--- 2C) Per ogni persona visualizzare il codice fiscale, il nome, il numero di
-- lezioni frequentate e il numero di istruttori (diversi) con cui ha fatto lezione
SELECT P.CodFisc, P.NomeP, COUNT(L.*), COUNT(DISTINCT L.CodI)
FROM PERSONA P, LEZIONE_PRIVATA L
WHERE P.CodF = L.CodF
GROUP BY P.CodFisc, P.NomeP;

-- 2D) Per ogni persona nata dopo il 1970 che ha frequentato almeno 5 lezioni, 
-- visualizzare il codice fiscale, il nome, il numero di lezioni frequentate 
-- e il numero di istruttori (diversi) con cui ha fatto lezione
SELECT P.CodFisc, P.NomeP, COUNT(L.*), COUNT(DISTINCT L.CodI)
FROM PERSONA P, LEZIONE_PRIVATA L
WHERE P.CodF = L.CodF AND EXTRACT(YEAR P.DataNascita) > 1970
GROUP BY P.CodFisc, P.NomeP
HAVING COUNT(L.*) > 5;

/*
ESERCIZIO 3)

CORSO(*CodCorso, NomeC, Anno, Semestre)
ORARIO_LEZIONI(*CodCorso, *GiornoSettimana, *OraInizio, OraFine, Aula) 
*/

-- 3A) Trovare codice corso, nome corso e numero totale di ore di lezione settimanali per i corsi 
-- del terzo anno per cui il numero complessivo di ore di lezione settimanali è superiore
-- a 10 e le lezioni sono in piu` di tre giorni diversi della settimana.

-- Somma ora con giorni diversi
SELECT C.CodCorso, C.NomeC, SUM(OraFine - OraInizio)
FROM CORSO C, ORARIO_LEZIONI O
WHERE C.Anno = 3 AND C.CodCorso = O.CodCorso
GROUP BY C.CodCorso, C.NomeC
HAVING COUNT(DISTINCT GiornoSettimana) > 3 AND SUM(OraFine - OraInizio) > 10;

/*
ESERCIZIO 4)

ALLOGGIO (*CodA, Indirizzo, Città, Superficie, CostoAffittoMensile)
CONTRATTO_AFFITTO (*CodC, DataInizio, DataFine*, NomePersona, CodA)

N.B. Superficie espressa in metri quadri. Per i contratti in corso, DataFine è NULL.
*/

-- A) Trovare il nome delle persone che hanno stipulato più di due contratti
-- di affitto per lo stesso appartamento (in tempi diversi).

SELECT C.NomePersona
FROM CONTRATTO_AFFITTO C
GROUP BY C.CodA, C.NomePersona
HAVING COUNT(A.*) > 2;

/*
B) Trovare, per le città in cui sono stati stipulati almeno 100 contratti,
la città, il costo mensile massimo degli affitti, il costo mensile medio degli affitti,
la durata massima dei contratti, la durata media dei
contratti e il numero totale di contratti stipulati.
*/

SELECT A.Città, MAX(A.CostoAffittoMensile), AVG(CostoAffittoMensile),
         MAX(C.DataFine - C.DataInizio), AVG(C.DataFine - C.DataInizio), 
         COUNT(C.CodC)
FROM ALLOGGIO A, CONTRATTO_AFFITTO C
WHERE A.CodA = C.CodA
GROUP BY A.Città
HAVING COUNT(C.*) >= 100;

-- QUERY ANNIDATE --

/*
ESERCIZIO 2)

ORCHESTRA (*CodO, NomeO, NomeDirettore, NumElementi)
SALA (*CodS, NomeS, Città, Capienza)
CONCERTI (*CodC, Data, CodO, CodS, PrezzoBiglietto)
*/

/*
1A) Trovare il codice e il nome delle orchestre con più di 30 elementi
che hanno tenuto concerti sia a Torino, sia a Milano e non hanno mai tenuto concerti a Bologna.
*/

SELECT O.CodO, O.NomeO
FROM ORCHESTRA
WHERE O.NumElementi > 30
GROUP BY O.CodO, O.NomeO
HAVING O.CodO IN 
    (SELECT C.CodO
    FROM CONCERTI C, SALA S
    WHERE C.CodS = S.CodS AND S.Città = 'Torino')
AND O.CodO IN 
    (SELECT C.CodO
    FROM CONCERTI C, SALA S
    WHERE C.CodS = S.CodS AND S.Città = 'Milano')
AND O.CodO NOT IN 
    (SELECT C.CodO
    FROM CONCERTI C, SALA S
    WHERE C.CodS = S.CodS AND S.Città = 'Bologna');

/*
CORSO (*CodCorso, NomeC, Anno, Semestre)
ORARIO_LEZIONI (*CodCorso, *GiornoSettimana, *OraInizio, OraFine, Aula)

a) Trovare le aule in cui non si tengono mai lezioni di corsi del primo anno
*/
SELECT O.Aula
FROM ORARIO_LEZIONI O
WHERE O.Aula NOT IN (SELECT O.Aula
                         FROM CORSO C, ORARIO_LEZIONI O
                         WHERE ANNO = 1 AND C.CodCorso = O.CodCorso);

/*
ALLOGGIO (*CodA, Indirizzo, Città, Superficie)
CONTRATTO_AFFITTO (*CodC, DataInizio, DataFine*, NomePersona, CodA, RettaMensile)

a) Trovare il nome delle persone che non hanno mai affittato alloggi con superficie superiore a 80
metri quadri.
*/

SELECT C.NomePersona
FROM CONTRATTO_AFFITTO C
WHERE NomePersona NOT IN (SELECT NomePersona
                        FROM CONTRATTO_AFFITTO CA, ALLOGGIO A
                        WHERE A.CodA = CA.CodA AND A.Superficie > 80);

-- Trovare il codice e l’indirizzo degli appartamenti di Torino in cui la retta mensile è
-- sempre stata superiore a 500 euro e per cui sono stati stipulati al più 5 contratti di
-- affitto.

SELECT A.CodA, A.Indirizzo
FROM ALLOGGIO A, CONTRATTO_AFFITTO C
WHERE C.RettaMensile = 500
AND A.CodA NOT IN
    (SELECT CodA
    FROM CONTRATTO-AFFITTO
    WHERE RettaMensile<=500)
GROUP BY A.CodA, A.Indirizzo
HAVING COUNT(C.*) <= 5;

-- Trovare il codice, l’indirizzo e la città degli alloggi che hanno una superficie
-- superiore alla superficie media degli alloggi delle città in cui si trovano.

SELECT A1.CodA, A1.Indirizzo, A1.Città
FROM ALLOGGIO A1
WHERE A1.Superficie > (SELECT AVG(Superficie)
                    FROM ALLOGGIO A2
                    WHERE A1.Città = A2.Città); -- CONDIZIONE DI CORRELAZIONE

/*
AEREI (*Matr, Modello, NumPosti)
ORARIO (*Sigla, CittàPartenza, CittàArrivo, OraPart, OraArr)
VOLI (*Sigla, *Matr, *Data, PostiPren)

a) Trovare le tratte (città di partenza, città di arrivo) che non sono state 
mai effettuate con un aereo modello Boing-747.
*/

SELECT O.CittàPartenza, O.CittàArrivo
FROM ORARIO O
WHERE (O.CittàPartenza, O.CittàArrivo) 
NOT IN  (SELECT O1.CittàPartenza, O1.CittàArrivo
        FROM ORARIO O1, AEREI A1, VOLI V1
        WHERE A1.Modello < > '747'
        AND A.Matr = V.Matr AND O.Sigla = V.Sigla
        AND O.CittàPartenza = O1.CittàPartenza AND O.CittàArrivo = O1.CittàArrivo   -- CONDIZIONE DI CORRELAZIONE
        )

