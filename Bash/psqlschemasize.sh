#!/bin/bash
set -x
names='<host>'
for name in $names
do
echo "-------------" >> psqlhostsschemasize
echo $name >> psqlhostsschemasize
PGPASSWORD=<password> psql -h $name -U batman -d postgres -c "WITH schemas AS (SELECT schemaname as name, sum(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::bigint as size FROM pg_tables GROUP BY schemaname), db AS (SELECT pg_database_size(current_database()) AS size ) SELECT schemas.name, pg_size_pretty(schemas.size) as schema_size FROM schemas;" >> psqlhostsschemasize
done