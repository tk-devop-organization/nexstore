# Frontend: React Application Dockerfile

# Use an official Node.js image
FROM node:16

# Set the working directory for the frontend
WORKDIR /frontend

# Install dependencies for the frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

# Copy the rest of the frontend files
COPY frontend/ ./

# Build the React application
RUN npm run build

# Expose the frontend port (default for React)
EXPOSE 3001

# Start the React app (or use the appropriate command for your setup)
CMD ["npm", "start"]
