# Consolidate Docker Installation Guide

This guide will help you install and run Consolidate using Docker and the provided `server.sh` script.

## Prerequisites

- **Docker**: You must have Docker installed on your system. [Install Docker](https://docs.docker.com/engine/install/)
- **Git**: You must have Git installed. [Install Git](https://git-scm.com/downloads)

## Installation Steps

1. **Clone the Repository**

   Open a terminal and run:
   ```bash
   git clone https://github.com/Consolidate-Software/consolidate-docker.git
   cd consolidate-docker
   ```

2. **Run the Setup Script**

   The main script for setup and management is `server.sh`. You may need to make it executable:
   ```bash
   chmod +x server.sh
   ```

   To configure the application, run:
   ```bash
   ./server.sh configure
   ```
   This will prompt you for configuration details and create a `.env` file.

3. **Start the Application**

   To start the application:
   ```bash
   ./server.sh start
   ```

4. **Stop the Application**

   To stop the application:
   ```bash
   ./server.sh stop
   ```

5. **Update the Application**

   To update to the latest version:
   ```bash
   ./server.sh update
   ```
   This will pull the latest code and update the running containers.

## Additional Notes

- You can view logs with:
  ```bash
  docker compose logs -f
  ```
- If you encounter permission issues with Docker, ensure your user is in the `docker` group or run the script with `sudo`.
