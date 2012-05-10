#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import urllib2
import re
import BeautifulSoup


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

    print "----------"
    print "Revision %s / build # %s" % (revision, build)
    for number, kind in data:
        print "%s: %s" % (kind, number)



def main():
    for revision, build in getWebKitBuildingRevisions():
        print getRevisionTestStats(revision, build)

if __name__ == '__main__':

    main()
