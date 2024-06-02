/*
PRODOTTO (*CodP, NomeP, Prezzo, PuntiProdotto)
CARTA_FEDELTA’ (*CodC, NomeCliente, PuntiTotali)
ACQUISTO (*CodA, $CodP, Data, $CodC*, NumeroPezzi)
PREMIO (*CodPremio, DescrizPremio, PuntiNecessari)
RICHIESTA_NOTIFICA(*CodN, $CodC, $CodPremio, DescrizPremio) 
*/

/*
(ESERCIZIO 1)
Attribuzione dei punti per un acquisto ed eventuale selezione del premio. Si scriva il trigger per
aggiornare la situazione della carta fedeltà del cliente che ha eseguito l’acquisto. Quando viene
eseguito un nuovo acquisto (inserimento nella tabella ACQUISTO), devono essere aggiornati i
punti totali conseguiti dal cliente. I punti indicati nell’attributo PuntiProdotto sono relativi
all’acquisto di un solo pezzo. 

Per calcolare i punti totali conseguiti nell’acquisto occorre
considerare il numero totale di pezzi acquistati (attributo NumeroPezzi). 

Quando il prodotto non è associato all’acquisizione di punti, l’attributo PuntiProdotto vale zero.
Si noti che gli acquisti non sono necessariamente associati a una carta fedeltà. 
Quando l’acquisto non è associato a una carta
fedeltà, il valore dell’attributo CodC è NULL e non deve essere eseguito alcun aggiornamento
della tabella CARTA_FEDELTA’.

Successivamente, si deve verificare se i punti accumulati consentono di ottenere un premio (ossia
se esiste almeno un premio di valore (attributo PuntiNecessari) inferiore o uguale ai punti totali
accumulati). In caso positivo, deve essere scelto il premio di valore massimo che può essere
ricevuto con i punti accumulati. Si supponga che ci sia al più un premio che soddisfa questa
condizione.

Si deve infine richiedere la notifica (inserimento nella tabella RICHIESTA
NOTIFICA) della possibilità di ricevere il premio selezionato al possessore della carta fedeltà. 
La chiave primaria CodN è un contatore che deve essere incrementato ogni volta che è inserita una
nuova notifica (si tenga conto che le notifiche completamente evase potrebbero essere eliminate
dalla base di dati). 
*/

CREATE OR REPLACE TRIGGER aggiornamentoCarta
AFTER INSERT ON ACQUISTO
FOR EACH ROW
WHEN (:NEW.CodC <> NULL)
DECLARE
    X NUMBER;
    Y NUMBER;
    Z NUMBER;
    descPremio VARCHAR(30);
BEGIN
    -- trovo quanti punti ha il prodotto
    SELECT PuntiProdotto INTO X
    FROM PRODOTTO
    WHERE CodP = :NEW.CodP;

    IF(X > 0) THEN
        -- Aggiorno i punti della carta fedeltà
        UPDATE CARTA_FEDELTA’
        SET PuntiTotali = PuntiTotali + X
        WHERE CodC = :NEW.CodC;

        -- Controllo se con i punti accumulati finora vi è un premio acquisibile
        SELECT P1.CodPremio, P1.DescrizPremio INTO Y, descPremio
        FROM PREMIO P1, CARTA_FEDELTA’ C
        WHERE C.CodC = :NEW.CodC
        AND P1.PuntiNecessari <= C.PuntiTotali
        AND PuntiNecessari = (
            SELECT MAX(P2.PuntiNecessari)
            FROM PREMIO P2);

        IF(Y IS NOT NULL) THEN
            -- Seleziono l'ultimo CodN 
            SELECT MAX(CodN) INTO Z
            FROM RICHIESTA_NOTIFICA;

            IF(Z IS NULL) THEN
                Z := 0;
            END IF;

            -- Mando la notifica
            INSERT INTO RICHIESTA_NOTIFICA(CodN, CodC, CodPremio, DescrizPremio)
            VALUES (Z+1, :NEW.CodC, Y, descPremio);

        END IF;
    END IF;
END;

/*
(ESERCIZIO 2)
Vincolo di integrità sul valore massimo in punti di un prodotto. Per ogni prodotto, il valore in
punti (attributo PuntiProdotto nella tabella PRODOTTO) non può essere superiore a 1/10 del
prezzo di vendita (attributo Prezzo). Si scriva il trigger che gestisce il vincolo d’integrità,
assegnando il valore massimo, pari a 1/10 del prezzo, quando il valore massimo consentito viene
superato. 
*/

CREATE OR REPLACE TRIGGER vincoloPuntiProdotto
BEFORE INSERT OR UPDATE PuntiProdotto ON PRODOTTO
FOR EACH ROW
WHEN (:NEW.PuntiProdotto > (1/10 * :NEW.Prezzo))
BEGIN
    :NEW.PuntiProdotto := (1/10 * :NEW.Prezzo);
END;