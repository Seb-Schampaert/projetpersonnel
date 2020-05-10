ALTER PROCEDURE "DBA"."getProduits"()
RESULT (id int, lib varchar(20), libUnit varchar(10))
BEGIN
    call sa_set_http_header('Content-Type','application:json; charset=utf-8');
    SELECT prodID, prodLib, unitLib
    FROM tbProduits 
    NATURAL JOIN tbUnites
END

CREATE SERVICE "getProduits"
    TYPE 'JSON'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.getProduits();


ALTER PROCEDURE "DBA"."listUsers"()
RESULT (username char(30), pswd char(30))
BEGIN
    call sa_set_http_header('Content-Type','application:json; charset=utf-8');
    select usrName, usrKey
    from dba.tbUsers
END

CREATE SERVICE "listUsers"
    TYPE 'JSON'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.listUsers();


CREATE PROCEDURE "DBA"."getUserID"(@username varchar(30))
RESULT (userID int)
BEGIN
    call sa_set_http_header( 'Content-Type', 'text/html' );
    select usrID
    FROM tbUsers
    WHERE usrName = @username;
END

CREATE SERVICE "getUserID"
    TYPE 'RAW'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.getUserID(:username);


CREATE PROCEDURE "DBA"."recupererFrigo"(@userID int)
RESULT (lib varchar(16), quant int, libUnit varchar(10))
BEGIN
    call sa_set_http_header('Content-Type','application:json; charset=utf-8');
    SELECT prodLib, prodQuant, unitLib
    FROM tbFrigo
    NATURAL JOIN tbProduits
    NATURAL JOIN tbUnites
    WHERE usrID = @userID;
END

CREATE SERVICE "recupererFrigo"
    TYPE 'JSON'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.recupererFrigo(:userID)



ALTER PROCEDURE "DBA"."ajouterFrigo"(@produits int, @quantite int, @userID int)
--Sebaztyan Schampaert
BEGIN
    declare quant int;
    call sa_set_http_header('Access-Control-Allow-Origin', '*');   

    IF (testFrigo(@produits, @userID)= 'false') --test si la combinaison userId et prodId est deja present dans le frigo
        THEN INSERT INTO tbFrigo(usrID, prodID,prodQuant) values (@userID, @produits, @quantite)--si non, on ajoute normalement
    ELSE 
        BEGIN
            --si oui, on sauvegarde la quantitee precedente et on met a jour le resultat 
            set quant = (select prodQuant from tbFrigo WHERE usrID = @userId AND prodID = @produits);-
            UPDATE tbFrigo SET usrID = @userID, prodID = @produits, prodQuant = @quantite + quant 
            WHERE usrID = @userId AND prodID = @produits;
        END
    endif;
END

CREATE SERVICE "ajouterFrigo"
    TYPE 'RAW'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.ajouterFrigo(:produits, :quantite, :userID)


ALTER PROCEDURE "DBA"."register" (@username varchar(30), @password varchar(30))
RESULT (userID int)
BEGIN
    call sa_set_http_header( 'Content-Type', 'text/html' );
    INSERT INTO tbUsers values
    (DEFAULT, @username, @password);
    SELECT usrID 
    FROM tbUsers
    WHERE usrName = @username;
END

CREATE SERVICE "register"
    TYPE 'RAW'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.register(:username,:password);


ALTER PROCEDURE "DBA"."envoieRecette" (IN numeroRecette INTEGER)
BEGIN 
call sa_set_http_header('Content-Type', 'text/html');
call sa_set_http_header('Access-Control-Allow-Origin', '*');
select prodLib
FROM dba.tbRecettes as t1 
JOIN dba.tbRecettesProduits as t2
ON t1.rctID = t2.rctID
JOIN dba.tbProduits as t3
ON t2.prodID = t3.prodID
WHERE t1.rctID = numeroRecette
END

ALTER PROCEDURE "DBA"."sendRecette" (IN produit VARCHAR(20))
BEGIN
call sa_set_http_header('Content-Type', 'text/html');
call sa_set_http_header('Access-Control-Allow-Origin', '*');
SELECT rctLib, t1.rctID
FROM DBA.tbRecettes as t1
JOIN Dba.tbRecettesProduits as t2
ON t1.rctID = t2.rctID
JOIN dba.tbProduits as t3
ON t2.prodID = t3.prodID
WHERE t3.prodLib = produit
END

--cette fonction permet a la procedure ajouterFrigo de voir si une instance d'un certain produit et user sont deja present
ALTER FUNCTION "DBA"."testFrigo"(@produits int, @userID int)
RETURNS varchar(7)--retourne vrai si il y a deja une instance
BEGIN
    IF EXISTS (SELECT usrID FROM tbFrigo WHERE prodID = @produits AND usrID = @userID)
       THEN return ('true');
    ELSE
       return ('false');
    endif;
END


CREATE procedure "dba"."resetFrigo" (@userID int)
BEGIN
    DELETE FROM tbFrigo WHERE usrID = @userID;
END

CREATE SERVICE "resetFrigo"
    TYPE 'RAW'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.resetFrigo(:userID);








------------------------------
ALTER PROCEDURE "DBA"."listProd"()
RESULT (numID int, lib varchar(16), unite varchar(16))
BEGIN
    call sa¨_set_http_header('Content-Type','application:json; charset=utf-8');
    SELECT prodID, prodLib, unitLib
    FROM tbProduits 
    NATURAL JOIN tbUnites
END

CREATE SERVICE "listProd"
    TYPE 'JSON'
    AUTHORIZATION OFF
    USER "DBA"
    URL ON
    METHODS 'GET'
AS call dba.getUserID()


ALTER PROCEDURE "DBA"."verifierUser"(in @name varchar(30), in @key varchar(20))

RESULT(str varchar(30))
BEGIN
declare @msg varchar(30);
set @msg = 'smth';
call sa_set_http_header('Content-Type','text/html');
call sa_set_http_header('Access-Control-Allow-Origin', '*'); 
--creation de procedure et des headers appropries

--utilisation du exists pour verifier si le nom utilisateur est deja employe
    IF EXISTS (SELECT usrName FROM tbUsers WHERE usrName = @name)
        THEN SELECT (@msg);
    ELSE
      BEGIN
        INSERT INTO DBA.tbUsers (usrID, usrName, usrKey)
         VALUES (DEFAULT, @name, @key);
        SELECT ('wew gj');
      END
    endif;
END


CREATE SERVICE "verifierUser" TYPE 'RAW' AUTHORIZATION OFF USER "DBA" METHODS 'GET' AS call DBA.verifierUser(:name, :key);