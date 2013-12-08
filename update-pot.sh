#!/bin/bash -x

######################################################################
# Update POT files in Horizon
######################################################################

MERGE_UPSTREAM=0
LANG=ja
DIR_REPO=$HOME/horizon
BRANCH=stable/havana
BRANCH_UPSTREAM=origin/stable/havana
TX_CMD=/usr/local/bin/tx

function check_updated() {
  local file=$1
  git diff $file | \
  grep -E '^[-+]' | \
  grep -v -E '^[-+]#:' | \
  grep -v -E '^[-+]"POT-Creation-Date:' | \
  grep -v -E '^(\+\+\+|---) [ab]/' >/dev/null || revert_po_file $file
}

function revert_po_file() {
  echo "$f is unchanged"
  git checkout -- $file
}

cd $DIR_REPO
git checkout $BRANCH
git pull

./run_tests.sh -N --makemessages

POFILES=$(ls */locale/en/LC_MESSAGES/*.po)
for f in $POFILES; do
  check_updated $f
done

if ! git status | grep modified: >/dev/null; then
  echo "***** No changes in PO files *****"
  exit 1
fi
