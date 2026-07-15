import os

html_path = r"c:\Users\Windows 10 Pro\Documents\YURI\poultryconnect-main\poultryconnect\app\templates\marketplace\marketplace_base.html"
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = "{% if current_user.is_authenticated and current_user.role.value ==\n          'farmer' %}"
end_marker = "{% elif current_user.is_authenticated and current_user.role.value ==\n          'buyer' %}"

if start_marker not in content:
    start_marker = "{% if current_user.is_authenticated and current_user.role.value == 'farmer' %}"
if end_marker not in content:
    end_marker = "{% elif current_user.is_authenticated and current_user.role.value == 'buyer' %}"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print("Could not find markers")
    import sys
    sys.exit(1)

farmer_nav = """{% if current_user.is_authenticated and current_user.role.value == 'farmer' %}
          <p class="mp-sidebar-section-label">Overview</p>
          <a href="{{ url_for('dashboard.farmer') }}" class="{% if request.endpoint == 'dashboard.farmer' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            Dashboard
          </a>

          <p class="mp-sidebar-section-label">Farm Operations</p>
          <a href="{{ url_for('production.farms') }}" class="{% if request.endpoint in ['production.farms','production.farm_add','production.farm_edit','production.farm_deactivate'] %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            My Farms
          </a>
          <a href="{{ url_for('production.log') }}" class="{% if request.endpoint in ['production.log','production.log_add','production.log_edit','production.quick_log'] %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/><line x1="2" y1="20" x2="22" y2="20"/></svg>
            Production Log
          </a>
          <a href="{{ url_for('production.expenses') }}" class="{% if request.endpoint in ['production.expenses','production.expense_add','production.expense_edit'] %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
            Expenses
          </a>
          <a href="{{ url_for('analytics.index') }}" class="{% if request.blueprint == 'analytics' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
            Analytics
          </a>

          <p class="mp-sidebar-section-label">Market</p>
          <a href="{{ url_for('marketplace.manage') }}" class="{% if 'manage' in request.endpoint %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 14.66V20a2 2 0 01-2 2H4a2 2 0 01-2-2V6a2 2 0 012-2h5.34"/><polygon points="18 2 22 6 12 16 8 16 8 12 18 2"/></svg>
            My Products
          </a>
          <a href="{{ url_for('marketplace.farmer_orders') }}" class="{% if request.endpoint == 'marketplace.farmer_orders' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            Incoming Orders
          </a>

          <p class="mp-sidebar-section-label">Communication</p>
          <a href="{{ url_for('messaging.index') }}" class="{% if request.blueprint == 'messaging' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            Messages
          </a>
"""

new_content = content[:start_idx] + farmer_nav + "\n          " + content[end_idx:]

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Done marketplace_base")
