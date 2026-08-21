import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Filter button styling to have fixed width
filter_btn_pattern = r'<button type="submit" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1\.5rem; background: var\(--primary\); color: var\(--on-primary\); border: 1px solid transparent; border-radius: 6px; font-weight: 600; cursor: pointer; box-sizing: border-box; font-family: inherit; font-size: 0\.95rem;">'
filter_btn_replacement = '<button type="submit" style="height: 42px; width: 90px; display: inline-flex; align-items: center; justify-content: center; background: var(--primary); color: var(--on-primary); border: 1px solid transparent; border-radius: 6px; font-weight: 600; cursor: pointer; box-sizing: border-box; font-family: inherit; font-size: 0.95rem;">'
content = re.sub(filter_btn_pattern, filter_btn_replacement, content)

# Replace Clear button styling to have fixed width
clear_btn_pattern = r'<a href="\{\{ url_for\(\'marketplace\.farmer_feedback\'\) \}\}" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1\.5rem; background: var\(--surface-container\); color: var\(--on-surface\); border: 1px solid var\(--outline-variant\); border-radius: 6px; font-weight: 600; text-decoration: none; box-sizing: border-box; font-family: inherit; font-size: 0\.95rem;">'
clear_btn_replacement = '<a href="{{ url_for(\'marketplace.farmer_feedback\') }}" style="height: 42px; width: 90px; display: inline-flex; align-items: center; justify-content: center; background: var(--surface-container); color: var(--on-surface); border: 1px solid var(--outline-variant); border-radius: 6px; font-weight: 600; text-decoration: none; box-sizing: border-box; font-family: inherit; font-size: 0.95rem;">'
content = re.sub(clear_btn_pattern, clear_btn_replacement, content)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated HTML")