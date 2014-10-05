#!/bin/bash

THRESH=95
WORKDIR=$HOME/horizon
BASE_BRANCH=proposed/juno
WORK_BRANCH=translation-imports-for-juno
RELEASE=juno

INCLUDE_MO_FILE=0

TX_PROJECT=horizon
TX_RESOURCES="horizon-translations-$RELEASE openstack-dashboard-translations-$RELEASE horizon-js-translations-$RELEASE"
SOURCE_LANG=en
TX_OPTS=-f

TOP_DIR=$(cd $(dirname $0) && pwd)

get_stats() {
    local resource=$1
    local ofile=/tmp/$$.$resource
    tx --debug pull -r $resource -l $SOURCE_LANG | sed -n '/Statistics response is/,/^}$/p' | sed -e 's/^Statistics response is //' > $ofile
    git checkout -- {horizon,openstack_dashboard}/locale/$SOURCE_LANG/LC_MESSAGES/*.po
}

get_langs_over_thresh() {
    for resource in $TX_RESOURCES; do
	get_stats $TX_PROJECT.$resource
    done
    $TOP_DIR/completion_check.py $THRESH /tmp/$$.$TX_PROJECT.*
    rm -f /tmp/$$.$TX_PROJECT.*
}

setup_horizon_repo_if_nonexist() {
    if [ -d $WORKDIR ]; then
	return
    fi
    git clone git://git.openstack.org/openstack/horizon.git $WORKDIR
}

setup_work_branch() {
    if `git branch | grep $WORK_BRANCH >/dev/null 2>&1`; then
	git checkout $WORK_BRANCH
    else
	git checkout -b $WORK_BRANCH origin/$BASE_BRANCH
    fi
}

setup_tx_config() {
    if `grep translations-$RELEASE .tx/config >/dev/null`; then
	# .tx/config already has resoruce entries for the targeted release
	return
    fi
    # If not, modify .tx/config from the existing .tx/config
    sed -i -e "s|translations\(-[a-z]\+\)\?\]$|translations-$RELEASE\]|" .tx/config
}

cleanup_message_catalogs() {
    git reset HEAD -- horizon/locale/
    git reset HEAD -- openstack_dashboard/locale/
    git checkout -- horizon/locale/
    git checkout -- openstack_dashboard/locale/
    git status | grep django.mo | xargs --no-run-if-empty rm
    git status | grep djangojs.mo | xargs --no-run-if-empty rm
    git status | grep django.po | xargs --no-run-if-empty rm
    git status | grep djangojs.po | xargs --no-run-if-empty rm
    git status | grep /locale/ | xargs --no-run-if-empty rm -rf
}

remove_all_message_catalogs() {
    rm -rf openstack_dashboard/locale/*
    rm -rf horizon/locale/*
    git checkout -- openstack_dashboard/locale/$SOURCE_LANG/
    git checkout -- horizon/locale/$SOURCE_LANG/
}

setup_horizon_repo_if_nonexist
cd $WORKDIR
cleanup_message_catalogs
setup_work_branch
git status
setup_tx_config
if [ $INCLUDE_MO_FILE -ne 1 ]; then
    remove_all_message_catalogs
fi

echo "Checking translation statistics...."
LANGS=$(get_langs_over_thresh | grep -vE "^$SOURCE_LANG\$")

for lang in $LANGS; do
    if [ "$lang" = "$SOURCE_LANG" ]; then
	continue
    fi
    tx pull $TX_OPTS -l $lang
done

if [ $INCLUDE_MO_FILE -eq 1 ]; then
    ./run_tests.sh --compilemessages
fi

git add --all horizon/locale/
git add --all openstack_dashboard/locale/

for lang in $LANGS; do
    if [ "$lang" = "$SOURCE_LANG" ]; then
	continue
    fi
    echo "---------- $lang ----------"
    echo -n "horizon: "
    msgfmt -o /dev/null --statistics horizon/locale/$lang/LC_MESSAGES/django.po
    echo -n "horizon javascript: "
    msgfmt -o /dev/null --statistics horizon/locale/$lang/LC_MESSAGES/djangojs.po
    echo -n "openstack_dashboard: "
    msgfmt -o /dev/null --statistics openstack_dashboard/locale/$lang/LC_MESSAGES/django.po
done

echo
echo "$(echo $LANGS | wc -w) languages have been imported."
