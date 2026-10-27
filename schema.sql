-- SmartStock AI PostgreSQL Schema for Supabase

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100) NOT NULL,
    current_stock INTEGER NOT NULL DEFAULT 0,
    reorder_level INTEGER NOT NULL DEFAULT 10,
    target_stock INTEGER NOT NULL DEFAULT 50,
    unit_cost NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    daily_demand NUMERIC(6, 2) NOT NULL DEFAULT 1.00,
    lead_time_days INTEGER NOT NULL DEFAULT 3,
    safety_stock INTEGER NOT NULL DEFAULT 5,
    supplier VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. REORDERS TABLE
CREATE TABLE IF NOT EXISTS reorders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    current_stock INTEGER NOT NULL,
    reorder_point INTEGER NOT NULL,
    recommended_quantity INTEGER NOT NULL,
    priority VARCHAR(50) NOT NULL CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING_APPROVAL' CHECK (status IN ('RECOMMENDED', 'PENDING_APPROVAL', 'APPROVED', 'ORDERED', 'RECEIVED', 'CANCELLED')),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    ordered_at TIMESTAMPTZ,
    received_at TIMESTAMPTZ
);

-- 3. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reorder_id UUID REFERENCES reorders(id) ON DELETE SET NULL,
    channel VARCHAR(50) NOT NULL CHECK (channel IN ('whatsapp', 'email')),
    recipient VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('SENT', 'FAILED', 'SIMULATED')),
    message TEXT NOT NULL,
    sent_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. AGENT RUNS TABLE
CREATE TABLE IF NOT EXISTS agent_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status VARCHAR(50) NOT NULL,
    items_evaluated INTEGER NOT NULL DEFAULT 0,
    reorders_triggered INTEGER NOT NULL DEFAULT 0,
    summary TEXT
);

-- 5. ACTIVITY LOGS TABLE
CREATE TABLE IF NOT EXISTS activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    event_type VARCHAR(100) NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    description TEXT NOT NULL,
    previous_stock INTEGER,
    new_stock INTEGER,
    metadata JSONB
);

-- Row Level Security (RLS) setup
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE reorders ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated full access" ON products FOR ALL USING (true);
CREATE POLICY "Allow authenticated full access" ON reorders FOR ALL USING (true);
