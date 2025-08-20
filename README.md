(Für die Deutsch Anleitung klicken Sie [hier](./README.de.md).)

# Consolidate On-Premise Installation Guide

This guide will help you install and run Consolidate On-Premise using Docker and the provided `server.sh` script.

**Important Notice**

Running Consolidate On-Premise requires that you can securely administer a web server, including regular operating system updates, firewall management, and general server security.  
You are solely responsible for performing backups, updates, and all ongoing maintenance of your server and data.  

If you are not sure you can maintain a secure and stable environment, we strongly recommend using our cloud hosting options instead: [Consolidate Cloud Plans](https://www.consolidate.eu/preise)

## Hosting Options & Prerequisites

During setup, you can choose between two hosting options for exposing your Consolidate application:

### 1. Direct Exposure with Let's Encrypt

- **Description**: The application is exposed directly to the internet, and a TLS certificate is automatically generated using Let's Encrypt.
- **Prerequisites**:
   - You must have a domain name that resolves to your server (via static IP or dynamic DNS).
   - Your server must be accessible from the web on **port 80** (for certificate generation) and **port 443** (for HTTPS traffic).
   - Ensure your firewall allows inbound traffic on ports 80 and 443.
   - The server must not have another service listening on port 80 or 443.


### 2. Exposure via Reverse Proxy

- **Description**: The application is hosted behind a reverse proxy (such as Nginx, Apache, or a cloud load balancer). The proxy is responsible for generating and terminating TLS certificates, and forwards plain HTTP traffic to the application.
- **Prerequisites**:
    - You must have a domain name that resolves to your proxy server.
    - Your reverse proxy must be configured to:
       - Handle TLS certificate generation and termination (the application itself does not provide HTTPS).
       - Forward HTTP requests to the application's HTTP port (customizable during setup).
       - Set the "X-Forwarded-For" and "X-Forwarded-Proto" headers for proper client IP and protocol handling.
    - No HTTPS port is required for the application itself; all traffic between the proxy and the application is unencrypted HTTP.
    - Ensure your firewall allows inbound traffic to your proxy and traffic from the proxy to the application's HTTP port.

### System Emails
- **Mail Server**: You need an SMTP server capable of sending emails. This is required for system notifications (e.g., appointment invitations).


### Hardware
- **Operating System**: Linux. We recommend Ubuntu Server 24.04 LTS. Docker on Windows might work, but is untested.
- **Resource Requirements**: Based on our experience, you should plan for at least:
   - 1 CPU core and 2 GB RAM per 20 users.
   - Adjust resources according to your expected user count for optimal performance.

### Software
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
