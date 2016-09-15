#!/bin/bash -ex

I18N_REPO=../i18n

os-glossary-ja-tool wiki-ja-glossary.txt wiki-ja-glossary.yaml
os-i18n-glossary-tool write-po wiki-ja-glossary.yaml wiki-ja-glossary.po
msgmerge -N wiki-ja-glossary.po $I18N_REPO/i18n/locale/i18n.pot | \
    diff -u wiki-ja-glossary.po - | colordiff | less -r
