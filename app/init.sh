#!/bin/sh
 
################################################################
##
##   MariaDB Database Backup Script : Initial Setup 
##   Last Update: July 27th, 2021
##
################################################################

#Constants
export C_MSMTPRC_FILE=/etc/msmtprc
export C_MAIL_ALIASES=/etc/aliases
export C_CRON_SCHD=/app/custom.cron


#Common Functions for all bash scripting
write_log_header(){
    echo "$1" 
}

write_log_message(){
    echo "$(date) - $1"
}

# ===== Specific Functions for this bash script =====
create_msmtprc_file(){
    write_log_message "Creating MailConfig File for MSTPRC at $C_MSMTPRC_FILE"

    echo "defaults" > $C_MSMTPRC_FILE
    echo "auth   $MAIL_AUTH" >> $C_MSMTPRC_FILE
    echo "tls    $MAIL_TLS" >> $C_MSMTPRC_FILE
    echo "tls_trust_file  /etc/ssl/certs/ca-certificates.crt" >> $C_MSMTPRC_FILE
    echo "syslog  on" >> $C_MSMTPRC_FILE
    echo >> $C_MSMTPRC_FILE
    echo "account opsmail" >> $C_MSMTPRC_FILE
    echo "host   $MAIL_HOST" >> $C_MSMTPRC_FILE
    echo "port   $MAIL_PORT" >> $C_MSMTPRC_FILE
    echo "from   $MAIL_FROM" >> $C_MSMTPRC_FILE
    echo "user   $MAIL_USER" >> $C_MSMTPRC_FILE
    echo "password   $MAIL_USER_PASSWORD" >> $C_MSMTPRC_FILE
    echo >> $C_MSMTPRC_FILE
    echo "account default:   opsmail" >> $C_MSMTPRC_FILE
    echo "aliases /etc/aliases" >> $C_MSMTPRC_FILE

    write_log_message "File Created"
}

create_alias_file(){

    write_log_message "Creating aliases file at $C_MAIL_ALIASES"
    
    echo "root: $MAIL_TO" > $C_MAIL_ALIASES
    echo "default: $MAIL_TO" >> $C_MAIL_ALIASES

    write_log_message "File Created"
}

generate_cron_schedule(){
    write_log_message "Generating Cron entries using the file $C_CRON_SCHD"
    write_log_message "Backup Schedule is $DB_BACKUP_SCHEDULE"
    write_log_message "Backup Instance set to $DB_INSTANCE"

    echo "$DB_BACKUP_SCHEDULE   /app/mdb_backup.sh" > $C_CRON_SCHD

    #Now post this change to cron and remove the cron.custom file
    crontab $C_CRON_SCHD
    rm $C_CRON_SCHD

    write_log_message "Cron Schedule Generated"
}

# ===== MAIN_PROGRAM =====
write_log_header ""
write_log_header "MariaDB Backup Docker Side Car."
write_log_header "======================================================================"

create_msmtprc_file
create_alias_file
generate_cron_schedule

write_log_header ""
write_log_header "Starting CRON Schedule Engine. All Logs will be from scheduled backups"
write_log_header "======================================================================"

#Start crond daemon in foreground mode. this will log all events into the Docker logs.
crond -f