import shutil

src = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/analytics/sales_report_pdf.html'
dst = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/analytics/expenses_report_pdf.html'

shutil.copyfile(src, dst)

with open(dst, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("Sales Report", "Expenses Report")
content = content.replace("<th>Type</th>\n                <th>Farm</th>\n                <th>Buyer</th>\n                <th>Egg Type / Notes</th>\n                <th>Qty</th>\n                <th>Price</th>\n                <th>Total (,)</th>", "<th>Farm</th>\n                <th>Category</th>\n                <th>Description</th>\n                <th>Frequency</th>\n                <th>Amount (,)</th>")
content = content.replace('{% for s in sales %}', '{% for e in expenses %}')
content = content.replace('<td>{% if s.notes and \'(Order #\' in s.notes %}Online{% else %}On-site{% endif %}</td>\n                    <td>{{ s.farm.name }}</td>\n                    <td>{{ s.buyer_name or \'Walk-in / Unknown\' }}</td>\n                    <td>{{ s.notes or \'\' }}</td>\n                    <td class="num">{{ "{:,}".format(s.quantity_sold) }}</td>\n                    <td class="num">{{ "{:,.2f}".format(s.price_per_egg) }}</td>\n                    <td class="num">{{ "{:,.2f}".format(s.total_revenue) }}</td>', '<td>{{ e.farm.name }}</td>\n                    <td>{{ e.category.value if e.category else \'\' }}</td>\n                    <td>{{ e.description or \'\' }}</td>\n                    <td>{{ e.frequency.value if e.frequency else \'\' }}</td>\n                    <td class="num">{{ "{:,.2f}".format(e.amount) }}</td>')
content = content.replace('{% endfor %}', '{% endfor %}')
content = content.replace('<td colspan="4" class="totals-row">TOTALS</td>', '<td colspan="4" class="totals-row">TOTAL</td>')
content = content.replace('<td class="num"><strong>{{ "{:,}".format(sales|sum(attribute="quantity_sold")) }}</strong></td>', '')
content = content.replace('<td></td>', '')
content = content.replace('<td class="num"><strong>{{ "{:,.2f}".format(sales|sum(attribute="total_revenue")) }}</strong></td>', '<td class="num"><strong>{{ "{:,.2f}".format(total_amount) }}</strong></td>')

with open(dst, 'w', encoding='utf-8') as f:
    f.write(content)

print("Created expenses_report_pdf.html")