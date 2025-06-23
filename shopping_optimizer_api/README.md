# Shopping Optimizer API v2.0

A Flask API that provides shopping list optimization based on nutritional requirements and budget constraints.

## Features

- Nutritional optimization using linear programming
- Budget-aware shopping recommendations
- Category diversity constraints
- Support for different fitness goals
- RESTful API endpoints

## API Endpoints

### GET /
Health check and API information

### GET /health
Detailed health status

### POST /optimize
Optimize shopping list based on user parameters

**Request Body:**
```json
{
  "age": 25,
  "gender": "male",
  "weight": 70,
  "height": 175,
  "activity": "moderately active",
  "goal": "doing sports",
  "budget": 10000,
  "days": 30
}
```

**Response:**
```json
{
  "success": true,
  "optimization_results": {
    "items": [...],
    "total_cost": 4658.07,
    "total_weight": 45000,
    "total_items": 158,
    "budget_usage": 46.6
  },
  "nutrition_targets": {...},
  "nutrition_achieved": {...},
  "parameters": {...}
}
```

## Deployment on Render

1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Set the following:
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `gunicorn app:app`
   - **Environment:** Python 3.9

## Local Development

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Place your `enriched_2025_05_21.csv` file in the same directory

3. Run the server:
   ```bash
   python app.py
   ```

4. The API will be available at `http://localhost:5000`

## File Structure

```
shopping_optimizer_api/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── render.yaml           # Render deployment config
├── README.md             # This file
└── enriched_2025_05_21.csv  # Product data (not included in repo)
``` 