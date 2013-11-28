#!/bin/bash

######################################################################
# Fetch the latest translation from Transifex and commit it to
# the specified horizon git repository if there are any updates.
######################################################################

MERGE_UPSTREAM=0
LANG=ja
DIR_REPO=$HOME/horizon-ja
BRANCH_JA=trans-ja-havana
BRANCH_UPSTREAM=origin/stable/havana
TX_CMD=/usr/local/bin/tx

function check_updated() {
  local file=$1
  git diff $file | \
  grep -E '^[-+]' | \
  grep -v -E '^[-+]#:' | \
  grep -v -E '^[-+]"POT-Creation-Date:' | \
  grep -v -E '^[-+]"PO-Revision-Date:' | \
  grep -v -E '^(\+\+\+|---) [ab]/' >/dev/null || revert_po_file $file
}

function revert_po_file() {
  echo "$f is unchanged"
  git checkout -- $file
}

cd $DIR_REPO
git checkout $BRANCH_JA
$TX_CMD pull -f -l $LANG

POFILES=$(ls */locale/$LANG/LC_MESSAGES/*.po)
for f in $POFILES; do
  check_updated $f
done

if ! git status | grep modified: >/dev/null; then
  echo "***** No changes in PO files *****"
  exit 1
fi

git add -u
git commit -m "Transifex $LANG snapshot $(date +'%Y/%m/%d %H:%M')"

if [ $? -ne 0 ]; then
  echo "No update"
  exit 1
fi
git show --stat | cat

if [ $MERGE_UPSTREAM -ne 0 ]; then
  git remote update
  git merge $BRANCH_UPSTREAM
fi

#git push openstack-ja trans-ja-havana
