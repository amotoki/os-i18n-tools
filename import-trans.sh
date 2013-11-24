#!/bin/bash -x
######################################################################
# Import translations from Transifex and reload Apache running Horizon
######################################################################

HORIZON_REPO=/opt/stack/horizon
TX_FORCE_FETCH=0

if [ "$TX_FORCE_FETCH" -ne 0 ]; then
  FORCE_OPT="-f"
fi

cd $HORIZON_REPO
git pull

tx pull -a $FORCE_OPT

cd horizon
../manage.py compilemessages
cd ..
cd openstack_dashboard
../manage.py compilemessages
cd ..

rm horizon/locale/en/LC_MESSAGES/django.mo
rm horizon/locale/en/LC_MESSAGES/djangojs.mo
rm openstack_dashboard/locale/en/LC_MESSAGES/django.mo

sudo service apache2 reload
