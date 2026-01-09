# Liora 🌸

**Liora** is a privacy-first menstrual cycle tracking and wellness e-commerce platform built using **Flutter**, **Firebase**, and **Node.js**. The application is designed to help users better understand their menstrual health through accurate cycle predictions, visual calendar insights, smart notifications, and access to trusted wellness products—all in one place.

This project is currently under active development and aims to balance **medical responsibility**, **user empathy**, and **technological precision**.

---

## 📌 Purpose of the Application

Menstrual health is often misunderstood, under-discussed, or tracked using unreliable methods. Liora is being created to:

* Provide **clear and understandable menstrual cycle tracking**
* Help users **anticipate periods and fertile windows**
* Reduce anxiety by sending **timely notifications**
* Offer **personalized insights** based on user-specific parameters
* Combine health tracking with a **wellness-focused e-commerce experience**
* Maintain **data privacy, transparency, and user control**

Liora does **not** aim to replace medical professionals. Instead, it works as a **supportive digital companion** that helps users observe patterns and make informed lifestyle decisions.

---

## 🧠 How Liora Works (Concept Overview)

Liora collects a small set of essential, non-invasive user inputs. Using these parameters, the system applies rule-based mathematical models to generate a **short-term cycle prediction (3–6 months maximum)**.

Predictions are continuously refined when the user updates their cycle data.

---

## 🧾 User Data & Parameters Collected

Liora only asks for information that is **strictly necessary** for menstrual cycle calculation.

### 1. Basic Profile Information

* **Name** (for personalization)
* **Date of Birth**

  * Used to calculate **age**
  * Age helps improve calculation logic and future insights

### 2. Menstrual Cycle Inputs

These parameters form the foundation of the tracking algorithm:

* **Last Period Start Date**

  * Day
  * Month
  * Year

* **Average Cycle Length (in days)**

  * Common value: 28 days
  * Can vary between users (e.g., 21–35 days)

* **Average Period Duration (in days)**

  * Minimum: 3 days
  * Common range: 5–7 days
  * Can extend beyond 7 days for some users

All data is securely stored using **Firebase** and can be updated at any time by the user.

---

## 📅 Calendar & Visualization System

The in-app calendar is the core interface of Liora. It visually represents menstrual and fertility-related phases using **distinct colors and markers**.

### Calendar Highlights

* 🩸 **Predicted Period Days**
  Displays expected bleeding days based on historical data

* 🌱 **Ovulation Window**
  Indicates the most probable fertile period

* ⭐ **High Fertility Days**
  Based on ovulation estimation

* 🗂 **Cycle History**
  Past cycles are stored and accessible for reference

The system avoids long-term predictions beyond **3–4 months**, as accuracy decreases over time.

---

## 🧮 Menstrual Cycle Algorithm (Mathematical Model)

Liora uses a **rule-based deterministic algorithm**, not AI or machine learning (yet).

### Step-by-Step Logic

1. **Age Calculation**

   ```
   Age = Current Date − Date of Birth
   ```

2. **Next Period Prediction**

   ```
   Next Period Start = Last Period Start Date + Average Cycle Length
   ```

3. **Period Duration Mapping**

   ```
   Period End Date = Period Start Date + Average Period Length
   ```

4. **Ovulation Estimation**
   Ovulation typically occurs:

   ```
   Ovulation Day = Cycle Length − 14
   ```

5. **Fertile Window Calculation**

   ```
   Fertile Window = Ovulation Day ± 4 days
   ```

6. **Short-Term Forecasting**

   * Predictions are generated for **up to 3–6 cycles only**
   * Accuracy is prioritized over long-term assumptions

---

## 🔄 Cycle Update & User Control

* Every **4 months**, Liora prompts users to:

  * Update cycle details
  * Confirm current accuracy

### User Choices

* ✅ Update cycle → New calculations applied
* ❌ Skip update → Previous prediction logic continues

All previous data remains stored as **cycle history**.

---

## 🔔 Smart Notification System

Liora includes an automated notification engine:

* ⏰ Period-start alerts (advance reminders)
* 🌸 Fertility window notifications
* 📝 Cycle update reminders

Notifications are configurable and fully controlled by the user.

---

## 🛒 Wellness E-Commerce Integration

Liora also functions as a wellness marketplace where users can:

* Browse menstrual & wellness products
* View items relevant to their cycle phase
* Access trusted and curated products

This integration is designed to feel **supportive, not intrusive**.

---

## 🧑‍💻 Technology Stack

* **Frontend:** Flutter (Android-focused)
* **Backend:** Node.js
* **Database & Auth:** Firebase (Firestore, Authentication)
* **Version Control:** Git & GitHub
* **Development Tools:** Android Studio

---

## 🔐 Privacy & Ethics

* No unnecessary data collection
* No data selling or sharing
* Full user control over updates
* Transparent calculation logic

Liora respects menstrual health as **personal, sensitive, and private**.

---

## 👥 Contributors

* **Alwin Madhu** – [@alwin-m](https://github.com/alwin-m)
* **Abhishek** – [@abhishek-2006-7](https://github.com/abhishek-2006-7)
* **Nejin Bejoy** – [@nejinbejoy](https://github.com/nejinbejoy)
* **Majumnair** – [@Majumnair](https://github.com/Majumnair)
* **Siraj** – [@Siraj](https://github.com/sirajudheen7official-boop)

📧 **Team Lead:** [alwinmadhu7@gmail.com](mailto:alwinmadhu7@gmail.com)

---

## 🚧 Project Status

This README is a **living document** and will evolve as Liora grows.

Future plans include:

* Advanced health insights
* Smarter pattern detection
* Better accessibility
* Improved personalization
