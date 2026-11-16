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

### Hakbang 3: I-import ang Database sa phpMyAdmin
1. Buksan ang browser at pumunta sa:
   👉 **http://localhost/phpmyadmin**
2. I-click ang tab na **Import** sa itaas (hindi na kailangang gumawa muna ng database — kusa itong gagawa ng `poultryconnect`).
3. Sa **Choose File**, piliin ang **`poultryconnect_xampp.sql`** na nasa loob ng folder ng project.
4. Mag-scroll pababa at i-click ang **Import** (o **Go**).
> *Lalabas ang berdeng notification. Dapat may 18 tables sa `poultryconnect` database.*
> *Kung may luma ka nang `poultryconnect` database, papalitan ito ng bagong data (DROP + CREATE).*

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

### Hakbang 6: I-setup ang `.env` File (Optional)
Hindi na kailangan ng `.env` para sa XAMPP — kusang kumokonekta ang system sa MySQL ng XAMPP (`root`, walang password, `127.0.0.1:3306`, database `poultryconnect`) kapag naka-Start ito.

Kung gusto mong i-set nang manual, gumawa ng **`.env`** sa root folder:
```env
FLASK_ENV=development
SECRET_KEY=poultryconnect-super-secret-key-2026
DATABASE_URL=mysql+pymysql://root:@localhost/poultryconnect
```
> ⚠️ Huwag ilagay ang `DATABASE_URL=sqlite:///...` kung XAMPP ang gagamitin.
> Kung hindi naka-Start ang MySQL, gagamitin ng system ang kasamang SQLite file (`instance/poultryconnect.db`) para gumana pa rin.

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
| 👑 **Admin** | `admin` <br> `admin@poultryconnect.com` | `Admin#2026` | Buong platform access, Account Management, Owner Verifications, Reports |
| 🐔 **Owner** | `ardonn` <br> `ardonn.sales@poultryconnect.com` | `Ardonn#2026` | Ardonn Farm — Brgy. Macasipac, Sta. Maria, Laguna (300 layers) |
| 🐔 **Owner** | `benito` <br> `benito.valmonte@poultryconnect.com` | `Benito#2026` | Benito Farm — Brgy. Iniyapan, Sta. Maria, Laguna (1,200 layers) |
| 🐔 **Owner** | `jane` <br> `jane.ison@poultryconnect.com` | `Jane#2026` | Coco-A-Vanilla Farm — Brgy. Bubucal, Sta. Maria, Laguna (350 layers) |
| 🐔 **Owner** | `digna` <br> `digna.fernandez@poultryconnect.com` | `Digna#2026` | Ising's Farm — Brgy. Balian, Pangil, Laguna (300 layers) |
| 🛒 **Buyer** | `liza` / `ramon` / `carla` <br> `liza.manalo@poultryconnect.com` | `Buyer#2026` | Marketplace, Cart/Checkout, Order Tracking, Feedback |

> Sample data: Oct 1 – Nov 16, 2026. Para i-reset ang lahat ng data at accounts: `python seed_revision.py` tapos `python scripts/export_mysql_dump.py`.

---

## ❓ 4. Mga Karaniwang Tanong at Troubleshooting

* **Q: Paano kung `ModuleNotFoundError: No module named 'flask'` ang lumabas?**  
  Siguraduhing na-activate mo ang virtual environment (`venv\Scripts\activate`) bago magpatakbo ng `pip install -r requirements.txt` at `python run.py`.

* **Q: Paano kung `Access denied for user 'root'@'localhost'`?**  
  Siguraduhing tumatakbo ang MySQL sa XAMPP at tama ang format sa `.env`: `mysql+pymysql://root:@localhost/poultryconnect` (walang password pagkatapos ng colon).

* **Q: Paano kung `Packet too large` / hindi ma-upload ang malaking picture?**
  Kusa nang tinataasan ng system ang `max_allowed_packet` ng XAMPP sa 16 MB at pinaliliit ang malalaking picture. Kung lumabas pa rin, i-edit ang `C:\xampp\mysql\bin\my.ini`, palitan ang `max_allowed_packet=1M` ng `max_allowed_packet=16M` sa ilalim ng `[mysqld]`, at i-restart ang MySQL.

* **Q: Paano kung may port conflict (`Address already in use` sa port 5000)?**  
  Patakbuhin sa ibang port gamit ang:
  ```powershell
  flask run --port 5001
  ```
