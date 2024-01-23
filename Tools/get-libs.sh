#!/bin/bash
#
# I think most devs just get curse updater or something to keep the libs
# globally. I don't know if that's a good idea or not. Honestly I feel
# pretty nervous about packaging "the newest version" all the time.
#

indent () {
    sed -e 's/^/    /'
}

get_repotype () {
    case "$1" in
    *://repos.curseforge.com/*)
        echo svn
        ;;
    *://repos.wowace.com/*)
        echo svn
        ;;
    *://svn*)
        echo svn
        ;;
    svn:*)
        echo svn
        ;;
    *://git*)
        echo git
        ;;
    git:*)
        echo git
        ;;
    *)  # I guess
        echo git
        ;;
    esac
}

get_libs () {
    local INLIBS=0
    local FILE
    if [ -f pkgmeta.yaml ]; then
        FILE=pkgmeta.yaml
    else
        FILE=.pkgmeta
    fi

    cat $FILE | while read k v; do
        case $k in
        externals:)
            INLIBS=1
            ;;
        "")
            INLIBS=0
            ;;
        *)
            if [ $INLIBS -eq 1 ]; then
                echo ${v} $( get_repotype $v ) ${k/:/}
            fi
            ;;
        esac
    done
}

update_repo () {
    local repotype=$1
    local dir=$2

    case $repotype in
    git)
        (cd $dir && git pull && git reset --hard)
        ;;
    svn)
        (cd $dir && svn up)
        ;;
    esac
}

fetch_repo () {
    local uri=$1
    local repotype=$2
    local dir=$3

    case $repotype in
    git)
        git clone $uri $dir
        ;;
    svn)
        svn co $uri $dir
        ;;
    esac
}


get_libs | while read uri repotype dir; do
    if [ -d $dir ]; then
        echo "Updating $dir"
        update_repo $repotype $dir 2>&1 | indent
    else
        echo "Cloning $uri into $dir"
        fetch_repo $uri $repotype $dir 2>&1 | indent
    fi
done
