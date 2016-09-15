# OpenStack i18n tools

This repository stores various tools which are related to OpenStack i18n
but are not maintained in the official i18n repository.

This includes:

* glossary management tool
* Horizon translation import from Zanata
* DevStack plugin for Horizon i18n check site

## Glossary management tool

### Preparation

``pip install .``

### Commands

After running pip install, you will have the following commands:

* ``os-i18n-glossary-tool`` converts glossary file format between PO and YAML.
* ``os-glossary-ja-tool`` converts Japanese glossary on OpenStack Wiki to YAML format.

### Workflow to update Japanese glossary

1. Retrieve the source of https://wiki.openstack.org/wiki/I18nTeam/team/ja/glossary
   ("最新版" section only) and save it to ``wiki-ja-glossary.txt`` (example).
2. Convert the glossary from the wiki format to YAML.

       os-glossary-ja-tool wiki-ja-glossary.txt wiki-ja-glossary.yaml

3. Convert the glossary from YAML to PO file (which is the expect format of the i18n repo)

       os-i18n-glossary-tool write-po wiki-ja-glossary.yaml wiki-ja-glossary.po

4. Check the difference:

       msgmerge -N wiki-ja-glossary.po i18n/locale/i18n.pot | \
         diff -u wiki-ja-glossary.po - | colordiff | less -r

   * If some entry is added, there is a new entry in the master glossary.
     In this case, add a new entry to Japanese glossary on OpenStack wiki.
   * If some entry is deleted, there is a new entry in Japanese glossary.
     In this case, propose the new entry to the i18n repo.

5. Copy ``wiki-ja-glossary.po`` to ``i18n/locale/ja/LC_MESSAGES/i18n.po``
   and propose the change to Gerrit.
6. Once the review is merged into the i18n repo, Zanata admin will manually
   upload it to Zanata.

## horizon-i18n-tools

Utilities to manage OpenStack Dashboard translations.

* **import-trans.sh**: A script to import Zanata translations into Horizon repo

### Prerequisites

The following translation tools are required.

* gettext: ``apt-get install gettext``
* Zanata CLI: http://zanata-client.readthedocs.org/en/latest/installation/linux-installation/#debian-based-distro

### import-trans.sh

A script to import Zanata translations into Horizon repo.
It is usually used to update translations in the i18n translation check site.

It is originally intended to used with devstack environment, and
the Horizon repository is expected to be in /opt/stack/horizon.

The script does the following:

* Download up-to-date translations from Zanata with >=30% progress
* Compile message catalogs
* Update LANGUAGES settings in Horizon ``openstack_dashboard/settings.py``
* Restart apache2 service

## DevStack plugin

``devstack`` directory is a DevStack plugin which is a complementary tool
to support i18n environment using DevStack.
To use this,

    enable_plugin horizon-i18n-tools https://github.com/amotoki/horizon-i18n-tools.git
