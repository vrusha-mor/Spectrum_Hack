from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io
import json
import re
import google.generativeai as genai
import traceback

# ================= GEMINI CONFIG =================

GOOGLE_API_KEY = "AIzaSyCgP1gBUMWCB2HWnusmtxgmIZBElZxhyU0"
genai.configure(api_key=GOOGLE_API_KEY)

# Using stable library google-generativeai
MODEL_NAME = "models/gemini-2.5-flash"

# 🔥 JSON PROMPT
prompt = """
Analyze this food image. 
Return a STRICT JSON object (no Markdown backticks) with this exact structure:
{
    "Food": "Name of the dish",
    "Classification": "Veg" or "Non-Veg",
    "Ingredients": {
        "Raw Material": ["List", "of", "items"],
        "Spices": [],
        "Oils": [],
        "Additives": []
    },
    "Allergies": ["List", "of", "allergies"],
    "Nutrients": {
        "Carbohydrates": 0.0,
        "Proteins": 0.0,
        "Fats": 0.0
    }
}
Values for Nutrients should be float numbers representing grams per 100g (approx).
Example: "Carbohydrates": 12.5
"""

# ================= FASTAPI APP =================

app = FastAPI(title="Food Calorie Analyzer API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ================= HELPER =================

def calculate_calories_and_range(carbs, protein, fat):
    calories = (carbs * 4) + (protein * 4) + (fat * 9)
    return {
        "min": round(calories * 0.9),
        "max": round(calories * 1.2)
    }

# ================= API ENDPOINT =================

@app.post("/analyze-food")
async def analyze_food(image: UploadFile = File(...)):
    print(f"📥 REQUEST RECEIVED: {image.filename}")
    try:
        image_bytes = await image.read()
        img = Image.open(io.BytesIO(image_bytes))
        print("✅ Image loaded")

        print(f"🚀 Sending to Gemini ({MODEL_NAME})...")
        
        # Use GenerativeModel from google-generativeai
        model = genai.GenerativeModel(MODEL_NAME)
        
        # Standard generation call
        response = model.generate_content([prompt, img])
        
        raw_text = response.text
        print(f"✅ Gemini Response Received (Length: {len(raw_text)})")
        
        # 🐛 DEBUG: Write raw response to file
        with open("gemini_response.log", "w", encoding="utf-8") as f:
            f.write(raw_text)

        # 🧹 Clean Markdown if present
        cleaned_json = raw_text.replace("```json", "").replace("```", "").strip()
        
        # 🧩 Parse JSON
        data = json.loads(cleaned_json)
        print("✅ JSON Parsed successfully")

        # 🧮 Extract Data
        nutrients = data.get("Nutrients", {})
        carbs = float(nutrients.get("Carbohydrates", 0))
        protein = float(nutrients.get("Proteins", 0))
        fat = float(nutrients.get("Fats", 0))

        cal_range = calculate_calories_and_range(carbs, protein, fat)

        # 📦 Format for Frontend
        result = {
            "food_name": data.get("Food", "Unknown Meal"),
            "classification": data.get("Classification", "Unknown"),
            "ingredients": {
                "raw_material": data.get("Ingredients", {}).get("Raw Material", []),
                "spices": data.get("Ingredients", {}).get("Spices", []),
                "oils": data.get("Ingredients", {}).get("Oils", []),
                "additives": data.get("Ingredients", {}).get("Additives", [])
            },
            "allergies": data.get("Allergies", []),
            "nutrition_per_100g": {
                "carbs_g_per_100g": carbs,
                "protein_g_per_100g": protein,
                "fat_g_per_100g": fat,
                "calories_range_per_100g": cal_range
            }
        }

        print("📤 Sending structured data to frontend")
        return result

    except json.JSONDecodeError as je:
        print(f"❌ JSON ERROR: {str(je)}")
        return {"error": "Failed to parse AI response", "details": str(je)}
    except Exception as e:
        error_msg = f"❌ GENERAL ERROR: {str(e)}\n{traceback.format_exc()}"
        print(error_msg)
        with open("backend_debug.log", "a", encoding="utf-8") as f:
            f.write(error_msg + "\n")
        
        # Provide more detail for debugging
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=str(e))