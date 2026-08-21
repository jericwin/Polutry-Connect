import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/product_detail.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

reviews_section = '''
  <div style="margin-top: 3rem; border-top: 1px solid var(--outline-variant); padding-top: 2rem;">
    <h3 style="font-family: var(--font-display); font-size: 1.5rem; font-weight: 700; color: var(--on-surface); margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--primary);"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
      Product Reviews
      {% if avg_rating %}
      <span style="font-size: 1.1rem; font-weight: 500; color: var(--text-muted); margin-left: auto;">
        {{ avg_rating }} / 5.0 Average
      </span>
      {% endif %}
    </h3>

    {% if feedbacks %}
    <div style="display: grid; gap: 1.5rem; grid-template-columns: 1fr;">
        {% for fb in feedbacks %}
        <div style="background: var(--surface-container); border-radius: 8px; padding: 1.5rem; display: flex; flex-direction: column; gap: 1rem;">
            <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                <div style="display: flex; gap: 0.75rem; align-items: center;">
                    <div style="width: 40px; height: 40px; border-radius: 50%; background: var(--primary-container); color: var(--on-primary-container); display: flex; align-items: center; justify-content: center; font-weight: 600;">
                        {{ fb.buyer.full_name[0]|upper if fb.buyer else '?' }}
                    </div>
                    <div>
                        <div style="font-weight: 600; color: var(--on-surface);">{{ fb.buyer.full_name if fb.buyer else 'Anonymous' }}</div>
                        <div style="font-size: 0.85rem; color: var(--text-muted);">{{ fb.created_at.strftime('%B %d, %Y') }}</div>
                    </div>
                </div>
                <div style="display: flex; gap: 0.25rem;">
                    {% if fb.rating %}
                        {% for i in range(5) %}
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="{% if i < fb.rating %}#eab308{% else %}none{% endif %}" stroke="{% if i < fb.rating %}#eab308{% else %}#cbd5e1{% endif %}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                        </svg>
                        {% endfor %}
                    {% else %}
                        <span style="font-size: 0.875rem; color: var(--text-muted);">No rating</span>
                    {% endif %}
                </div>
            </div>
            
            <p style="font-size: 1rem; color: var(--on-surface); line-height: 1.5; margin: 0;">
                "{{ fb.feedback_text }}"
            </p>

            {% if fb.ai_sentiment or fb.ai_issue %}
            <div style="display: flex; gap: 0.5rem; flex-wrap: wrap; margin-top: 0.5rem;">
                {% if fb.ai_sentiment %}
                    {% if fb.ai_sentiment == 'Positive' %}
                        <span style="font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.5rem; border-radius: 4px; background: #dcfce7; color: #15803d;">Positive</span>
                    {% elif fb.ai_sentiment == 'Negative' %}
                        <span style="font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.5rem; border-radius: 4px; background: #fee2e2; color: #b91c1c;">Negative</span>
                    {% else %}
                        <span style="font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.5rem; border-radius: 4px; background: #f1f5f9; color: #475569;">Neutral</span>
                    {% endif %}
                {% endif %}

                {% if fb.ai_issue %}
                    <span style="font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.5rem; border-radius: 4px; background: #f3f4f6; color: #374151;">
                        {{ fb.ai_issue }}
                    </span>
                {% endif %}
            </div>
            {% endif %}
        </div>
        {% endfor %}
    </div>
    {% else %}
    <div style="text-align: center; padding: 3rem 1rem; background: var(--surface-container); border-radius: 8px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="color: var(--text-muted); margin-bottom: 1rem; opacity: 0.5;"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
        <p style="color: var(--text-muted); margin: 0; font-size: 1.1rem;">No reviews yet for this product.</p>
    </div>
    {% endif %}
  </div>

{% endif %} {% endblock %}'''

content = content.replace('{% endif %} {% endblock %}', reviews_section)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated product_detail.html")