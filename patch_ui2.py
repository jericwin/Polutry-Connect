import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix form styling: allow wrap but adjust search box width
content = content.replace('<form method="GET" action="{{ url_for(''marketplace.farmer_feedback'') }}" style="display: flex; gap: 1rem; align-items: flex-end; flex-wrap: nowrap; overflow-x: auto; padding-bottom: 0.5rem;">', '<form method="GET" action="{{ url_for(''marketplace.farmer_feedback'') }}" style="display: flex; gap: 1rem; align-items: flex-end; flex-wrap: wrap;">')

# Reduce search field width
content = content.replace('<div style="flex: 1; min-width: 250px;">', '<div style="width: 200px;">')

# Ensure inputs and selects have same height
content = content.replace('padding: 0.75rem 1rem 0.75rem 2.5rem;', 'height: 42px; padding: 0 1rem 0 2.5rem;')
content = content.replace('padding: 0.75rem 1rem; border: 1px', 'height: 42px; padding: 0 1rem; border: 1px')

# Make button heights the same
content = content.replace('<button type="submit" style="padding: 0.75rem 1.5rem; background: var(--primary); color: var(--on-primary); border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">', '<button type="submit" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1.5rem; background: var(--primary); color: var(--on-primary); border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">')
content = content.replace('<a href="{{ url_for(''marketplace.farmer_feedback'') }}" style="padding: 0.75rem 1.5rem; background: var(--surface-container); color: var(--on-surface); border: 1px solid var(--outline-variant); border-radius: 6px; font-weight: 600; text-decoration: none;">', '<a href="{{ url_for(''marketplace.farmer_feedback'') }}" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1.5rem; background: var(--surface-container); color: var(--on-surface); border: 1px solid var(--outline-variant); border-radius: 6px; font-weight: 600; text-decoration: none; box-sizing: border-box;">')

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated HTML")