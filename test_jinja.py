from jinja2 import Template

data = {'small': {'white': 6.48}}

try:
    t = Template('{{ "%.2f"|format(data.small.white) }}')
    print("Test 1:", t.render(data=data))
except Exception as e:
    print("Test 1 Error:", e)

try:
    t = Template('{{ "%.2f"|format(data["small"]["white"]) }}')
    print("Test 2:", t.render(data=data))
except Exception as e:
    print("Test 2 Error:", e)
