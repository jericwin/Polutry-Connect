import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the iteration part
search_block = r'{% if feedbacks %}.*?{% else %}'

replace_block = '''{% if feedbacks_grouped %}
    <div class="fo-grid">
        {% for group in feedbacks_grouped %}
        <div class="feedback-card" style="padding: 1.5rem; display: flex; flex-direction: column; gap: 1.5rem;">
            <!-- Header for the grouped feedback -->
            <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid var(--outline-variant); padding-bottom: 1rem;">
                <div>
                    <h3 style="margin: 0; font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; color: var(--on-surface);">Order #{{ group.order_id }}</h3>
                    <div style="font-size: 0.85rem; color: var(--on-surface-variant); margin-top: 0.25rem;">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="12" height="12" style="vertical-align: middle; margin-right: 0.25rem;"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        {{ group.buyer.full_name }}
                    </div>
                </div>
                <div style="font-size: 0.85rem; color: var(--text-muted);">
                    {{ group.created_at.strftime('%b %d, %Y') }}
                </div>
            </div>

            <!-- Website Feedback -->
            {% if group.website %}
            <div>
                <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--primary); margin-bottom: 0.5rem;">Website Experience</div>
                <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                    <div style="display: flex; align-items: center; color: #f59e0b; font-weight: 700; font-size: 0.9rem;">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="16" height="16" style="margin-right: 0.25rem;"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        {{ group.website.rating }} / 5
                    </div>
                    {% if group.website.ai_sentiment %}
                        {% set s = group.website.ai_sentiment.lower() %}
                        <span style="font-size: 0.75rem; font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 4px; background: {% if s == 'positive' %}#e8f5e9; color: #2e7d32;{% elif s == 'negative' %}#ffebee; color: #c62828;{% else %}#f5f5f5; color: #616161;{% endif %}">{{ group.website.ai_sentiment }}</span>
                    {% endif %}
                </div>
                {% if group.website.feedback_text %}
                    <div style="font-size: 0.95rem; color: var(--on-surface); line-height: 1.5; font-style: italic;">"{{ group.website.feedback_text }}"</div>
                {% else %}
                    <div style="font-size: 0.85rem; color: var(--text-muted); opacity: 0.7;">No comments provided.</div>
                {% endif %}
            </div>
            {% endif %}

            <!-- Product Feedback -->
            {% if group.product %}
            <div>
                <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--primary); margin-bottom: 0.5rem;">Product</div>
                <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                    <div style="display: flex; align-items: center; color: #f59e0b; font-weight: 700; font-size: 0.9rem;">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="16" height="16" style="margin-right: 0.25rem;"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        {{ group.product.rating }} / 5
                    </div>
                    {% if group.product.ai_sentiment %}
                        {% set s = group.product.ai_sentiment.lower() %}
                        <span style="font-size: 0.75rem; font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 4px; background: {% if s == 'positive' %}#e8f5e9; color: #2e7d32;{% elif s == 'negative' %}#ffebee; color: #c62828;{% else %}#f5f5f5; color: #616161;{% endif %}">{{ group.product.ai_sentiment }}</span>
                    {% endif %}
                </div>
                {% if group.product.feedback_text %}
                    <div style="font-size: 0.95rem; color: var(--on-surface); line-height: 1.5; font-style: italic;">"{{ group.product.feedback_text }}"</div>
                {% else %}
                    <div style="font-size: 0.85rem; color: var(--text-muted); opacity: 0.7;">No comments provided.</div>
                {% endif %}
            </div>
            {% endif %}

            <!-- Delivery Feedback -->
            {% if group.delivery %}
            <div>
                <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--primary); margin-bottom: 0.5rem;">Delivery</div>
                <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                    <div style="display: flex; align-items: center; color: #f59e0b; font-weight: 700; font-size: 0.9rem;">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="16" height="16" style="margin-right: 0.25rem;"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        {{ group.delivery.rating }} / 5
                    </div>
                    {% if group.delivery.ai_sentiment %}
                        {% set s = group.delivery.ai_sentiment.lower() %}
                        <span style="font-size: 0.75rem; font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 4px; background: {% if s == 'positive' %}#e8f5e9; color: #2e7d32;{% elif s == 'negative' %}#ffebee; color: #c62828;{% else %}#f5f5f5; color: #616161;{% endif %}">{{ group.delivery.ai_sentiment }}</span>
                    {% endif %}
                </div>
                {% if group.delivery.feedback_text %}
                    <div style="font-size: 0.95rem; color: var(--on-surface); line-height: 1.5; font-style: italic;">"{{ group.delivery.feedback_text }}"</div>
                {% else %}
                    <div style="font-size: 0.85rem; color: var(--text-muted); opacity: 0.7;">No comments provided.</div>
                {% endif %}
            </div>
            {% endif %}
        </div>
        {% endfor %}
    </div>
    {% else %}'''

content = re.sub(search_block, replace_block, content, flags=re.DOTALL)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated HTML logic")