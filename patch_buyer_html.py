import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/buyer/feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add product_id field
product_field = '''            <div class="form-group" id="productField" style="display: none;">
                <label class="form-label" for="product_id">Related Product</label>
                <select id="product_id" name="product_id" class="form-control">
                    <option value="" disabled selected>Select a product...</option>
                    {% for product in recent_products %}
                    <option value="{{ product.id }}">{{ product.name }}</option>
                    {% endfor %}
                </select>
            </div>'''

# Add an ID to the order field
content = content.replace('<div class="form-group">\n                <label class="form-label" for="order_id">Related Order (Optional)</label>', '<div class="form-group" id="orderField">\n                <label class="form-label" for="order_id">Related Order (Optional)</label>')

content = content.replace('<div class="form-group" id="orderField">', product_field + '\n\n            <div class="form-group" id="orderField">')

# Add JS logic
js_logic = '''
{% block scripts %}
<script>
    document.getElementById('category').addEventListener('change', function() {
        const cat = this.value;
        const prodField = document.getElementById('productField');
        const orderField = document.getElementById('orderField');
        const prodSelect = document.getElementById('product_id');
        
        if (cat === 'product') {
            prodField.style.display = 'block';
            prodSelect.required = true;
            orderField.style.display = 'none';
        } else {
            prodField.style.display = 'none';
            prodSelect.required = false;
            orderField.style.display = 'block';
        }
    });
</script>
{% endblock %}
'''

if '{% block scripts %}' not in content:
    content = content.replace('{% endblock %}', js_logic + '\n{% endblock %}')

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated feedback.html")