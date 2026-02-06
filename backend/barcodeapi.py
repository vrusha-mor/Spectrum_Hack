from fastapi import FastAPI, HTTPException
import requests
import re
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from requests.exceptions import ReadTimeout, ConnectTimeout, ConnectionError

app = FastAPI(title="Barcode Product API")

# -------------------- API SESSION WITH RETRIES --------------------

session = requests.Session()

retries = Retry(
    total=2,
    backoff_factor=0.5,
    status_forcelist=[429, 500, 502, 503, 504],
    allowed_methods=["GET"]
)

adapter = HTTPAdapter(max_retries=retries)
session.mount("https://", adapter)

# -------------------- SAFE EMPTY PRODUCT --------------------

def safe_empty_product(reason):
    return {
        "ingredients": f"Ingredients not available ({reason})",
        "weight_grams": "Weight not available",
        "serving_size": "Serving size not available",
        "nutriments": {}
    }

# -------------------- PRODUCT HELPERS --------------------

def extract_weight(product):
    if product.get("product_quantity"):
        return f'{product["product_quantity"]} g'

    quantity = product.get("quantity")
    if isinstance(quantity, str):
        match = re.search(r"(\d+)\s*g", quantity.lower())
        if match:
            return f"{match.group(1)} g"
        return quantity

    if product.get("packaging_quantity"):
        return f'{product["packaging_quantity"]} g'

    return "Weight not available"

def extract_ingredients_text(product):
    if product.get("ingredients_text_en"):
        return product["ingredients_text_en"]

    if product.get("ingredients_text"):
        return product["ingredients_text"]

    if product.get("ingredients_text_with_allergens"):
        return product["ingredients_text_with_allergens"]

    structured = product.get("ingredients")
    if isinstance(structured, list):
        joined = ", ".join(
            ing.get("text", "") for ing in structured if ing.get("text")
        )
        if joined:
            return joined

    return "Ingredients not provided"

# -------------------- FETCH PRODUCT --------------------

def fetch_product_details(barcode: str):
    url = f"https://world.openfoodfacts.org/api/v0/product/{barcode}.json"

    try:
        response = session.get(url, timeout=5)

        if response.status_code != 200:
            return safe_empty_product("API error")

        data = response.json()
        product = data.get("product", {})

        return {
            "barcode": barcode,
            "ingredients": extract_ingredients_text(product),
            "weight_grams": extract_weight(product),
            "serving_size": product.get("serving_size", "Not available"),
            "nutriments": product.get("nutriments", {})
        }

    except (ReadTimeout, ConnectTimeout):
        return safe_empty_product("Timeout")

    except ConnectionError:
        return safe_empty_product("Network error")

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# -------------------- API ENDPOINT --------------------

@app.get("/scan/{barcode}")
def scan_barcode(barcode: str):
    return fetch_product_details(barcode)

@app.get("/")
def root():
    return {"status": "Barcode API running"}
