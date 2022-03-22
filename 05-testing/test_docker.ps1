$VER="C5"
$BUILD_DT="20210827"


#Use for Docker Compose testing
#docker-compose -f ../mariadb_backup.yml up

#Stop the test container
write-host "Stopping Backup_test Container"
docker container stop backup_test
write-host "Container stopped."

#Remove the test container
write-host "Removing backup_test container"
docker container rm backup_test
write-host "container backup_test removed."

#Remove the image
write-host "Removing docker image mariadbbackup:$VER"
docker image rm mariadbbackup:$VER
write-host "Docker image removed."

#Build the image
write-host "Building the mariadbbackup:$VER image for build date $BUILD_DT"
docker build ../. -t mariadbbackup:$VER --build-arg BUILD_DATE=$BUILD_DT --build-arg VERSION=$VER --no-cache
write-host "Image Built."

#Run the docker volume with my static environment file 
write-host "starting backup_test container on Docker Desktop on local machine."
docker container run -d --env-file atlas_backup.txt --name backup_test mariadbbackup:$VER
write-host "Container started. Testing is ready."