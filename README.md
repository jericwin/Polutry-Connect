<div align="center">

# 🐔 PoultryConnect 2.0 

**Empowering Smallholder Poultry Farmers with Data & Connectivity**

[![Python Version](https://img.shields.io/badge/python-3.10%2B-blue?style=for-the-badge&logo=python&logoColor=white)](#)
[![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)](#)
[![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)](#)
[![Bootstrap](https://img.shields.io/badge/bootstrap-%238511FA.svg?style=for-the-badge&logo=bootstrap&logoColor=white)](#)

*A centralized web-based platform to monitor operations, analyze production, and connect with the agricultural community.*

[Explore Features](#-core-features) • [Quick Setup Guide](SETUP_GUIDE.md) • [User Roles](#-user-roles)

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
- Multi-category buyer review and feedback intelligence.

### 🔗 Community Linkage
- Integrated directory of Veterinarians, Feed Suppliers, and Cooperatives.
- Basic contact and messaging features to support farm operations.

### ⚙️ Admin Dashboard
- Manage users, monitor the system, review farmer verifications, and oversee accounts.

---

## 🛠️ Technologies Built With

- **Backend:** Flask, Python 3.10+
- **Database:** MySQL (XAMPP), SQLAlchemy (ORM), Flask-Migrate
- **Data Analytics:** Pandas, Scikit-learn
- **Frontend:** Jinja2 Templates, HTML5/CSS3 (Bootstrap)
- **Deployment:** Vercel / Gunicorn

---

## 🚀 Setup Guide

> 📖 **Detailed Step-by-Step Guide with Screenshots and Troubleshooting:**  
> Tingnan ang [**`SETUP_GUIDE.md`**](SETUP_GUIDE.md) para sa kumpletong gabay gamit ang **VS Code** at **XAMPP**.

### Quick Start:

#### 1. Clone the Repository
```bash
git clone https://github.com/jericwin/Polutry-Connect.git
cd Polutry-Connect
```

#### 2. Create and Activate Virtual Environment
**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

#### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

#### 4. Configure `.env`
Copy the `.env.example` file:
```bash
cp .env.example .env
```
Ensure your `.env` connects to your XAMPP MySQL database:
```env
FLASK_ENV=development
SECRET_KEY=poultryconnect-super-secret-key-2026
DATABASE_URL=mysql+pymysql://root:@localhost/poultryconnect
```

#### 5. Database Setup (XAMPP phpMyAdmin)
1. Start **Apache** and **MySQL** in XAMPP Control Panel.
2. Open `http://localhost/phpmyadmin` and create a database named `poultryconnect`.
3. Select `poultryconnect`, go to the **Import** tab, choose `poultryconnect.sql`, and click **Import**.

#### 6. Run the Application
```bash
python run.py
```
Open **http://127.0.0.1:5000** in your browser.

---

## 🔑 Default Login Credentials

| Role | Username / Email | Password | Access |
| :--- | :--- | :--- | :--- |
| 👑 **Admin** | `admin` / `admin@poultryconnect.com` | `admin123` | System Management, Farmer Verification, All Reports |
| 🐔 **Farmer** | `jdelacruz` / `farmer@poultryconnect.com` | `password123` | Farm Management, Production Logs, P&L Analytics, Products |
| 🛒 **Buyer** | `mreyes` / `buyer@poultryconnect.com` | `password123` | Marketplace Shopping, Order Tracking, Feedback |

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
