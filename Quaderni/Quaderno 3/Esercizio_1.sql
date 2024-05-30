/*
Per ogni autore che ha pubblicato almeno 3 libri di genere 'Fantascienza', 
ma che non ha mai pubblicato nessun libro di genere 'Horror' o 'Giallo', 
visualizzare il nome e cognome dell'autore e,
per ciascun libro pubblicato, il titolo, il genere e il numero totale di copie pubblicate 
di quel libro.
*/

-- Risultato finale
SELECT A.Nome, A.Cognome, L.Titolo, L.Genere, P.NumeroCopie
FROM AUTORI_LIBRO AL
JOIN AUTORE A ON A.CodAutore = AL.CodAutore
JOIN LIBRO L ON L.CodL = AL.CodL
JOIN PUBBLICAZIONE P ON P.CodL = AL.CodL
WHERE AL.CodA IN (
    SELECT A.CodAutore  -- Selezionare ogni autore che ha pubblicato almeno 3 libri di genere 'Fantascienza'
    FROM AUTORI_LIBRO A
    JOIN LIBRO L ON L.CodLibro = A.CodLibro
    WHERE L.Genere = 'Fantascienza'
    GROUP BY CodAutore
    HAVING COUNT(A.CodLibro) >= 3)
AND AL.CodA NOT IN (
    SELECT A.CodAutore  -- Selezionare gli autori che pubblicato libri di genere 'Horror' o 'Giallo'
    FROM AUTORI_LIBRO A
    JOIN LIBRO L ON L.CodLibro = A.CodLibro
    WHERE L.Genere = 'Horror' OR L.Genere = 'Giallo'
    GROUP BY A.CodAutore)