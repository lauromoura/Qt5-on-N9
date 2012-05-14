#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import urllib2
import re
import BeautifulSoup
import json


# TODO Hardcoded bot - Qt Linux Release

REVISIONS_URL = 'http://build.webkit.org/builders/Qt%20Linux%20Release?numbuilds=50'
TESTRUN_URL = 'http://build.webkit.org/builders/Qt%%20Linux%%20Release/builds/%s/steps/layout-test/logs/stdio/text'

regex = re.compile("^[\d\:\.]* \d* Expect:\s*(\d*) (\w*).*", re.MULTILINE)


def getWebKitBuildingRevisions(builds=[]):
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
        if cols[2].text == 'success' and build not in builds:
            yield revision, build
        else:
            print "Skipping build", build, 'not success' if cols[2].text != 'success' else 'alread cached'


def getRevisionTestStats(revision, build):
    url = TESTRUN_URL % build
    log = urllib2.urlopen(url).read(4000)

    data = regex.findall(log)

    return dict((kind, int(number)) for number, kind in data)
    

def main():

    filename = 'results/qtlinuxrelease.json'

    try:
        with open(filename) as handle:
            current_data = json.load(handle)
            builds = [x['build'] for x in current_data]
    except EnvironmentError:
        current_data = []
        builds = []

    new_data = []

    for revision, build in getWebKitBuildingRevisions(builds):
        build_info = {'revision': revision, 'build':build}
        build_info.update(getRevisionTestStats(revision, build))
        new_data.append(build_info)

    new_data.sort(key=lambda info: info['revision'])

    with open(filename, 'w') as output:
        json.dump(current_data + new_data, output)


if __name__ == '__main__':

    main()
