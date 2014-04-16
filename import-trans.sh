#!/bin/bash -x
######################################################################
# Import translations from Transifex and reload Apache running Horizon
######################################################################

HORIZON_REPO=/opt/stack/horizon
TX_FORCE_FETCH=1
TX_CMD=/usr/local/bin/tx
TX_OPTS="-a --minimum-perc=20"
DO_GIT_PULL=0

if [ "$TX_FORCE_FETCH" -ne 0 ]; then
  TX_OPTS+=" -f"
fi

cd $HORIZON_REPO
if [ "$DO_GIT_PULL" -ne 0 ]; then
  git pull
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

sudo service apache2 reload
