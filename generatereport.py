import json
from jinja2 import Environment, FileSystemLoader

def main():
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('gchart_template.html')
    bot = "Qt Linux Release"
    botname = bot.replace(" ", "").lower()
    with open('%s_results.html' % botname, 'w') as output:
        output.write(template.render(bot=bot, botname=botname))

if __name__ == '__main__':
    main()