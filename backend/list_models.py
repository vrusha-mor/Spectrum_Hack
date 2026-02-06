from google import genai
import os

GOOGLE_API_KEY = "AIzaSyCgP1gBUMWCB2HWnusmtxgmIZBElZxhyU0"
client = genai.Client(api_key=GOOGLE_API_KEY)

print("Listing models...")
try:
    for m in client.models.list():
        print(f"Model: {m}")
except Exception as e:
    print(f"Error: {e}")
