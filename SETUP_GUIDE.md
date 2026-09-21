# 🚀 PoultryConnect 2.0 — Setup & Run Guide (VS Code + XAMPP)

Sundin ang gabay na ito para patakbuhin ang **PoultryConnect** sa iyong computer pagkatapos i-download o i-clone ang repository mula sa GitHub.

---

## 📋 1. Mga Kailangan (Prerequisites)

Bago magsimula, siguraduhing naka-install ang sumusunod sa iyong computer:
1. **[VS Code](https://code.visualstudio.com/)** (Visual Studio Code)
2. **[Python 3.10+](https://www.python.org/downloads/)**
   * *Mahalaga:* Habang ini-install ang Python, lagyan ng tsek ang **"Add python.exe to PATH"**.
3. **[XAMPP](https://www.apachefriends.org/index.html)** (para sa Apache at MySQL)

---

## 🛠️ 2. Step-by-Step Installation Guide

### Hakbang 1: Buksan ang Project sa VS Code
1. I-extract ang na-download na zip file mula sa GitHub (kung naka-zip).
2. Buksan ang **VS Code**.
3. Pindutin ang **File** > **Open Folder...** at piliin ang folder ng project (kung nasaan ang `run.py` at `requirements.txt`).

---

### Hakbang 2: Simulan ang XAMPP (Apache at MySQL)
1. Buksan ang **XAMPP Control Panel**.
2. I-click ang **Start** sa tapat ng **Apache**.
3. I-click ang **Start** sa tapat ng **MySQL**.
> *Dapat maging kulay berde (green) ang parehong module bago magpatuloy.*

---

### Hakbang 3: I-setup at I-import ang Database sa phpMyAdmin
1. Buksan ang browser (Chrome, Edge, Firefox) at pumunta sa:  
   👉 **http://localhost/phpmyadmin**
2. Sa kaliwang menu, i-click ang **New**.
3. Sa **Database name**, ilagay:
   ```text
   poultryconnect
   ```
4. Piliin ang Collation bilang `utf8mb4_unicode_ci` (o iwanan sa default) at i-click ang **Create**.
5. I-click ang bagong likhang database na **`poultryconnect`** sa kaliwang sidebar.
6. Sa itaas na tabs, piliin ang **Import**.
7. Sa **Choose File**, piliin ang **`poultryconnect.sql`** na nasa loob ng folder ng project.
8. Mag-scroll pababa at i-click ang **Import** (o **Go**).
> *Lalabas ang berdeng notification na matagumpay na na-import ang lahat ng 18 tables.*

---

### Hakbang 4: Gumawa ng Python Virtual Environment sa VS Code
1. Sa VS Code, buksan ang terminal: pindutin ang `Ctrl` + `~` (o menu: **Terminal** > **New Terminal**).
2. Gumawa ng virtual environment gamit ang command na:
   ```powershell
   python -m venv venv
   ```
3. I-activate ang virtual environment:
   ```powershell
   venv\Scripts\activate
   ```
   *(May lalabas na `(venv)` sa kaliwa ng iyong terminal prompt kapag aktibo na).*

---

### Hakbang 5: I-install ang mga Dependencies
Habang aktibo ang `(venv)`, patakbuhin:
```powershell
pip install -r requirements.txt
```
*(Hintaying matapos ang pag-download at pag-install ng lahat ng kailangang packages tulad ng Flask, SQLAlchemy, PyMySQL, atbp.)*

---

### Hakbang 6: I-setup ang `.env` File
1. Gumawa ng bagong file sa root folder na pinangalanang **`.env`** (o kopyahin ang `.env.example`).
2. Ilagay ang sumusunod na configuration:
   ```env
   FLASK_ENV=development
   SECRET_KEY=poultryconnect-super-secret-key-2026
   DATABASE_URL=mysql+pymysql://root:@localhost/poultryconnect
   ```
   *(Default sa XAMPP ang username na `root` na walang password).*

---

### Hakbang 7: Patakbuhin ang System
Sa terminal, patakbuhin:
```powershell
python run.py
```

Makikita mo ang output na:
```text
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://127.0.0.1:5000
```

---

### Hakbang 8: Buksan sa Web Browser
Buksan ang browser at magtungo sa:  
👉 **http://127.0.0.1:5000**

---

## 🔑 3. Default Login Credentials para sa Testing

Pumunta sa **http://127.0.0.1:5000/auth/login** at gamitin ang alinman sa mga accounts na ito:

| Role | Username / Email | Password | Mga Tampok / Access |
| :--- | :--- | :--- | :--- |
| 👑 **Admin** | `admin` <br> `admin@poultryconnect.com` | `admin123` | Buong platform access, Account Management, Farmer Verifications, Reports |
| 🐔 **Farmer** | `jdelacruz` <br> `farmer@poultryconnect.com` | `password123` | Farm Dashboard, Daily Egg/Feed Logs, P&L Analytics, Product Listings, Review Monitoring |
| 🛒 **Buyer** | `mreyes` <br> `buyer@poultryconnect.com` | `password123` | Marketplace Browsing, Order Cart/Checkout, Multi-Category Feedback submission |

---

## ❓ 4. Mga Karaniwang Tanong at Troubleshooting

* **Q: Paano kung `ModuleNotFoundError: No module named 'flask'` ang lumabas?**  
  Siguraduhing na-activate mo ang virtual environment (`venv\Scripts\activate`) bago magpatakbo ng `pip install -r requirements.txt` at `python run.py`.

* **Q: Paano kung `Access denied for user 'root'@'localhost'`?**  
  Siguraduhing tumatakbo ang MySQL sa XAMPP at tama ang format sa `.env`: `mysql+pymysql://root:@localhost/poultryconnect` (walang password pagkatapos ng colon).

* **Q: Paano kung may port conflict (`Address already in use` sa port 5000)?**  
  Patakbuhin sa ibang port gamit ang:
  ```powershell
  flask run --port 5001
  ```
