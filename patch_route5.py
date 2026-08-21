import re
py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('feedback_text=comment_website or None', 'feedback_text=comment_website')
content = content.replace('feedback_text=comment_product or None', 'feedback_text=comment_product')
content = content.replace('feedback_text=comment_delivery or None', 'feedback_text=comment_delivery')

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed None to empty string")