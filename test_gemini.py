import os, json
from dotenv import load_dotenv
load_dotenv()
import google.generativeai as genai

key = os.environ.get('GEMINI_API_KEY')
print('Key found:', bool(key))
if not key:
    print('ERROR: GEMINI_API_KEY not found in .env!')
    exit()

genai.configure(api_key=key)
try:
    model = genai.GenerativeModel(
        'gemini-1.5-flash',
        generation_config={'response_mime_type': 'application/json'}
    )
    prompt = 'Analyze this feedback: "The eggs were fresh and delivery was fast!". Return JSON with keys: category, issue, sentiment, keywords (array).'
    resp = model.generate_content(prompt)
    print('SUCCESS! Response:')
    print(resp.text)
    parsed = json.loads(resp.text)
    print('Parsed:', parsed)
except Exception as e:
    print('ERROR:', type(e).__name__)
    print(str(e))
