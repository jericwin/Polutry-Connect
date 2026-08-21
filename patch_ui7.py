import re

html_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/order_detail.html'
with open(html_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add ID to form
content = content.replace('<form action="{{ url_for(\'marketplace.order_feedback\', order_id=order.id) }}" method="POST">', '<form id="feedbackForm" action="{{ url_for(\'marketplace.order_feedback\', order_id=order.id) }}" method="POST">')

# Add Animation Modal and Logic at the end before {% endblock %}
animation_code = '''
<!-- Success Animation Modal -->
<style>
.success-checkmark {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    animation: scaleIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
}
.success-checkmark svg {
    color: white;
    width: 44px;
    height: 44px;
    stroke-dasharray: 48;
    stroke-dashoffset: 48;
    animation: drawCheck 0.4s 0.3s ease-out forwards;
}
@keyframes scaleIn {
    0% { transform: scale(0); }
    100% { transform: scale(1); }
}
@keyframes drawCheck {
    0% { stroke-dashoffset: 48; }
    100% { stroke-dashoffset: 0; }
}
@keyframes fadeInUp {
    to { opacity: 1; transform: translateY(0); }
}
</style>
<div id="successAnimationModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); z-index: 10000; align-items: center; justify-content: center; flex-direction: column;">
    <div class="success-checkmark">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
    </div>
    <h2 style="color: white; margin-top: 1.5rem; font-family: var(--font-display); font-weight: 800; animation: fadeInUp 0.4s 0.4s forwards; opacity: 0; transform: translateY(15px);">Thank You!</h2>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const feedbackForm = document.getElementById('feedbackForm');
    if (feedbackForm) {
        feedbackForm.addEventListener('submit', function(e) {
            // Check if all radio buttons required are filled (HTML5 validation does this but just in case)
            if (this.checkValidity()) {
                e.preventDefault();
                document.getElementById('feedbackModal').style.display = 'none';
                document.getElementById('successAnimationModal').style.display = 'flex';
                
                // Wait for animation to finish then actually submit
                setTimeout(() => {
                    this.submit();
                }, 1300);
            }
        });
    }
});
</script>
'''

content = content.replace('{% endblock %}', animation_code + '\n{% endblock %}')

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Added check animation popup")