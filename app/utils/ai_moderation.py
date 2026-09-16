import os
import json
import warnings
warnings.filterwarnings('ignore', category=FutureWarning, module='google.generativeai')
import google.generativeai as genai
from PIL import Image

def init_gemini():
    api_key = os.environ.get('GEMINI_API_KEY')
    if not api_key:
        return False
    genai.configure(api_key=api_key)
    return True

def moderate_image(image_path):
    """
    Analyzes an image using Gemini Vision API and returns moderation results.
    Returns: (is_safe, flag_reason, full_json_response)
    """
    if not init_gemini():
        return True, "", '{"error": "API Key missing", "safe": true}' # Pass if no API key configured

    try:
        model = genai.GenerativeModel('models/gemini-3.6-flash')
        
        prompt = """
        You are a content moderation AI for an agricultural marketplace.
        Analyze this image and determine if it is appropriate for a public marketplace where farmers sell poultry products (chickens, eggs, feed, supplies, etc.).
        
        Flag the image if it contains:
        1. Explicit, adult, or inappropriate content
        2. Offensive, hateful, or harmful imagery
        3. Completely irrelevant content (e.g. spam, unrelated memes)
        4. Clear signs of scam or misleading representations
        
        Respond with ONLY a valid JSON object in this exact format:
        {
            "safe": boolean (true if appropriate, false if flagged),
            "reason": "If safe=false, provide a brief 1-sentence reason. If safe=true, return empty string",
            "category": "e.g. 'Explicit', 'Irrelevant', 'Safe'"
        }
        """
        
        img = Image.open(image_path)
        response = model.generate_content([prompt, img])
        
        if response and response.text:
            text = response.text
            # Clean up potential markdown formatting around JSON
            if text.startswith('```json'):
                text = text.replace('```json', '', 1)
            if text.endswith('```'):
                text = text[:-3]
                
            result = json.loads(text.strip())
            is_safe = result.get('safe', True)
            reason = result.get('reason', '')
            
            return is_safe, reason, json.dumps(result)
            
    except Exception as e:
        print(f"[AI Moderation Error] {e}")
        return True, "", json.dumps({"error": str(e), "safe": True}) # Default safe on error
        
    return True, "", "{}"
