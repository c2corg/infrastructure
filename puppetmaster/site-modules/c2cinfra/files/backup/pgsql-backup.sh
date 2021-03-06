#!/bin/sh -e

BKPDIR="/var/backups/pgsql"
BKPFMT="custom"
TODAY=$(date +%F)
DAY=$(date +%A |tr 'A-Z' 'a-z')
MONTH=$(date +%B |tr 'A-Z' 'a-z')
TMPDIR=$(mktemp -d -p $BKPDIR) || exit 1
export PGOPTIONS='-c statement_timeout=0'

pg_dumpall -U postgres --globals-only |bzip2 > $TMPDIR/ACCOUNT-OBJECTS.$TODAY.dump.bz

for i in `psql -U postgres -c "select datname from pg_database where datname <> 'template0'" -t template1`
    do
        pg_dump -U postgres --format=$BKPFMT --create $i |bzip2  > $TMPDIR/$i.$TODAY.dump.bz
    done

test -f $BKPDIR/pgsql_$DAY.tar.gz && rm $BKPDIR/pgsql_$DAY.tar.gz
tar -C $TMPDIR -c -f $BKPDIR/pgsql_$DAY.tar `ls $TMPDIR`
rm -fr $TMPDIR
