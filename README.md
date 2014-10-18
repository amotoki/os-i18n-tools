horizon-i18n-tools
==================

Utilities to manage OpenStack Dashboard translations.

* **propose-trans.sh**: A script to download Transifex translations and prepare a patch
* **import-trans.sh**: A script to import Transifex translations into Horizon repo
* **snapshot-trans.sh**: A scirpt to fetch Transifex translation of a given language
  and commit it as a snapshot to Horizon repo

Prerequisites
-------------

The following translation tools are required.

* gettext: ``apt-get install gettext``
* Transifex client: ``pip install transifex-client``

propose-trans.sh
----------------

A script to download Transifex translations and prepare a patch for
stable branches.

Usage:

    $ ~/horizon-i18n-tools/propose-trans.sh -h
    Usage: /home/ubuntu/horizon-i18n-tools/propose-trans.sh [options]
    
    Options:
      -r RELEASE : Specify release name in lower case (e.g. juno, icehouse, ...)
                   (Default: juno)
      -b BRANCH  : Specify a target branch name.
                   If unspecified, it will be stable/RELEASE.
                   (Default: )
      -d WORKDIR : Horizon working git repo (Default: /home/ubuntu/horizon)
      -m THRESH  : Minimum percentage of a translation (Default: 95)

Example:

    ~/horizon-i18n-tools/propose-trans.sh -r juno -m 85
    ~/horizon-i18n-tools/propose-trans.sh -r icehouse

$HOME/horizon is used as a working directory by default.

The script does the following:

* Download up-to-date translations from Transifex with the specified progress
  (the default is 95%).
* Check if all of Horizon django.po, djangojs.po and OpenStack Dashboard django.po
  meet the specified progress. If not, remove such languages.
* Exclude files where the only things which have changed are
  the creation date, the version number, the revision date,
  comment lines, or diff file information.
* Update POT files.
* Compile message catalogs if necessary (Icehouse release is shipped with mo files).

You need to do the following manually.

* Update LANGUAGES settings in ``openstack_dashboard/settings.py``
* Prepare the commit itself (``git commit``)

import-trans.sh
---------------

A script to import Transifex translations into Horizon repo.

It is usually used to update translations in the I18N translation check site.

It is originally intended to used with devstack environment, and
the Horizon repository is expected to be in /opt/stack/horizon.

The script does the following:

* Download up-to-date translations from Transifex with >=30% progress
* Compile message catalogs
* Update LANGUAGES settings in Horizon ``openstack_dashboard/settings.py``
* Restart apache2 service
