import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the form layout
form_pattern = r'<form method="GET" action="{{ url_for\(\'marketplace\.farmer_feedback\'\) }}" style="display: flex; gap: 1rem; flex-wrap: wrap; align-items: flex-end;">'
form_replacement = '<form method="GET" action="{{ url_for(\'marketplace.farmer_feedback\') }}" style="display: flex; gap: 1rem; align-items: flex-end; flex-wrap: nowrap; overflow-x: auto; padding-bottom: 0.5rem;">'
content = re.sub(form_pattern, form_replacement, content)

# Adjust widths in the form
content = content.replace('style="flex: 1; min-width: 200px;"', 'style="flex: 1; min-width: 250px;"')
content = content.replace('style="width: 150px;"', 'style="min-width: 140px;"')

# Ensure button container doesn't shrink
content = content.replace('<div style="display: flex; gap: 0.5rem; align-items: center;">', '<div style="display: flex; gap: 0.5rem; align-items: center; flex-shrink: 0;">')

# Replace the keywords UI
keywords_pattern = r'        \{% if keywords_map %\}.*?\{% endif %\}'
keywords_replacement = '''        {% if keywords_map %}
        <div style="margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid var(--outline-variant);">
            <div style="font-size: 0.85rem; font-weight: 600; color: var(--text-muted); margin-bottom: 0.75rem;">Trending Keywords</div>
            <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                {% for kw, count in keywords_map.items() %}
                <a href="{{ url_for('marketplace.farmer_feedback', q=kw) }}" style="display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.35rem 0.75rem; background: var(--surface); color: var(--on-surface); border: 1px solid var(--outline-variant); border-radius: 6px; font-size: 0.85rem; text-decoration: none; font-weight: 500; transition: background 0.2s;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--text-muted);"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>
                    {{ kw|title }}
                    <span style="background: var(--surface-container-highest); padding: 0.15rem 0.4rem; border-radius: 4px; font-size: 0.75rem; font-weight: 700; color: var(--text-muted);">{{ count }}</span>
                </a>
                {% endfor %}
            </div>
        </div>
        {% endif %}'''

content = re.sub(keywords_pattern, keywords_replacement, content, flags=re.DOTALL)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated HTML")