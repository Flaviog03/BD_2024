/*
DIPENDENTE (*CodDipendente, Nome, Cognome, Reparto)
PROGETTO (*CodProgetto, Titolo, Descrizione, ScadenzaPrevista)
VALUTAZIONE (*CodDipendente, *CodProgetto, DataConsegna, DataValutazione, Valutazione)

Per ogni dipendente, visualizzare il nome e il cognome del dipendente, 
e il titolo e la descrizione di ciascun progetto per cui il dipendente ha ottenuto una 
valutazione superiore alla valutazione media conseguita dai dipendenti che hanno lavorato 
su quel progetto.
*/

SELECT D.Nome, D.Cognome, P.Titolo, P.Descrizione
FROM VALUTAZIONE V, DIPENDENTE D, PROGETTO P
WHERE D.CodDipendente = V.CodDipendente
AND P.CodProgetto = V.CodProgetto
AND V.Valutazione > (
    SELECT AVG(VAL.Valutazione)
    FROM VALUTAZIONE VAL
    WHERE VAL.CodProgetto = P.CodProgetto); -- Condizione di correlazione