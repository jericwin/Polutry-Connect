import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/production/transactions.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

search_header = r'<div class="ds-card__header">\s*<h3 class="ds-card__label">All Sales Records<\/h3>\s*<span class="ds-pill ds-pill--green">{{ sales\|length }} Records<\/span>\s*<\/div>'

replace_header = '''<div class="ds-card__header" style="display:flex; justify-content:space-between; align-items:center;">
        <div style="display:flex; align-items:center; gap:0.75rem;">
            <h3 class="ds-card__label" style="margin:0;">All Sales Records</h3>
            <span class="ds-pill ds-pill--green" style="margin:0;">{{ sales|length }} Records</span>
        </div>
        <div style="display:flex; gap:0.5rem;">
            <a href="{{ url_for('analytics.sales_report', farm_id=selected_farm_id, type=selected_type, start_date=start_date_str, end_date=end_date_str, format='pdf') }}" target="_blank" class="btn btn-sm" style="display:inline-flex; align-items:center; gap:0.4rem; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface);">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color:#dc2626;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                PDF
            </a>
            <a href="{{ url_for('analytics.sales_report', farm_id=selected_farm_id, type=selected_type, start_date=start_date_str, end_date=end_date_str, format='excel') }}" class="btn btn-sm" style="display:inline-flex; align-items:center; gap:0.4rem; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface);">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color:#16a34a;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><path d="M8 13h2a2 2 0 0 1 2 2v2"></path><path d="M8 17h2a2 2 0 0 0 2-2v-2"></path><path d="M14 13h4"></path><path d="M16 17h2"></path></svg>
                Excel
            </a>
        </div>
    </div>'''

content = re.sub(search_header, replace_header, content)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated transactions HTML")