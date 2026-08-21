import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/order_detail.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the existing feedback-body entirely. We need to handle the case where feedback already exists vs doesn't exist.
# The original code has {% if order.rating %} ... {% else %} ... {% endif %} inside <div class="feedback-body">

replacement_body = '''        <div class="feedback-body">
          {% if order.rating %}
            <!-- Display Existing Feedback (Simplified since it's already submitted) -->
            <div style="background: var(--surface-container-lowest); padding: 1.5rem; border-radius: var(--radius-md); border: 1px dashed var(--outline); text-align: center;">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom: 1rem;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
              <h3 style="margin: 0 0 0.5rem 0; color: var(--on-surface);">Feedback Submitted</h3>
              <p style="color: var(--on-surface-variant); margin: 0;">Thank you for sharing your experience! Your ratings have been recorded.</p>
            </div>
          {% else %}
            <!-- Feedback Form -->
            <form action="{{ url_for('marketplace.order_feedback', order_id=order.id) }}" method="POST">
              <p style="color: var(--on-surface-variant); margin-top: 0; margin-bottom: 1.5rem;">Please rate your experience in the following categories to help us improve.</p>
              
              <!-- Category: Website Experience -->
              <div style="margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid var(--outline-variant);">
                  <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
                      <div style="flex: 1; min-width: 200px;">
                          <h4 style="margin: 0 0 0.5rem 0; font-size: 1.1rem; color: var(--on-surface);">1. Website Experience</h4>
                          <p style="margin: 0; font-size: 0.85rem; color: var(--text-muted);">How was your experience using the platform? (Ease of use, navigation, etc.)</p>
                      </div>
                      <div>
                          <div class="star-rating">
                            <input type="radio" id="star5_web" name="rating_website" value="5" required />
                            <label for="star5_web" title="5 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star4_web" name="rating_website" value="4" />
                            <label for="star4_web" title="4 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star3_web" name="rating_website" value="3" />
                            <label for="star3_web" title="3 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star2_web" name="rating_website" value="2" />
                            <label for="star2_web" title="2 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star1_web" name="rating_website" value="1" />
                            <label for="star1_web" title="1 star">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                          </div>
                      </div>
                  </div>
                  <div style="margin-top: 1rem;">
                      <textarea name="comment_website" rows="2" class="feedback-textarea" placeholder="Optional comment..."></textarea>
                  </div>
              </div>

              <!-- Category: Product Feedback -->
              <div style="margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid var(--outline-variant);">
                  <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
                      <div style="flex: 1; min-width: 200px;">
                          <h4 style="margin: 0 0 0.5rem 0; font-size: 1.1rem; color: var(--on-surface);">2. Product Quality</h4>
                          <p style="margin: 0; font-size: 0.85rem; color: var(--text-muted);">Rate the quality and freshness of the products received.</p>
                      </div>
                      <div>
                          <div class="star-rating">
                            <input type="radio" id="star5_prod" name="rating_product" value="5" required />
                            <label for="star5_prod" title="5 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star4_prod" name="rating_product" value="4" />
                            <label for="star4_prod" title="4 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star3_prod" name="rating_product" value="3" />
                            <label for="star3_prod" title="3 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star2_prod" name="rating_product" value="2" />
                            <label for="star2_prod" title="2 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star1_prod" name="rating_product" value="1" />
                            <label for="star1_prod" title="1 star">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                          </div>
                      </div>
                  </div>
                  <div style="margin-top: 1rem;">
                      <textarea name="comment_product" rows="2" class="feedback-textarea" placeholder="Optional comment..."></textarea>
                  </div>
              </div>

              <!-- Category: Delivery Experience -->
              <div style="margin-bottom: 1.5rem;">
                  <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
                      <div style="flex: 1; min-width: 200px;">
                          <h4 style="margin: 0 0 0.5rem 0; font-size: 1.1rem; color: var(--on-surface);">3. Delivery Experience</h4>
                          <p style="margin: 0; font-size: 0.85rem; color: var(--text-muted);">Rate the delivery speed, handling, and service of the farmer.</p>
                      </div>
                      <div>
                          <div class="star-rating">
                            <input type="radio" id="star5_del" name="rating_delivery" value="5" required />
                            <label for="star5_del" title="5 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star4_del" name="rating_delivery" value="4" />
                            <label for="star4_del" title="4 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star3_del" name="rating_delivery" value="3" />
                            <label for="star3_del" title="3 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star2_del" name="rating_delivery" value="2" />
                            <label for="star2_del" title="2 stars">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                            <input type="radio" id="star1_del" name="rating_delivery" value="1" />
                            <label for="star1_del" title="1 star">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            </label>
                          </div>
                      </div>
                  </div>
                  <div style="margin-top: 1rem;">
                      <textarea name="comment_delivery" rows="2" class="feedback-textarea" placeholder="Optional comment..."></textarea>
                  </div>
              </div>

              <div style="margin-top: 2rem;">
                <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center; padding: 1rem; font-size: 1.1rem; height: 50px;">
                  Submit Feedback
                </button>
              </div>
            </form>
          {% endif %}
        </div>'''

content = re.sub(r'        <div class="feedback-body">.*?</form>\s*\{% endif %\}\s*</div>', replacement_body, content, flags=re.DOTALL)

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated HTML form")