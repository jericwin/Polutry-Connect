import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/order_detail.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the feedback-card entirely
feedback_card_pattern = r'      <div class="feedback-card">.*?</div>\n      </div>\n      \{% endif %\}\n    </div>'

new_feedback_ui = '''
      {% if order.status.value == 'delivered' and current_user.id == order.buyer_id %}
      <div class="feedback-card" style="text-align: center; padding: 2rem;">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom: 1rem;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        <h3 style="margin: 0 0 0.5rem 0; color: var(--on-surface);">Your Order has been Delivered!</h3>
        <p style="color: var(--on-surface-variant); margin-bottom: 1.5rem;">Please confirm that you have successfully received your order.</p>
        <form action="{{ url_for('marketplace.confirm_receipt', order_id=order.id) }}" method="POST">
            <button type="submit" class="btn btn-primary" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1.5rem; font-size: 1rem;">Confirm Order Received</button>
        </form>
      </div>
      {% elif order.status.value == 'completed' and current_user.id == order.buyer_id %}
      <div class="feedback-card" style="text-align: center; padding: 2rem;">
          {% if order.rating %}
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom: 1rem;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
            <h3 style="margin: 0 0 0.5rem 0; color: var(--on-surface);">Feedback Submitted</h3>
            <p style="color: var(--on-surface-variant); margin: 0;">Thank you for sharing your experience! Your ratings have been recorded.</p>
          {% else %}
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom: 1rem;"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
            <h3 style="margin: 0 0 0.5rem 0; color: var(--on-surface);">Order Completed</h3>
            <p style="color: var(--on-surface-variant); margin-bottom: 1.5rem;">How was your experience? Please leave us some feedback.</p>
            <button onclick="document.getElementById('feedbackModal').style.display='flex'" class="btn btn-primary" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1.5rem; font-size: 1rem;">Leave Feedback</button>
          {% endif %}
      </div>
      {% endif %}
    </div>

    <!-- Modal Form -->
    <div id="feedbackModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9999; align-items: center; justify-content: center; padding: 1rem;">
        <div style="background: var(--surface); width: 100%; max-width: 600px; border-radius: var(--radius-lg); box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 90vh; overflow-y: auto;">
            <div style="padding: 1.5rem; border-bottom: 1px solid var(--outline-variant); display: flex; justify-content: space-between; align-items: center; background: var(--surface-container-low); border-radius: var(--radius-lg) var(--radius-lg) 0 0;">
                <h3 style="margin: 0; font-family: var(--font-display); font-size: 1.25rem; font-weight: 800; color: var(--on-surface);">Order Feedback</h3>
                <button type="button" onclick="document.getElementById('feedbackModal').style.display='none'" style="background: none; border: none; cursor: pointer; color: var(--text-muted);">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>
            
            <div style="padding: 1.5rem;">
                <form action="{{ url_for('marketplace.order_feedback', order_id=order.id) }}" method="POST">
                    <p style="color: var(--on-surface-variant); margin-top: 0; margin-bottom: 1.5rem;">Rate your experience with this order.</p>
                    
                    <!-- Category: Website Experience -->
                    <div style="margin-bottom: 1.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid var(--outline-variant);">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
                            <div style="flex: 1; min-width: 200px;">
                                <h4 style="margin: 0 0 0.5rem 0; font-size: 1.05rem; color: var(--on-surface);">Website Experience</h4>
                            </div>
                            <div>
                                <div class="star-rating">
                                  <input type="radio" id="star5_web" name="rating_website" value="5" required />
                                  <label for="star5_web" title="5 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star4_web" name="rating_website" value="4" />
                                  <label for="star4_web" title="4 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star3_web" name="rating_website" value="3" />
                                  <label for="star3_web" title="3 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star2_web" name="rating_website" value="2" />
                                  <label for="star2_web" title="2 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star1_web" name="rating_website" value="1" />
                                  <label for="star1_web" title="1 star"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                </div>
                            </div>
                        </div>
                        <div style="margin-top: 0.5rem;">
                            <textarea name="comment_website" rows="2" class="feedback-textarea" placeholder="Optional comment"></textarea>
                        </div>
                    </div>

                    <!-- Category: Product Feedback -->
                    <div style="margin-bottom: 1.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid var(--outline-variant);">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
                            <div style="flex: 1; min-width: 200px;">
                                <h4 style="margin: 0 0 0.5rem 0; font-size: 1.05rem; color: var(--on-surface);">Product</h4>
                            </div>
                            <div>
                                <div class="star-rating">
                                  <input type="radio" id="star5_prod" name="rating_product" value="5" required />
                                  <label for="star5_prod" title="5 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star4_prod" name="rating_product" value="4" />
                                  <label for="star4_prod" title="4 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star3_prod" name="rating_product" value="3" />
                                  <label for="star3_prod" title="3 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star2_prod" name="rating_product" value="2" />
                                  <label for="star2_prod" title="2 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star1_prod" name="rating_product" value="1" />
                                  <label for="star1_prod" title="1 star"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                </div>
                            </div>
                        </div>
                        <div style="margin-top: 0.5rem;">
                            <textarea name="comment_product" rows="2" class="feedback-textarea" placeholder="Optional comment"></textarea>
                        </div>
                    </div>

                    <!-- Category: Delivery Experience -->
                    <div style="margin-bottom: 2rem;">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
                            <div style="flex: 1; min-width: 200px;">
                                <h4 style="margin: 0 0 0.5rem 0; font-size: 1.05rem; color: var(--on-surface);">Delivery</h4>
                            </div>
                            <div>
                                <div class="star-rating">
                                  <input type="radio" id="star5_del" name="rating_delivery" value="5" required />
                                  <label for="star5_del" title="5 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star4_del" name="rating_delivery" value="4" />
                                  <label for="star4_del" title="4 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star3_del" name="rating_delivery" value="3" />
                                  <label for="star3_del" title="3 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star2_del" name="rating_delivery" value="2" />
                                  <label for="star2_del" title="2 stars"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                  <input type="radio" id="star1_del" name="rating_delivery" value="1" />
                                  <label for="star1_del" title="1 star"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></label>
                                </div>
                            </div>
                        </div>
                        <div style="margin-top: 0.5rem;">
                            <textarea name="comment_delivery" rows="2" class="feedback-textarea" placeholder="Optional comment"></textarea>
                        </div>
                    </div>

                    <div style="display: flex; gap: 1rem; align-items: center; justify-content: flex-end;">
                        <button type="button" onclick="document.getElementById('feedbackModal').style.display='none'" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1.5rem; background: var(--surface-container); color: var(--on-surface); border: 1px solid var(--outline-variant); border-radius: 6px; font-weight: 600; cursor: pointer; box-sizing: border-box; font-family: inherit;">Cancel</button>
                        <button type="submit" style="height: 42px; display: inline-flex; align-items: center; justify-content: center; padding: 0 1.5rem; background: var(--primary); color: var(--on-primary); border: 1px solid transparent; border-radius: 6px; font-weight: 600; cursor: pointer; box-sizing: border-box; font-family: inherit;">Submit Feedback</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
'''
content = re.sub(feedback_card_pattern, new_feedback_ui, content, flags=re.DOTALL)

# Add script at the bottom to auto-open modal if ?feedback=auto
script_add = '''
<script>
document.addEventListener("DOMContentLoaded", function() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('feedback') === 'auto') {
        const modal = document.getElementById('feedbackModal');
        if (modal) modal.style.display = 'flex';
        // Remove param from url cleanly
        window.history.replaceState({}, document.title, window.location.pathname);
    }
});
</script>
'''
content = content.replace('{% endblock %}', script_add + '\n{% endblock %}')

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated HTML")