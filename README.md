<div align="center">

# 🐔 PoultryConnect 2.0 

**Empowering Smallholder Poultry Farmers with Data & Connectivity**

[![Python Version](https://img.shields.io/badge/python-3.10%2B-blue?style=for-the-badge&logo=python&logoColor=white)](#)
[![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)](#)
[![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)](#)
[![Bootstrap](https://img.shields.io/badge/bootstrap-%238511FA.svg?style=for-the-badge&logo=bootstrap&logoColor=white)](#)

*A centralized web-based platform to monitor operations, analyze production, and connect with the agricultural community.*

[Explore Features](#-core-features) • [Installation Guide](#-setup-guide) • [User Roles](#-user-roles)

</div>

---

## 🎯 About The Project

**PoultryConnect 2.0** is an intelligent web platform designed specifically for smallholder poultry farmers. It replaces manual record-keeping with a digital ecosystem that not only tracks farm data but provides predictive analytics to help farmers make better pricing and operational decisions. It also opens up market access by directly connecting farmers to buyers, feed suppliers, and veterinarians.

### 💡 The Problem We Solve
Farmers often struggle with manual records, unstable pricing, and limited market access resulting in low productivity and income uncertainty. 

### ✅ Our Solution
PoultryConnect 2.0 centralizes data, analyzes it to provide actionable insights, and features a built-in marketplace and community directory to boost farm productivity and sales.

---

## ⭐ Core Features

### 🧠 Predictive Analytics & Decision Support
Analyzes farm data to generate actionable insights:
- **Production Forecasts:** Predicts future egg yields.
- **Disease Alerts:** Warns when production drops abnormally.
- **Feed Efficiency:** Monitors if feed consumption aligns with output.
- **Pricing Recommendations:** Suggests optimal pricing per egg.

### 📊 Production Monitoring
- Track daily egg production & feed consumption.
- Log flock health & environmental conditions.

### 🛒 Marketplace Module
- Direct-to-consumer product listings (e.g., eggs, live birds).
- Seamless order placement and tracking for buyers.

### 🔗 Community Linkage
- Integrated directory of Veterinarians, Feed Suppliers, and Cooperatives.
- Basic contact and messaging features to support farm operations.

### ⚙️ Admin Dashboard
- Manage users, monitor the system, and generate comprehensive reports.

---

## 🛠️ Technologies Built With

- **Backend:** Flask, Python 3.10+
- **Database:** MySQL (XAMPP), SQLAlchemy (ORM), Flask-Migrate
- **Data Analytics:** Pandas, Scikit-learn
- **Frontend:** Jinja2 Templates, HTML5/CSS3 (Bootstrap)
- **Deployment:** Vercel / Gunicorn

---

## 🚀 Setup Guide

Follow these steps to get a local copy up and running.

### 1. Prerequisites
Ensure you have the following installed:
- [Python 3.10+](https://www.python.org/downloads/)
- [XAMPP](https://www.apachefriends.org/index.html) (for Apache + MySQL)
- Git

### 2. Clone the Repository
```bash
git clone https://github.com/Luxanna22/poultryconnect.git
cd poultryconnect
```

### 3. Create a Virtual Environment
Isolate your dependencies using a virtual environment:

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

**macOS / Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 4. Install Dependencies
```bash
pip install -r requirements.txt
```

### 5. Configure Environment Variables
Copy the example environment file and fill in your details:
```bash
cp .env.example .env
```
Update your `.env` file:
```env
FLASK_ENV=development
SECRET_KEY=your-super-secret-key
# XAMPP default format (no password):
DATABASE_URL=mysql+pymysql://root:@localhost/poultryconnect
```

### 6. XAMPP MySQL Setup
1. Open **XAMPP Control Panel** and **Start** both `Apache` and `MySQL`.
2. Navigate to `http://localhost/phpmyadmin` in your browser.
3. Create a new database named `poultryconnect` with collation `utf8mb4_unicode_ci`.

### 7. Run Database Migrations
Initialize and create the database tables:
```bash
flask db init              # Only needed the first time
flask db migrate -m "init"
flask db upgrade
```

### 8. Run the Application
```bash
python run.py
```
Open your browser and navigate to **http://127.0.0.1:5000**.

---

## 👥 User Roles

PoultryConnect 2.0 supports a role-based access control system tailored to the agricultural ecosystem:

| Role | Responsibilities & Access |
|------|---------------------------|
| 👑 **Admin** | Manages users, system reports, and oversees the entire platform. |
| 🐔 **Farmer** | Manages farms, logs production, views analytics, and sells on the marketplace. |
| 👨‍🌾 **Staff** | Handles daily data entry (production, feed, health) for the farm. |
| 🛒 **Buyer** | Browses the marketplace and places orders for farm products. |
| 💊 **Veterinarian** | Listed in the community directory to assist with flock health. |
| 🌾 **Feed Supplier** | Listed in the community directory for easy ordering and contact. |

---

## ❓ Common Issues & Troubleshooting

- **`ModuleNotFoundError: No module named 'pymysql'`**
  Ensure your virtual environment is active and you have run `pip install -r requirements.txt`.
- **`Access denied for user 'root'@'localhost'`**
  Check that the MySQL password in your `.env` file matches your XAMPP configuration (default is usually blank).
- **`Target database is not up to date`**
  Run `flask db upgrade` before making new migrations.
- **Port 5000 already in use**
  Run the app on a different port: `flask run --port 5001`.

---

<div align="center">
  <i>PoultryConnect 2.0 — Built to elevate Filipino Poultry Farmers 🇵🇭</i>
</div>
