#!/bin/bash -e
############################################################
# Update POT files in OpenStack Dashboard repository
# and create a new commit if there is some update
############################################################

TARGET_BRANCH=master

function is_updated() {
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

cd $HOME/horizon
POFILES=$(ls */locale/en/LC_MESSAGES/*.po)

if git branch | grep "update-source-po"; then
  echo "branch 'update-source-po' already exists. Please check it."
  exit 2
fi

git checkout $TARGET_BRANCH
git pull

# Update PO files

source .venv/bin/activate

cd horizon
echo "horizon:"
../manage.py makemessages -l en --no-obsolete
echo "horizon javascript"
../manage.py makemessages -d djangojs -l en --no-obsolete

cd ../openstack_dashboard
echo "openstack_dashboard"
../manage.py makemessages -l en --ignore=openstack/common/* --no-obsolete

cd ..

deactivate

for f in $POFILES; do
  is_updated $f
done

if ! git status | grep modified: >/dev/null; then
  echo "***** No changes in PO files *****"
  exit 1
fi

git checkout -b "update-source-po"
git add -u
git commit -m "Update English PO files."

echo "-----------------------------------------"
git show --stat | cat
echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!! English PO files are updated. !!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
