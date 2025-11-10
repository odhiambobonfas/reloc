#!/bin/bash

# Database Setup Script for Reloc App
# This script will set up the PostgreSQL database with the correct schema

echo "🚀 Setting up Reloc Database..."

# Database connection details
DB_HOST="192.168.20.207"
DB_PORT="5432"
DB_NAME="reloc"
DB_USER="postgres"
DB_PASSWORD="Othina78"

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL client (psql) is not installed or not in PATH"
    exit 1
fi

# Test database connection
echo "🔍 Testing database connection..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Cannot connect to database. Please check your connection details."
    echo "Host: $DB_HOST"
    echo "Port: $DB_PORT"
    echo "Database: $DB_NAME"
    echo "User: $DB_USER"
    exit 1
fi

echo "✅ Database connection successful!"

# Run the database setup script
echo "📝 Creating tables and indexes..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database_setup.sql

if [ $? -eq 0 ]; then
    echo "✅ Database setup completed successfully!"
    echo ""
    echo "📊 Database Summary:"
    echo "   - Posts table created with media_url support"
    echo "   - Comments table created with nested replies support"
    echo "   - Messages table created for chat functionality"
    echo "   - Indexes created for better performance"
    echo "   - Sample data inserted for testing"
    echo ""
    echo "🎉 Your Reloc backend is ready to use!"
else
    echo "❌ Database setup failed. Please check the error messages above."
    exit 1
fi