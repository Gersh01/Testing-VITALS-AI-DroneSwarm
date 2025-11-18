FROM ubuntu:22.04

WORKDIR /app

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    python3.11-dev \
    build-essential \
    libgdal-dev \
    libspatialindex-dev \
    libpq-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Set python3.11 as default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies with increased timeout and retries
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --timeout=1000 --retries=5 -r requirements.txt && \
    echo "\n========================================" && \
    echo "Installed Python Packages:" && \
    echo "========================================\n" && \
    pip list

# Copy the entire app directory
COPY . .

# Print all dependencies when container runs
CMD ["sh", "-c", "echo '\n========================================'; echo 'Python Dependencies:'; echo '========================================'; pip list; echo '\n========================================'; echo 'System Packages:'; echo '========================================'; dpkg -l | grep '^ii' | awk '{print $2, $3}'; echo '\n========================================'; echo 'Application Ready'; echo '========================================'; exec bash"]
