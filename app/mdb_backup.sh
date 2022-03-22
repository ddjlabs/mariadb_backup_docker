#!/bin/sh

#==============================================================================
# MariaDB Database Backup Program
# ©2021 Doug Jenkins.
# Last Update: 08-27-2021
#==============================================================================

export TODAY=`date +"%Y.%m.%d"`
export MYSQL_EXE="$(which mysql)"
export MYSQLDUMP_EXE="$(which mysqldump)"
export MYSQLADMIN_EXE="$(which mysqladmin)"
export GREP_EXE="$(which grep)"
export DB_BACKUP_PATH="/backup"

#===== common functions =====
write_log_header(){
    echo "$1" 
}

write_log_message(){
    echo "$(date) - $1"
}

throw_error(){
    echo "$(date) - [ERROR] - $1"
    exit 1
}

#===== Script-specific functions =====

check_vars(){
    write_log_message "Checking System Variables"
    write_log_message "Database Backup Instance set to $DB_INSTANCE"
    write_log_message "Host: $DB_HOST | Protocol: $DB_PROTOCOL | Port: $DB_PORT | Database User: $DB_USERNAME"
}

check_db_connection(){
    write_log_message "Checking Database connection"    

    #Check the connection by doing a ping and grepping the result. A good connection should report "mysqld is alive". anything else will throw an error.
    $MYSQLADMIN_EXE --user=$DB_USERNAME --password=$DB_PASSWORD --host=$DB_HOST --port=$DB_PORT --protocol=$DB_PROTOCOL ping | $GREP_EXE 'alive'>/dev/nul

    #Grab the exit code to see if GREP found "alive" which will equal 0.
    RET_VAL=$?

    #Check the Return value. if it is not zero, throw an error and stop processing the program.
    if [ $RET_VAL -ne 0 ]; then
        throw_error "Database Connection Failed. Check the connection details."
    else
        write_log_message "Database Connection Verified"
    fi
}

backup_db(){
    DATABASE_NAME=$1
    TARGET_DIR=${DB_BACKUP_PATH}/${DATABASE_NAME}
    TARGET_FILENAME="${DATABASE_NAME}_${TODAY}.sql.gz"
    
    #Check to see if the target directory is created. if not, create it now
    [ ! -d $TARGET_DIR ] && mkdir -p $TARGET_DIR

    write_log_message "     Database Backup Started: Database - $DATABASE_NAME"
    
    #use MySQLDump to dump the data into a SQL file and zip up the details
    $MYSQLDUMP_EXE --user=$DB_USERNAME --password=$DB_PASSWORD --host=$DB_HOST --port=$DB_PORT --protocol=$DB_PROTOCOL --databases $DATABASE_NAME | gzip > $TARGET_DIR/$TARGET_FILENAME
	RET_VAL=$?

    ## Check for errors
    if [ $RET_VAL -ne 0 ]; then
        throw_error "     Database Backup Failed. Check Above."
    else
        write_log_message "     Database Backup complete. File located at $TARGET_DIR/$TARGET_FILENAME"
    fi
}

remove_old_backups(){
    DATABASE_NAME=$1

    #Generate the remove backup date so we can publish that into the log
    REMOVE_BACKUP_DATE=`date -d "$date -$BACKUP_RETAIN_DAYS days" +"%m-%d-%Y"`

    write_log_message "     Removing Database backups older than $REMOVE_BACKUP_DATE ($BACKUP_RETAIN_DAYS days old) for Database $DATABASE_NAME"
    i_file_cnt=0

    for FILENAME in `find /$DB_BACKUP_PATH/$DATABASE_NAME/* -type f -name "*.gz" -mtime $BACKUP_RETAIN_DAYS`
    do
        write_log_message "     Removing file $FILENAME"
        rm $FILENAME
        i_file_cnt = i_file_cnt + 1
    done
  
    write_log_message "     $i_file_cnt Files removed"
}

# ===== MAIN PROGRAM =====
write_log_header "====="
check_vars
check_db_connection

#Check to see if we are backing up all the databases or just a single database instance.
if [ $DB_INSTANCE = 'ALL' ]; then
    
    write_log_message "All Database option was set. Backing up all databases found on this database server."
    
    #Get a list of all databases from the mariaDB Database Server using the string result below    
    export DB_LIST="$($MYSQL_EXE --user=$DB_USERNAME --password=$DB_PASSWORD --host=$DB_HOST --port=$DB_PORT --protocol=$DB_PROTOCOL -e "SHOW DATABASES;" | $GREP_EXE -Ev "(Database)")"
    
    write_log_message "Database list gathered. The following databases will be backed up from this host:"

    for DNAME in $DB_LIST; do
        write_log_message "     $DNAME"
    done
else
    write_log_message "Backing up $DB_INSTANCE only."
    export DB_LIST=$DB_INSTANCE
fi

#iterate through the Database List for each database and perform the backup and removal operation
write_log_message "Starting Backup Operation"

for DNAME in $DB_LIST; do
    write_log_header ""
    backup_db $DNAME
    remove_old_backups $DNAME
done
write_log_header ""

#Close up the run.
write_log_message "Backup Operations completed"
write_log_header ""
write_log_header ""