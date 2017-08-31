#!/bin/bash

echo $#
if [ $# -lt 1 ]; then
  echo "Usage: $0 <horizon-repo>"
  exit 1
fi

set -x

HORIZON_DIR=$(cd $1 && pwd)

#TOXENVDIR=$2

export LANG=C

function clean_temp_files {
    rm -f $HORIZON_DIR/*/locale/*.pot_
}
trap clean_temp_files EXIT

function filter_pot_file {
    local infile=$1
    local outfile=$2

    msgcat --sort-by-file $infile | \
        grep -v 'Project-Id-Version:' |
        grep -v 'POT-Creation-Date' > $outfile
}

function diff_pot_files {
    local pot_file1=$1
    local pot_file2=$2

    filter_pot_file $pot_file1 ${pot_file1}_
    filter_pot_file $pot_file2 ${pot_file2}_
    diff -u ${pot_file1}_ ${pot_file2}_
}

function get_branch_or_commit {
    if git branch | grep -q '^\* ('; then
        # HEAD is detached
        git rev-parse HEAD
    else
        git branch | grep '^\*' | cut -d ' ' -f 2-
    fi
}

cd $HORIZON_DIR

CUR_BRANCH=$(get_branch_or_commit)
echo $CUR_BRANCH

STASH_HASH=$(git stash create)
git checkout -- .

git checkout HEAD^
python ./manage.py extract_messages --verbosity 0
for module in horizon openstack_dashboard; do
    for domain in django djangojs; do
        mv $module/locale/$domain.pot $module/locale/${domain}_prev.pot
    done
done

git checkout $CUR_BRANCH
if [ -n "$STASH_HASH" ]; then
    git stash store $STASH_HASH
    git stash pop
fi

python ./manage.py extract_messages --verbosity 0

for module in horizon openstack_dashboard; do
    for domain in django djangojs; do
        diff_pot_files \
            $module/locale/${domain}_prev.pot \
            $module/locale/$domain.pot
    done
done > po-files.diff
if which colordiff > /dev/null; then
    colordiff < po-files.diff
else
    cat po-files.diff
fi
