# 🏛️ ExamSphere — Scalable Modular-Monolith Backend Architecture

[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-4.19-black?logo=express&logoColor=white)](https://expressjs.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-7.0-DC382D?logo=redis&logoColor=white)](https://redis.io/)
[![OWASP](https://img.shields.io/badge/OWASP-Security%20SRS-E11D48?logo=owasp&logoColor=white)](https://owasp.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

**ExamSphere** is an enterprise-scale educational backend architecture and evaluation platform engineered with a **modular-monolith** pattern on **PostgreSQL**, **Node.js**, **Express.js**, and **Redis**. Designed for high-concurrency student assessments, automated spaced-repetition retention, and sub-millisecond search query execution.

---

## 🌟 Key Architecture & Highlights

- **Modular-Monolith Architecture**: Decoupled domain modules (`Auth`, `Content`, `Quiz`, `Search`, `Progress`, `Notification`, `Admin`) sharing an optimized PostgreSQL transactional layer while maintaining strict domain isolation.
- **Relational Schema of 10+ Entities**: Modeled with Third Normal Form (3NF) zero-redundancy normalization, cascading constraints, and many-to-many junction mappings.
- **Composite & GIN Indexes**: Generalized Inverted Index (GIN) configured for rapid full-text search across thousands of questions, coupled with composite B-tree indexes for user quiz history.
- **Spaced-Repetition Scheduling (SM-2 Algorithm)**: Exponential retention interval calculations based on cognitive difficulty factors ($EF$) and repetition counts.
- **Content-Verification Finite State Machine (FSM)**: Strict verification workflow (`DRAFT` ➔ `PENDING_REVIEW` ➔ `VERIFIED` ➔ `PUBLISHED` ➔ `ARCHIVED`).
- **OWASP-Aligned Security SRS**: Defense against Top 10 vulnerabilities (parameterized SQL queries, bcrypt hashing, JWT RBAC authorization, and Redis rate limiting).

---

## 🗄️ Relational Database Schema (10+ Entities)

```sql
users ───────────< user_roles >─────────── roles
  │
  ├──────────────< quiz_sessions ────────< quiz_answers >──────── questions
  │                     │                                             │
  ├──────────────< spaced_reviews                                     ├────< question_categories >──── categories
  │                                                                   │
  └──────────────< audit_logs                                         └────< content_verifications
```

---

## 🧠 Spaced-Repetition Algorithm (SM-2 Implementation)

The spaced-repetition module calculates optimal review intervals using the SuperMemo SM-2 algorithmic formulation:

$$EF' = EF + (0.1 - (5 - q) \times (0.08 + (5 - q) \times 0.02))$$

$$I(n) = \begin{cases} 1 & n = 1 \\ 6 & n = 2 \\ I(n-1) \times EF & n > 2 \end{cases}$$

Where:
- $q$: Quality of response (0 to 5)
- $EF$: Easiness factor (default 2.5, minimum threshold 1.3)
- $I(n)$: Interval in days for repetition $n$

---

## 🚀 Quickstart

```bash
# Clone the repository
git clone https://github.com/MIHIR-1304/ExamSphere.git
cd ExamSphere

# Launch PostgreSQL 16, Redis, and Express Backend via Docker
docker compose up -d --build
```

Access the endpoints:
- **Interactive Web Client & SRS Explorer**: `http://localhost:4000`
- **Express REST API**: `http://localhost:4000/api/v1`
- **PostgreSQL**: `localhost:5432/examsphere_db`
- **Redis Cache**: `localhost:6379`

---

## 👨‍💻 Author

**Mihir Mahato**  
Software Developer | B.Tech CSE 2026  
GitHub: [@MIHIR-1304](https://github.com/MIHIR-1304)  
LinkedIn: [Mihir Mahato](https://www.linkedin.com/in/mihir-mahato-btech)  
Email: mihirmahato1304@gmail.com
