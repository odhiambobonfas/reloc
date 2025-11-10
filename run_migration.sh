#!/bin/bash

# Database Migration Script
# This script will add missing columns to your existing database tables

echo "🔧 Running database migration..."

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

# Run the migration script
echo "📝 Running migration script..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database_migration.sql

if [ $? -eq 0 ]; then
    echo "✅ Migration completed successfully!"
    echo ""
    echo "📊 Migration Summary:"
    echo "   - Added missing columns to posts table"
    echo "   - Added missing columns to comments table"
    echo "   - Added missing columns to messages table"
    echo "   - Created performance indexes"
    echo ""
    echo "🎉 Your database is now ready for the enhanced app!"
else
    echo "❌ Migration failed. Please check the error messages above."
    exit 1
fi