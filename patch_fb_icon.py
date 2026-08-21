import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the messy SVG in the empty state
search_svg = r'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11\.5a8\.38 8\.38 0 01-\.9 3\.8 8\.5 8\.5 0 01-7\.6 4\.7 8\.38 8\.38 0 01-3\.8-\.9L3 21l1\.9-5\.7a8\.38 8\.38 0 01-\.9-3\.8 8\.5 8\.5 0 014\.7-7\.6 8\.38 8\.38 0 013\.8-\.9h\.5a8\.48 8\.48 0 018 8v\.5z"/><path d="M12 2l3\.09 6\.26L22 9\.27l-5 4\.87 1\.18 6\.88L12 17\.77l-6\.18 3\.25L7 14\.14 2 9\.27l6\.91-1\.01L12 2z"/></svg>'

replace_svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>'

content = re.sub(search_svg, replace_svg, content)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed empty state icon")