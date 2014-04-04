#!/bin/bash

######################################################################
# Just Update POT files in Horizon (e.g. for tx push -s)
######################################################################

DIR_REPO=$HOME/horizon
BRANCH=master
PULL=0

function usage {
  echo "Usage: $0 [--branch|-b branch] [--pull] [-h]"
  exit 1
}

while true; do
  if [ -z "$1" ]; then
    break
  fi
  case "$1" in
    -b|--branch) BRANCH=$2; shift;;
    --pull) PULL=1;;
    *) usage;;
  esac
  shift
done

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
if [ $PULL -eq 1 ]; then
  git pull
fi

./run_tests.sh -N --makemessages

POFILES=$(ls */locale/en/LC_MESSAGES/*.po)
for f in $POFILES; do
  check_updated $f
done

if ! git status | grep modified: >/dev/null; then
  echo "***** No changes in PO files *****"
  exit 1
fi
