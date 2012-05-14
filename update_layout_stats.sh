#!/bin/sh

BASE=~/dev/scripts

$BASE/getlayouts.py
$BASE/generatereport.py
cp -R $BASE/results $BASE/qtlinuxrelease_results.html /var/www/lauro/stats
