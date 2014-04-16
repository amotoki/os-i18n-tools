#!/bin/bash -x

THRESH=95
WORKDIR=$HOME/horizon
RELEASE=icehouse
TX_PROJECT=horizon
TX_RESOURCES="horizon-translations-icehouse openstack-dashboard-translations-icehouse horizon-js-translations-icehouse"
SOURCE_LANG=en
TX_OPTS=-f
#TX_OPTS=

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

cd $WORKDIR
LANGS=$(get_langs_over_thresh)
for lang in $LANGS; do
  if [ "$lang" = "en" ]; then
    continue
  fi
  tx pull $TX_OPTS -l $lang
done
./run_tests.sh --compilemessages
git add horizon/locale/
git add openstack_dashboard/locale/
echo $LANGS
echo $LANGS | wc
