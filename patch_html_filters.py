import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

filter_html = '''
    <!-- Filters -->
    <div style="background: var(--surface); padding: 1.5rem; border: 1px solid var(--outline); border-radius: var(--radius-lg); margin-bottom: 2rem;">
        <form method="GET" action="{{ url_for('marketplace.farmer_feedback') }}" style="display: flex; gap: 1rem; flex-wrap: wrap; align-items: flex-end;">
            
            <div style="flex: 1; min-width: 200px;">
                <label for="q" style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--text-muted); margin-bottom: 0.5rem;">Search Comments</label>
                <div style="position: relative;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); color: var(--text-muted);"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <input type="text" id="q" name="q" value="{{ request.args.get('q', '') }}" placeholder="Search keywords..." style="width: 100%; padding: 0.75rem 1rem 0.75rem 2.5rem; border: 1px solid var(--outline-variant); border-radius: 6px; font-family: inherit;">
                </div>
            </div>

            <div style="width: 150px;">
                <label for="category" style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--text-muted); margin-bottom: 0.5rem;">Category</label>
                <select id="category" name="category" style="width: 100%; padding: 0.75rem 1rem; border: 1px solid var(--outline-variant); border-radius: 6px; font-family: inherit; background: var(--surface);">
                    <option value="">All Categories</option>
                    {% for cat in unique_categories %}
                    <option value="{{ cat }}" {% if request.args.get('category') == cat %}selected{% endif %}>{{ cat|title }}</option>
                    {% endfor %}
                </select>
            </div>

            <div style="width: 150px;">
                <label for="sentiment" style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--text-muted); margin-bottom: 0.5rem;">AI Sentiment</label>
                <select id="sentiment" name="sentiment" style="width: 100%; padding: 0.75rem 1rem; border: 1px solid var(--outline-variant); border-radius: 6px; font-family: inherit; background: var(--surface);">
                    <option value="">All Sentiments</option>
                    {% for sent in unique_sentiments %}
                    <option value="{{ sent|lower }}" {% if request.args.get('sentiment') == sent|lower %}selected{% endif %}>{{ sent }}</option>
                    {% endfor %}
                </select>
            </div>
            
            <div style="width: 150px;">
                <label for="rating" style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--text-muted); margin-bottom: 0.5rem;">Rating</label>
                <select id="rating" name="rating" style="width: 100%; padding: 0.75rem 1rem; border: 1px solid var(--outline-variant); border-radius: 6px; font-family: inherit; background: var(--surface);">
                    <option value="">All Ratings</option>
                    <option value="5" {% if request.args.get('rating') == '5' %}selected{% endif %}>5 Stars</option>
                    <option value="4" {% if request.args.get('rating') == '4' %}selected{% endif %}>4 Stars</option>
                    <option value="3" {% if request.args.get('rating') == '3' %}selected{% endif %}>3 Stars</option>
                    <option value="2" {% if request.args.get('rating') == '2' %}selected{% endif %}>2 Stars</option>
                    <option value="1" {% if request.args.get('rating') == '1' %}selected{% endif %}>1 Star</option>
                </select>
            </div>

            <button type="submit" style="padding: 0.75rem 1.5rem; background: var(--primary); color: var(--on-primary); border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">
                Filter
            </button>
            {% if request.args %}
            <a href="{{ url_for('marketplace.farmer_feedback') }}" style="padding: 0.75rem 1.5rem; background: var(--surface-container); color: var(--on-surface); border: 1px solid var(--outline-variant); border-radius: 6px; font-weight: 600; text-decoration: none;">Clear</a>
            {% endif %}
        </form>

        {% if keywords_map %}
        <div style="margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid var(--outline-variant);">
            <div style="font-size: 0.85rem; font-weight: 600; color: var(--text-muted); margin-bottom: 0.75rem;">Trending AI Keywords</div>
            <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                {% for kw, count in keywords_map.items() %}
                <a href="{{ url_for('marketplace.farmer_feedback', q=kw) }}" style="padding: 0.25rem 0.75rem; background: var(--primary-container); color: var(--on-primary-container); border-radius: 99px; font-size: 0.8rem; text-decoration: none; font-weight: 500;">
                    {{ kw }} <span style="opacity: 0.7; font-size: 0.75rem; margin-left: 0.25rem;">({{ count }})</span>
                </a>
                {% endfor %}
            </div>
        </div>
        {% endif %}
    </div>
'''

content = content.replace('{% if feedbacks %}', filter_html + '\n    {% if feedbacks %}')

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated farmer_feedback.html with filters")