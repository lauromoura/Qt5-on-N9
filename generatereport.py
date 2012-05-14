#!/usr/bin/env python
# -*- coding: utf-8 -*-


import json
import os
from jinja2 import Environment, FileSystemLoader

def main():

    bot = "Qt Linux Release"
    botname = bot.replace(" ", "").lower()

    path = os.path.dirname(os.path.abspath(__file__))
    print path
    outfilename = os.path.join(path, '%s_results.html' % botname)

    env = Environment(loader=FileSystemLoader(os.path.join(path, 'templates')))
    template = env.get_template('gchart_template.html')
    with open(outfilename, 'w') as output:
        output.write(template.render(bot=bot, botname=botname))

if __name__ == '__main__':
    main()
