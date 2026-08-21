import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    "return render_template(\n        'marketplace/farmer_feedback.html',\n        feedbacks=feedbacks,",
    "return render_template(\n        'marketplace/farmer_feedback.html',\n        feedbacks_grouped=feedbacks_grouped,\n        feedbacks=feedbacks,"
)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Injected feedbacks_grouped")