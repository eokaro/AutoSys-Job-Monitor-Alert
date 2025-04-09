
---

### File: jobs_monitor.sh

```bash
#!/bin/bash
#
# jobs_monitor.sh: Corporate Level AutoSys Job Monitor & Alert Script
#
# This script monitors the status of specified AutoSys jobs and sends an email alert if any job is not in an expected state.
#
# Usage:
#   ./jobs_monitor.sh <job_list_file>
#
# Where <job_list_file> is a text file with one AutoSys job name per line.
#

# -----------------------------------------------------------------------------
# Configuration Section
# -----------------------------------------------------------------------------

# AutoSys CLI credentials.
# In a corporate environment, consider more secure storage for credentials.
AUTO_USER="your_autosys_username"
AUTO_PASSWORD="your_autosys_password"

# List of email recipients (comma-separated)
EMAIL_RECIPIENTS="admin@example.com,ops@example.com"

# Log file to record script actions.
LOG_FILE="jobs_monitor.log"

# Expected job status values (customize based on your environment).
# For example, jobs might be expected to have statuses like RUNNING or SUCCESS.
EXPECTED_STATUSES=("RUNNING" "SUCCESS")

# -----------------------------------------------------------------------------
# Function: log_message
# Purpose: Log messages with a timestamp to both console and the log file.
# -----------------------------------------------------------------------------
log_message() {
  local message="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "${timestamp} - ${message}" | tee -a "$LOG_FILE"
}

# -----------------------------------------------------------------------------
# Function: send_email_alert
# Purpose: Send an email notification if any job is not in an expected state.
# -----------------------------------------------------------------------------
send_email_alert() {
  local subject="$1"
  local body="$2"

  # Example implementation using the 'mail' command.
  # In a corporate environment, you may need to configure an SMTP server or use a different mail service.
  echo -e "$body" | mail -s "$subject" "$EMAIL_RECIPIENTS"

  log_message "Email alert sent with subject: ${subject}"
}

# -----------------------------------------------------------------------------
# Function: check_job_status
# Purpose: Query the status of an AutoSys job using the autorep command.
# Input: AutoSys job name.
# Output: Job status (extracted from the autorep output).
# -----------------------------------------------------------------------------
check_job_status() {
  local job="$1"
  
  # Call the 'autorep' command to get job details.
  # Adjust the command as needed based on your AutoSys environment.
  # The output is assumed to contain the status in the last field.
  local output status
  output=$(autorep -J "$job" 2>/dev/null)
  status=$(echo "$output" | tail -1 | awk '{print $NF}')
  
  # Return the status.
  echo "$status"
}

# -----------------------------------------------------------------------------
# Main Script Logic
# -----------------------------------------------------------------------------

# Check that exactly one argument (job list file) is provided.
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <job_list_file>"
  exit 1
fi

JOB_LIST_FILE="$1"

# Verify the job list file exists.
if [ ! -f "$JOB_LIST_FILE" ]; then
  log_message "ERROR: Job list file '${JOB_LIST_FILE}' not found."
  exit 1
fi

log_message "Starting AutoSys Job Monitoring using job list: ${JOB_LIST_FILE}"

# Initialize variable to collect any jobs with non-expected status.
FAILED_JOBS=""

# Loop through each job in the file.
while IFS= read -r job || [ -n "$job" ]; do
  # Skip empty lines and comments.
  [[ -z "$job" || "$job" =~ ^# ]] && continue

  log_message "Checking status for job: ${job}"
  
  # Get the status of the job.
  job_status=$(check_job_status "$job")
  
  log_message "Job: ${job} has status: ${job_status}"
  
  # Check if the job's status is among the expected statuses.
  status_matched=0
  for expected in "${EXPECTED_STATUSES[@]}"; do
    if [ "$job_status" == "$expected" ]; then
      status_matched=1
      break
    fi
  done
  
  if [ "$status_matched" -ne 1 ]; then
    FAILED_JOBS="${FAILED_JOBS}\nJob: ${job} - Status: ${job_status}"
  fi

done < "$JOB_LIST_FILE"

# If any job did not match expected statuses, send an email alert.
if [ -n "$FAILED_JOBS" ]; then
  alert_subject="ALERT: AutoSys Job Failures Detected"
  alert_body="The following AutoSys jobs are not in an expected state:\n${FAILED_JOBS}"
  send_email_alert "$alert_subject" "$alert_body"
else
  log_message "All monitored jobs are in an expected state."
fi

log_message "AutoSys Job Monitoring completed."
