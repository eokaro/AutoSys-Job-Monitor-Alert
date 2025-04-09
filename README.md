#AutoSys Job Monitor & Alert

This repository contains a corporate‐grade Bash script that monitors AutoSys job statuses and sends email alerts when a job is not in an expected state. 

This project demonstrates the following key capabilities:
- **Job Monitoring:** Uses the AutoSys CLI (e.g., with `autorep`) to query job statuses.
- **Robust Logging:** Each operation is timestamped for traceability.
- **Automated Alerting:** Sends email notifications to designated recipients if a job fails or is not in an approved state.
- **Corporate-Ready Structure:** The script is modular, clearly configured, and designed for integration into enterprise-level scheduling and monitoring systems.

## Key Components

- **Configuration Section:**  
  Easily update variables like AutoSys credentials, recipient email addresses, and log file location.
  
- **Logging Function (`log_message`):**  
  Captures and writes log entries with timestamps. This aids in corporate troubleshooting and auditing.

- **Job Status Checker Function (`check_job_status`):**  
  Queries the status of a specific AutoSys job using the `autorep` command and extracts the status.

- **Alerting Function (`send_email_alert`):**  
  Sends an email notification with job status details if any job is not running properly.

- **Main Loop:**  
  Reads a list of AutoSys job names from an input file, checks their status, logs each result, and triggers alerts if necessary.

## Setup & Usage

1. **Clone this Repository:**

   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
