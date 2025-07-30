# 📚 Helpjuice FAQ - Internship Task

This project is a simplified version of a **FAQ management system** built as part of the Helpjuice internship task. It allows users to create articles and categories, search articles in real-time, and analyze user search behavior using Redis and background jobs.

---

## ✨ Features

- 🔍 **Search Tracking** with IP uniqueness and Redis caching
- 🧠 **Related Query Deduplication** (e.g., `rub` + `ruby` = one record)
- ⏪ **Fallback to Database** for search analytics
- 🗂️ CRUD operations for:
  - Articles
  - Categories
- 📈 **Search Analytics View** (JS frontend)
- 🧵 **Background Jobs** using ActiveJob
- ⚡ Redis integration
- 📦 JSON API (used by JS frontend)

---

## 🛠 Tech Stack

| Layer       | Tech Used                     |
|-------------|-------------------------------|
| Backend     | Ruby on Rails (API Mode)      |
| DB          | PostgreSQL                    |
| Caching     | Redis                         |
| Jobs        | ActiveJob + Redis             |
| Frontend    | Vanilla JavaScript + HTML/CSS |
| Testing     | RSpec (optional)              |

---

## 🚀 Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/your-username/helpjuice_faq.git
cd helpjuice_faq

bundle install
yarn install # If using JS dependencies

rails db:create db:migrate db:seed

redis-server.exe

rails s
