horizon-i18n-tools
==================

Utilities to manage OpenStack Dashboard translations.

* **import-trans.sh**: A script to import Zanata translations into Horizon repo

Prerequisites
-------------

The following translation tools are required.

* gettext: ``apt-get install gettext``
* Zanata CLI: http://zanata-client.readthedocs.org/en/latest/installation/linux-installation/#debian-based-distro

import-trans.sh
---------------

A script to import Zanata translations into Horizon repo.

It is usually used to update translations in the i18n translation check site.

It is originally intended to used with devstack environment, and
the Horizon repository is expected to be in /opt/stack/horizon.

The script does the following:

* Download up-to-date translations from Zanata with >=30% progress
* Compile message catalogs
* Update LANGUAGES settings in Horizon ``openstack_dashboard/settings.py``
* Restart apache2 service

DevStack plugin
---------------

``devstack`` directory is a DevStack plugin which is a complementary tool
to support i18n environment using DevStack.
To use this,

    enable_plugin horizon-i18n-tools https://github.com/amotoki/horizon-i18n-tools.git
