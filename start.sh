#!/bin/bash

# Navigate to the script's directory so it can be run from anywhere
cd "$(dirname "$0")"

echo "✨ Starting Nexus Engine (Chess Analysis Tool) ✨"

# ==========================================
# 1. Setup Backend
# ==========================================
cd backend

if [ ! -d "venv" ]; then
    echo "📦 First time setup: Installing Python backend dependencies..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    deactivate
else
    echo "✅ Python backend dependencies already installed."
fi
cd ..

# ==========================================
# 2. Setup Frontend
# ==========================================
cd frontend

if [ ! -d "node_modules" ]; then
    echo "📦 First time setup: Installing Next.js frontend dependencies..."
    npm install
else
    echo "✅ Next.js frontend dependencies already installed."
fi
cd ..

echo ""
echo "🚀 Starting servers..."

# ==========================================
# 3. Start Services & Handle Shutdown
# ==========================================

# Function to elegantly kill background processes when Ctrl+C is pressed
cleanup() {
    echo ""
    echo "🛑 Shutting down Nexus Engine..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 0
}

# Catch the Ctrl+C signal and run the cleanup function
trap cleanup SIGINT SIGTERM

# Start Backend in the background
cd backend
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000 > /dev/null 2>&1 &
BACKEND_PID=$!
cd ..

# Start Frontend in the background
cd frontend
npm run dev > /dev/null 2>&1 &
FRONTEND_PID=$!
cd ..

echo ""
echo "====================================================="
echo "🟢 Nexus Engine is running!"
echo "🌐 Dashboard: http://localhost:3000"
echo "🔌 Backend WS: ws://localhost:8000/ws"
echo "====================================================="
echo "Press Ctrl+C to safely stop both servers."

# Wait indefinitely for background processes (this keeps the script running)
wait
