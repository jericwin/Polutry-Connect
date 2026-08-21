"""Re-run backfill with AI (reset categories first, then re-classify)."""
import os, json, time
from dotenv import load_dotenv
load_dotenv()

from app import create_app, db
from app.models import Order
import google.generativeai as genai

app = create_app()

with app.app_context():
    api_key = os.environ.get("GEMINI_API_KEY")
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(
        "models/gemini-3.6-flash",
        generation_config={"response_mime_type": "application/json"}
    )

    orders = Order.query.filter(
        Order.rating.isnot(None),
        Order.feedback_text.isnot(None)
    ).all()

    print(f"Processing {len(orders)} orders with feedback text...")
    for o in orders:
        try:
            prompt = (
                "Analyze this poultry marketplace feedback. "
                "Return JSON with keys: category (one of: Delivery, Eggs, Product Quality, Pricing, Customer Service, Packaging, Other), "
                "issue (short phrase), sentiment (Positive/Negative/Neutral), keywords (array of 2-5 strings).\n\n"
                f"Feedback: {o.feedback_text}"
            )
            resp = model.generate_content(prompt)
            parsed = json.loads(resp.text)
            o.feedback_category = str(parsed.get("category", ""))[:100]
            o.feedback_issue = str(parsed.get("issue", ""))[:100]
            o.feedback_sentiment = str(parsed.get("sentiment", ""))[:20]
            kws = parsed.get("keywords", [])
            o.feedback_keywords = json.dumps(kws if isinstance(kws, list) else [])[:500]
            db.session.commit()
            print(f"Order #{o.id}: {o.feedback_category} | {o.feedback_sentiment} | kw={o.feedback_keywords}")
        except Exception as e:
            print(f"Order #{o.id} FAILED: {e}")
        time.sleep(0.5)

    print("All done!")
