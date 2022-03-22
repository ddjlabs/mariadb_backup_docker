# mariadb_backup_docker

This solution is a side-card container that will perform a MySQLDump of each database assigned based on a schedule provided. The solution will send out email alerts if there are problems with the backups.


# TO DO

* Develop old backup removal function
* Create Email alert function (For errors)
* Document code
* Sanitize the code (eg remove sensitive information)
* build and package the solution for both armhf and amd64 architectures in hub.docker.com



# Change Log
* 08-25-2021 2:30PM : Coded the backup removal function. Also enabled the single database backup option via environment variables.

* 08-25-2021 11:45AM : Figured out the Alpine build issues on the Raspberry Pi. It deals with a internal bug on Alpine 3.13 forward with the libfetch library pulling files from SSL (HTTPS/TLS) connection. I updated the Dockerfile to 3.12 and tested it successfully on my Windows workstation and on the Raspberry Pi using armhf architecture.

I also created a separate docker-compose file for Atlas (mariadb_backup_atlas.yml) that I tested with Portainer. I created a volume in portainer that links to Apollo NAS to deposit the backup files. I tested the mdb_backup.sh script within the interactive shell (/bin/sh) and via my cron schedule. Both tests worked as expected.

I need to develop the old backup removal function, prepare a proper build for both armhf and amd64 architectures, and build a email alert system. I have a generic working copy working on the RPI so I have a interim backup solution in place while I finish this script.

* 08-24-2021 5:30AM : Created Docker Compose file and tested it locally. I need to get it to work with a volume and see if we can get it to work correctly on the Raspberry Pi. So far I can not get the image to work on the RPi via portainer.

* 08-24-2021 : Moved all shell scripts to the /app folder and updated the Dockerfile and scripts to use the same.