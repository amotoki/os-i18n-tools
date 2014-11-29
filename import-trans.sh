#!/bin/bash
######################################################################
# Import translations from Transifex and reload Apache running Horizon
######################################################################

RELEASE=juno
HORIZON_REPO=/opt/stack/horizon
TX_THRESH=30
TX_FORCE_FETCH=1

#TX_CMD=/usr/local/bin/tx
TX_OPTS="-a --minimum-perc=$TX_THRESH"
DO_GIT_PULL=1

usage_exit() {
    set +o xtrace
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -r RELEASE : Specify release name in lower case (e.g. juno, icehouse, ...)"
    echo "               (Default: $RELEASE)"
    echo "  -b BRANCH  : Specify a target branch name."
    echo "               If unspecified, it will be stable/RELEASE."
    echo "               (Default: stable/$RELEASE)"
    echo "  -d WORKDIR : Horizon working git repo (Default: $HORIZON_REPO)"
    echo "  -m THRESH  : Minimum percentage of a translation (Default: $TX_THRESH)"
    exit 1
}

while getopts b:d:m:r:h OPT; do
    case $OPT in
        b) TARGET_BRANCH=$OPTARG ;;
        d) HORIZON_REPO=$OPTARG ;;
        m) TX_THRESH=$OPTARG ;;
        r) RELEASE=$OPTARG ;;
        h) usage_exit ;;
        \?) usage_exit ;;
    esac
done

if [ ! -n "$TARGET_BRANCH" ]; then
  if [ "$RELEASE" = "master" ]; then
    TARGET_BRANCH=$RELEASE
  else
    TARGET_BRANCH=stable/$RELEASE
  fi
fi

set -o xtrace

setup_tx_config() {
    local release=$1
    local slug
    if [ "$release" = "master" ]; then
      slug=translations
    else
      slug=translations-$release
    fi
    if `grep "$slug\]" .tx/config >/dev/null`; then
        # .tx/config already has resoruce entries for the targeted release
        return
    fi
    # If not, modify .tx/config from the existing .tx/config
    sed -i -e "s|translations\(-[a-z]\+\)\?\]$|$slug\]|" .tx/config
}

TX_CMD=`which tx`
if [ ! -n "$TX_CMD" ]; then
  echo "Transifex 'tx' command not found"
  exit 1
fi

TOP_DIR=$(cd $(dirname "$0") && pwd)

if [ "$TX_FORCE_FETCH" -ne 0 ]; then
  TX_OPTS+=" -f"
fi

cd $HORIZON_REPO

git checkout -- .tx
git checkout -- horizon/locale/
git checkout -- openstack_dashboard/locale/
git status | grep django.mo | xargs rm
git status | grep djangojs.mo | xargs rm
git status | grep django.po | xargs rm
git status | grep djangojs.po | xargs rm
git status | grep /locale/ | xargs rm -rf

if [ "$DO_GIT_PULL" -ne 0 ]; then
  git branch --set-upstream-to=origin/$TARGET_BRANCH $TARGET_BRANCH
  git checkout $TARGET_BRANCH
  git pull
  sudo pip install -e .
fi

setup_tx_config $RELEASE

$TX_CMD pull $TX_OPTS

cd horizon
../manage.py compilemessages
cd ..
cd openstack_dashboard
../manage.py compilemessages
cd ..

rm -f horizon/locale/en/LC_MESSAGES/django.mo
rm -f horizon/locale/en/LC_MESSAGES/djangojs.mo
rm -f openstack_dashboard/locale/en/LC_MESSAGES/django.mo

$TOP_DIR/update-lang-list.sh

sudo service apache2 reload
