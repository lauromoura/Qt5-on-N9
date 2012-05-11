#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import urllib2
import re
import BeautifulSoup
import json


REVISIONS_URL = 'http://build.webkit.org/builders/Qt%20Linux%20Release?numbuilds=50'
TESTRUN_URL = 'http://build.webkit.org/builders/Qt%%20Linux%%20Release/builds/%s/steps/layout-test/logs/stdio/text'

regex = re.compile("^[\d\:\.]* \d* Expect:\s*(\d*) (\w*).*", re.MULTILINE)


def getWebKitBuildingRevisions():
    data = urllib2.urlopen(REVISIONS_URL).read()
    soup = BeautifulSoup.BeautifulSoup(data)

    table = soup.find("table")
    rows = table.findAll('tr')
    for row in rows:
        cols = row.findAll('td')
        if len(cols) != 5:
            continue
        revision = cols[1].span.a.text
        build = cols[3].a.text.replace("#", "")
        if cols[2].text == 'success':
            yield revision, build


def getRevisionTestStats(revision, build):
    url = TESTRUN_URL % build
    log = urllib2.urlopen(url).read(4000)

    data = regex.findall(log)

    return sorted((kind, number) for number, kind in data)
    

def main():

    data = []
    for revision, build in getWebKitBuildingRevisions():
        print revision
        data.append((revision, build, getRevisionTestStats(revision, build)))

    with open('results.json', 'w') as output:
        json.dump(data, output)


if __name__ == '__main__':

    main()
