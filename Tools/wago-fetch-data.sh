#!/bin/bash
#
# Fetch some tables in CSV format from wago.tools, import them into sqlite3 and
# then join them together. No effort made (so far) to remove the few dups where
# mounts have condition-dependent display info.
#

set -e

DBFILE=WAGO.sqlite
JSONFILE=WAGO.json

#trap "rm -f $DBFILE" 0

fetch_db2 () {
    for f in Mount MountXDisplay CreatureDisplayInfo CreatureModelData
    do
        echo "=== Fetching $f ===" 1>&2
        local T=`mktemp -p .`
        #curl -s -o $T "https://wago.tools/db2/$f/csv?product=wow"
        curl -s -o $T "https://wago.tools/db2/$f/csv"
        sqlite3 $DBFILE -cmd ".mode csv" ".import $T $f"
        rm -f $T
    done
}

# Listfile is HUGE this takes a long long time
fetch_listfile () {
    echo "=== Fetching listfile ===" 1>&2
    local T=`mktemp -p .`
    echo "ID;FilePath" > $T
    curl -s -L 'https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv' >> $T
    sqlite3 $DBFILE -cmd ".mode csv" ".separator ;" ".import $T listfile"
    rm -f $T
}

make_combined_view () {
    echo "=== Creating view ===" 1>&2
    sqlite3 $DBFILE <<_EOT
        CREATE VIEW MountCombined
        AS SELECT *
            FROM Mount m
            LEFT JOIN MountXDisplay mxd ON m.ID = mxd.MountID
            LEFT JOIN CreatureDisplayInfo cdi ON mxd.CreatureDisplayInfoID = cdi.ID
            LEFT JOIN CreatureModelData cmd ON cdi.ModelID = cmd.ID
            LEFT JOIN listfile l ON cmd.FileDataID = l.ID;
_EOT
}


print_join () {
    local MODE=$1
    sqlite3 $DBFILE -cmd \
        ".mode $MODE" \
        'select * from MountCombined;'
}

fetch_db2
fetch_listfile
make_combined_view
echo "=== Writing $JSONFILE ==="
print_join json | jq . > $JSONFILE
