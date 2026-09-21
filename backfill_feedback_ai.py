"""Re-run backfill with local feedback analysis (no external GenAI needed)."""
import os, json
from dotenv import load_dotenv
load_dotenv()

from app import create_app, db
from app.models import Order
from app.utils.feedback_analysis import analyze_feedback

app = create_app()

with app.app_context():
    orders = Order.query.filter(
        Order.rating.isnot(None),
        Order.feedback_text.isnot(None)
    ).all()

    print(f"Processing {len(orders)} orders with feedback text...")
    for o in orders:
        try:
            analysis = analyze_feedback(o.feedback_text, rating=o.rating)
            o.feedback_issue = str(analysis.get("issue", ""))[:100]
            o.feedback_sentiment = str(analysis.get("sentiment", ""))[:20]
            kws = analysis.get("keywords", [])
            o.feedback_keywords = json.dumps(kws if isinstance(kws, list) else [])[:500]
            db.session.commit()
            print(f"Order #{o.id}: {o.feedback_issue} | {o.feedback_sentiment} | kw={o.feedback_keywords}")
        except Exception as e:
            print(f"Order #{o.id} FAILED: {e}")

    print("All done!")
