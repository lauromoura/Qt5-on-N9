#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import urllib2
import BeautifulSoup


URL = 'http://build.webkit.org/builders/Qt%20Linux%20ARMv7%20Release?numbuilds=50'


def getWebKitBuildingRevision():
    data = urllib2.urlopen(URL).read()
    soup = BeautifulSoup.BeautifulSoup(data)

    table = soup.find("table")
    rows = table.findAll('tr')
    for row in rows:
        cols = row.findAll('td')
        if len(cols) != 5:
            continue
        revision = cols[1].span.a.text
        if cols[2].text == 'success':
            return revision
    return None


def main():
    rev = getWebKitBuildingRevision()
    if not rev:
        sys.exit(1)
    print rev

if __name__ == '__main__':

    main()
