/*
CLIENTE (*CodCliente, NomeC, Cognome, Città)
NEGOZIO (*CodNegozio, NomeN, Indirizzo, Città)
ORDINE (*CodNegozio, *CodCliente, Data, Importo)

Per ogni negozio che ha ricevuto un numero di ordini pari al massimo numero di ordini dei negozi 
della stessa città, visualizzare il nome del negozio, la città del negozio e, 
per ciascun ordine ricevuto, il nome e il cognome del cliente che ha effettuato l'ordine,
la data dell'ordine e l'importo dell'ordine.
*/
WITH ordiniPerCittà AS (
    SELECT Città, COUNT(O.CodNegozio, O.CodCliente) AS numeroOrdini
    FROM ORDINE O, NEGOZIO N
    WHERE N.CodNegozio = O.CodNegozio
    GROUP BY Città),
SELECT N.NomeN, N.Città, C.NomeC, C.Cognome, O.Data, O.Importo
FROM ORDINE O, NEGOZIO N, CLIENTE C
WHERE C.CodCliente = O.CodCliente
AND N.CodNegozio = O.CodNegozio
GROUP BY N.CodNegozio, N.NomeN, N.Città, C.CodCliente, C.NomeC, C.Cognome, O.Data, O.Importo
HAVING COUNT(O.CodNegozio, O.CodCliente) = (
    SELECT MAX(numeroOrdini)
    FROM ordiniPerCittà CTE1
    WHERE CTE1.Città = N.Città);