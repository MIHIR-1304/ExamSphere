-- ========================================================
-- ExamSphere: PostgreSQL Relational Schema (10+ Entities)
-- 3NF Normalization, Composite & GIN Indexes, OWASP Security
-- Author: Mihir Mahato
-- ========================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 1. Users Entity
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Roles Entity (RBAC)
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- 3. User Roles (Many-to-Many Junction)
CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- 4. Categories Entity
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL,
    description TEXT
);

-- 5. Questions Bank Entity
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'MEDIUM', -- EASY, MEDIUM, HARD, EXPERT
    explanation TEXT,
    points INT DEFAULT 1,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Question Categories Junction
CREATE TABLE question_categories (
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    category_id INT REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (question_id, category_id)
);

-- 7. Content Verifications Entity (Finite State Machine)
CREATE TABLE content_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES users(id),
    status VARCHAR(30) DEFAULT 'PENDING_REVIEW', -- DRAFT, PENDING_REVIEW, VERIFIED, REJECTED, ARCHIVED
    review_notes TEXT,
    verified_at TIMESTAMP WITH TIME ZONE
);

-- 8. Quiz Sessions Entity
CREATE TABLE quiz_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    status VARCHAR(30) DEFAULT 'IN_PROGRESS', -- IN_PROGRESS, COMPLETED, ABANDONED
    total_score NUMERIC(5, 2) DEFAULT 0.0,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 9. Quiz Answers Entity
CREATE TABLE quiz_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES quiz_sessions(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id) ON DELETE RESTRICT,
    selected_option TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL,
    time_spent_seconds INT DEFAULT 0,
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Spaced Reviews Entity (SM-2 Algorithm Retention State)
CREATE TABLE spaced_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    repetition_number INT DEFAULT 0,
    easiness_factor NUMERIC(4, 2) DEFAULT 2.50,
    interval_days INT DEFAULT 1,
    last_reviewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    next_review_due TIMESTAMP WITH TIME ZONE NOT NULL,
    quality_score INT DEFAULT 5 -- 0 to 5
);

-- 11. Progress Metrics Entity
CREATE TABLE progress_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id INT REFERENCES categories(id) ON DELETE CASCADE,
    mastery_percentage NUMERIC(5, 2) DEFAULT 0.0,
    total_answered INT DEFAULT 0,
    total_correct INT DEFAULT 0,
    last_computed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. Security Audit Logs Entity (OWASP Accountability)
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    ip_address VARCHAR(50),
    user_agent TEXT,
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- INDEX OPTIMIZATIONS (GIN & Composite B-Tree Indexes)
-- ========================================================

-- GIN Index for Sub-Millisecond Full-Text Search on Questions
CREATE INDEX idx_questions_content_gin ON questions USING gin(to_tsvector('english', title || ' ' || content));

-- Composite B-Tree Indexes for High-Traffic Query Filters
CREATE INDEX idx_quiz_sessions_user_status ON quiz_sessions(user_id, status);
CREATE INDEX idx_spaced_reviews_user_due ON spaced_reviews(user_id, next_review_due);
CREATE INDEX idx_quiz_answers_session_question ON quiz_answers(session_id, question_id);
CREATE INDEX idx_audit_logs_user_action ON audit_logs(user_id, action, created_at);
