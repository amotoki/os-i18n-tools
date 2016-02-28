#!/bin/bash
######################################################################
# Import translations from Transifex and reload Apache running Horizon
######################################################################

RELEASE=master
ZANATA_VERSION=master
DEVSTACK_DIR=/opt/stack
THRESH=30

DO_GIT_PULL=1

PROJECTS="horizon trove-dashboard sahara-dashboard"

TOP_DIR=$(cd $(dirname "$0") && pwd)

. /usr/local/jenkins/slave_scripts/common_translation_update.sh

usage_exit() {
    set +o xtrace
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -r RELEASE : Specify release name in lower case (e.g. liberty, mitaka, ...)"
    echo "               (Default: $RELEASE)"
    echo "  -b BRANCH  : Specify a target branch name."
    echo "               If unspecified, it will be stable/RELEASE."
    echo "               (Default: stable/$RELEASE)"
    echo "  -m THRESH  : Minimum percentage of a translation (Default: $THRESH)"
    exit 1
}

parse_opts() {
    while getopts b:d:m:r:h OPT; do
        case $OPT in
            b) TARGET_BRANCH=$OPTARG ;;
            m) THRESH=$OPTARG ;;
            r) RELEASE=$OPTARG ;;
            h) usage_exit ;;
            \?) usage_exit ;;
        esac
    done

    if [ ! -n "$TARGET_BRANCH" ]; then
      if [ "$RELEASE" = "master" ]; then
        TARGET_BRANCH=$RELEASE
        ZANATA_VERSION=master
      else
        TARGET_BRANCH=stable/$RELEASE
        ZANATA_VERSION=stable-$RELEASE
      fi
    fi
}

check_zanata_cli() {
    local ZANATA_CMD=`which zanata-cli`
    if [ ! -n "$ZANATA_CMD" ]; then
      echo "'$ZANATA_CMD' command not found"
      exit 1
    fi
}

pull_project() {
    local project=$1
    cd $DEVSTACK_DIR/$project
    module_names=$(get_modulename $project django)
    if [ ! -n "$module_names" ]; then
        return
    fi
    setup_project $project $ZANATA_VERSION $module_names

    zanata-cli -B pull -e --min-doc-percent 30

    for module in "$module_names"; do
        cd $module
        DJANGO_SETTINGS_MODULE=openstack_dashboard.settings ../manage.py compilemessages
        cd -
    done
}

cleanup_project() {
    local project=$1
    cd $DEVSTACK_DIR/$project
    git checkout -- horizon/locale/
    git checkout -- openstack_dashboard/locale/
    git status | grep django.mo | xargs --no-run-if-empty rm -v
    git status | grep djangojs.mo | xargs --no-run-if-empty rm -v
    git status | grep django.po | xargs --no-run-if-empty rm -v
    git status | grep djangojs.po | xargs --no-run-if-empty rm -v
    git status | grep /locale/ | xargs --no-run-if-empty rm -v -rf
}

update_project() {
    local project=$1
    cd $DEVSTACK_DIR/$project
    if [ "$DO_GIT_PULL" -ne 0 ]; then
        git branch --set-upstream-to=origin/$TARGET_BRANCH $TARGET_BRANCH
        git checkout $TARGET_BRANCH
        git pull
        sudo pip install -e .
    fi
}

reload_horizon() {
    # Update LANGUAGES list in horizon settings
    $TOP_DIR/update-lang-list.sh

    DJANGO_SETTINGS_MODULE=openstack_dashboard.settings python manage.py collectstatic --noinput
    DJANGO_SETTINGS_MODULE=openstack_dashboard.settings python manage.py compress --force
    sudo service apache2 reload
}

# ----------------------------------------
# Main logic
# ----------------------------------------

logger -i -t `basename $0` "Started ($*)"

parse_opts

set -o xtrace

check_zanata_cli

for PROJECT in $PROJECTS; do
    cleanup_project $PROJECT
    update_project $PROJECT
    pull_project $PROJECT
done

reload_horizon

logger -i -t `basename $0` "Completed."
