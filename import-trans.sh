#!/bin/bash -x
######################################################################
# Import translations from Transifex and reload Apache running Horizon
######################################################################

HORIZON_REPO=/opt/stack/horizon
TX_THRESH=30
TX_FORCE_FETCH=1
TX_CMD=/usr/local/bin/tx
TX_OPTS="-a --minimum-perc=$TX_THRESH"
DO_GIT_PULL=1

TOP_DIR=$(cd $(dirname "$0") && pwd)

if [ "$TX_FORCE_FETCH" -ne 0 ]; then
  TX_OPTS+=" -f"
fi

cd $HORIZON_REPO

git checkout -- horizon/locale/
git checkout -- openstack_dashboard/locale/
git status | grep django.mo | xargs rm
git status | grep djangojs.mo | xargs rm
git status | grep django.po | xargs rm
git status | grep djangojs.po | xargs rm
git status | grep /locale/ | xargs rm -rf

if [ "$DO_GIT_PULL" -ne 0 ]; then
  git branch --set-upstream-to=origin/master master
  git pull
  sudo pip install -e .
fi

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
