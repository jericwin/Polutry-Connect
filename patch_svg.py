import re

svg_code = '''
<!-- Global SVG Defs for Marketplace Eggs -->
<svg style="width: 0; height: 0; position: absolute;" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="eggGradWhite" cx="30%" cy="30%" r="70%">
      <stop offset="0%" stop-color="#ffffff" />
      <stop offset="100%" stop-color="#f0f0f0" />
    </radialGradient>
    <radialGradient id="eggGradBrown" cx="30%" cy="30%" r="70%">
      <stop offset="0%" stop-color="#f4a460" />
      <stop offset="100%" stop-color="#d2691e" />
    </radialGradient>
    <radialGradient id="eggGradPremium" cx="30%" cy="30%" r="70%">
      <stop offset="0%" stop-color="#ffe4b5" />
      <stop offset="100%" stop-color="#daa520" />
    </radialGradient>
  </defs>
</svg>
'''

base_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/dashboard_base.html'
with open(base_path, 'r', encoding='utf-8') as f:
    base_content = f.read()

# Insert before </body>
base_content = base_content.replace('</body>', svg_code + '\n</body>')
with open(base_path, 'w', encoding='utf-8') as f:
    f.write(base_content)

print("Added SVG defs to dashboard_base.html")