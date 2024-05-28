CREATE OR REPLACE TRIGGER AggiornaSalari
AFTER UPDATE OF DNAME ON DIP
FOR EACH ROW
WHEN (OLD.DNAME = 'ACCOUNTING' AND NEW.DNAME = 'SALES')
BEGIN
UPDATE IMP
SET SAL = SAL + 100
WHERE DEPTNO = :OLD.DEPTNO;
END;

/*
Error at line 4: PL/SQL: ORA-00933: SQL command not properly ended Error at line 6: PLS-00103: Encountered the symbol "end-of-file" when expecting one of the following: ( begin case declare end exception exit for goto if loop mod null pragma raise return select update while with <an identifier> <a double-quoted delimited-identifier> <a bind variable> << continue close current delete fetch lock insert open rollback savepoint set sql execute commit forall merge pipe purge json_exists json_value json_query json_object json_array Error at line 2: PL/SQL: SQL Statement ignored	-
*/