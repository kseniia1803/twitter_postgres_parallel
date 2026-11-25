#!/bin/bash

files=$(find data/*)

NORMALIZED_URL=postgresql+psycopg2://postgres:pass@localhost:11442/
NORMALIZED_BATCH_URL=postgresql://postgres:pass@localhost:11443/
DENORMALIZED_URL=postgresql://postgres:pass@localhost:11441/

echo '================================================================================'
echo 'load denormalized'
echo '================================================================================'
time for file in $files; do
    unzip -p "$file" | sed 's/\\u0000//g' | psql "$DENORMALIZED_URL" -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets.py --db="$NORMALIZED_URL" --inputs "$file"
done

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets_batch.py --db="$NORMALIZED_BATCH_URL" --inputs "$file"
done
