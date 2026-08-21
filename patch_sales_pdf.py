import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/analytics/sales_report_pdf.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add Type header
search_header = "<th>Farm</th>"
replace_header = "<th>Type</th>\n                <th>Farm</th>"
content = content.replace(search_header, replace_header)

# Add Type cell
search_cell = "<td>{{ s.farm.name }}</td>"
replace_cell = "<td>{% if s.notes and '(Order #' in s.notes %}Online{% else %}On-site{% endif %}</td>\n                    <td>{{ s.farm.name }}</td>"
content = content.replace(search_cell, replace_cell)

# Update totals colspan
search_totals = '<td colspan="3" class="totals-row">TOTALS</td>'
replace_totals = '<td colspan="4" class="totals-row">TOTALS</td>'
content = content.replace(search_totals, replace_totals)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated sales_report_pdf.html")