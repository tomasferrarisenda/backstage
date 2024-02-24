# Use a Node.js base image
FROM node:14

# Copy the nginx.conf file to the appropriate directory in the Docker container
COPY nginx.conf /etc/nginx/conf.d

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the server files
COPY . .

# Expose the server port
EXPOSE 3000

# Start the server
CMD [ "node", "app.js" ]