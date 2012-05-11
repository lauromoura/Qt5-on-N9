import json
from jinja2 import Environment, FileSystemLoader

def main():
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('template.html')
    data = json.load(open('results.json'))
    with open('results.html', 'w') as output:
        output.write(template.render(bot="Qt Linux Release", data=data))

if __name__ == '__main__':
    main()