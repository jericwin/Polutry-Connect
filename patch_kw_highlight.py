import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

search_pattern = r"{% for kw, count in keywords_map\.items\(\) %}.*?{% endfor %}"

replace_pattern = '''{% for kw, count in keywords_map.items() %}
                {% set is_active = request.args.get('q', '').lower() == kw %}
                <a href="{{ url_for('marketplace.farmer_feedback', q='' if is_active else kw, category=request.args.get('category', ''), sentiment=request.args.get('sentiment', ''), rating=request.args.get('rating', '')) }}" style="display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.35rem 0.75rem; background: {{ '#e8f5e9' if is_active else 'var(--surface)' }}; color: {{ '#15803d' if is_active else 'var(--on-surface)' }}; border: 1px solid {{ '#bbf7d0' if is_active else 'var(--outline-variant)' }}; border-radius: 6px; font-size: 0.85rem; text-decoration: none; font-weight: 500; transition: all 0.2s;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: {{ '#15803d' if is_active else 'var(--text-muted)' }};"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>
                    {{ kw|title }}
                    <span style="background: {{ '#bbf7d0' if is_active else 'var(--surface-container-highest)' }}; padding: 0.15rem 0.4rem; border-radius: 4px; font-size: 0.75rem; font-weight: 700; color: {{ '#15803d' if is_active else 'var(--text-muted)' }};">{{ count }}</span>
                </a>
                {% endfor %}'''

content = re.sub(search_pattern, replace_pattern, content, flags=re.DOTALL)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated keywords UI logic")