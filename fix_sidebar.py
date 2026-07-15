import os

html_path = r"c:\Users\Windows 10 Pro\Documents\YURI\poultryconnect-main\poultryconnect\app\templates\dashboard_base.html"
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = "{% if current_user.is_authenticated %}"
end_marker = "</nav>"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker, start_idx)

original_nav = content[start_idx + len(start_marker):end_idx]

buyer_nav = """
          {% if current_user.role.value == 'buyer' %}
          <p class="sidebar-section-label">Overview</p>
          <a href="{{ url_for('index') }}" class="nav-item {% if request.endpoint == 'index' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            Home
          </a>
          
          <p class="sidebar-section-label">Market</p>
          <a href="{{ url_for('marketplace.index') }}" class="nav-item {% if request.endpoint == 'marketplace.index' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
            Marketplace
          </a>

          <p class="sidebar-section-label">My Purchases</p>
          <a href="{{ url_for('marketplace.cart') }}" class="nav-item {% if request.endpoint == 'marketplace.cart' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
            My Cart
          </a>
          <a href="{{ url_for('marketplace.orders') }}" class="nav-item {% if request.endpoint in ['marketplace.orders','marketplace.order_detail'] %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            My Orders
          </a>
          <a href="{{ url_for('messaging.index') }}" class="nav-item {% if request.blueprint == 'messaging' %}active{% endif %}" style="position: relative;" id="sidebarMsgLink">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            Messages
            <span id="sidebarMsgBadge" style="display:none; background:#ef4444; color:#fff; font-size:0.62rem; font-weight:700; border-radius:99px; min-width:16px; height:16px; padding:0 3px; align-items:center; justify-content:center; margin-left:auto; flex-shrink:0;">0</span>
          </a>

          <p class="sidebar-section-label">Account</p>
          <a href="{{ url_for('auth.profile') }}" class="nav-item {% if request.endpoint == 'auth.profile' %}active{% endif %}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            Profile
          </a>
          {% else %}
"""

original_nav = original_nav.strip()
original_nav = buyer_nav + "          " + original_nav + "\n          {% endif %}\n"

new_content = content[:start_idx + len(start_marker)] + "\n" + original_nav + "        " + content[end_idx:]

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
print("Done")
