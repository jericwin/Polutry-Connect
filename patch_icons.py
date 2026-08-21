import re

analytics_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/analytics/analytics.html'
with open(analytics_path, 'r', encoding='utf-8') as f:
    analytics_content = f.read()

dollar_svg_pattern = r'<svg [^>]*><line x1="12" y1="1" x2="12" y2="23"\/><path d="M17 5H9\.5a3\.5 3\.5 0 0 0 0 7h5a3\.5 3\.5 0 0 1 0 7H6"\/><\/svg>'

peso_svg_analytics = '<svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7 21V3h7a5 5 0 0 1 0 10H7"/><path d="M4 9h12"/><path d="M4 13h10"/></svg>'

analytics_content = re.sub(dollar_svg_pattern, peso_svg_analytics, analytics_content)

with open(analytics_path, 'w', encoding='utf-8') as f:
    f.write(analytics_content)


farm_profile_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farm_profile.html'
with open(farm_profile_path, 'r', encoding='utf-8') as f:
    farm_content = f.read()

dollar_svg_farm = r'<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M17 5H9\.5a3\.5 3\.5 0 0 0 0 7h5a3\.5 3\.5 0 0 1 0 7H6"\/><\/svg>'

peso_svg_farm = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7 21V3h7a5 5 0 0 1 0 10H7"/><path d="M4 9h12"/><path d="M4 13h10"/></svg>'

farm_content = re.sub(dollar_svg_farm, peso_svg_farm, farm_content)

with open(farm_profile_path, 'w', encoding='utf-8') as f:
    f.write(farm_content)

print("Icons replaced!")