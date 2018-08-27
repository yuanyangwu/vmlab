#!/usr/bin/python3

# deploy Kafka in standalone and cluster mode

from string import Template
import sys

def generateTemplate(path):
    with open(path, 'r') as content_file:
        content = content_file.read()
        return Template(content)

if len(sys.argv) < 2:
    usage = """gen_by_template.py <file> [key1=value1] [key2=value2] ..."""
    sys.exit(usage)

file = sys.argv[1]
props = {}
for item in sys.argv[2:]:
    key, value = item.split("=")
    props[key] = value

template = generateTemplate(file)
output = template.substitute(props)
print(output)