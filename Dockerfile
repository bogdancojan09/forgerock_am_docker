# The setup for the Apache Tomcat image is implemented in this Dockerfile.

# Path: Dockerfile
# Create a Dockerfile for the Apache Tomcat image.
# The Dockerfile should:
# - use the official Tomcat image with OpenJDK 11 as the base image
# - copy the war file to the webapps directory
# - expose port 8080
# - set the environment variable CATALINA_OPTS to -Xms512m -Xmx1024m -XX:MaxPermSize=256m
# - set the environment variable JAVA_OPTS to -Djava.security.egd=file:/dev/./urandom
# - set the environment variable CATALINA_HOME to /usr/local/tomcat
# - set the environment variable CATALINA_BASE to /usr/local/tomcat
# - set the environment variable CATALINA_PID to /usr/local/tomcat/temp/tomcat.pid
# - set the environment variable CATALINA_TMPDIR to /usr/local/tomcat/temp
# - start the Tomcat server using the catalina.sh script

FROM tomcat:8.5.50-jdk11-openjdk

EXPOSE 8080

ENV CATALINA_OPTS -Xms512m -Xmx1024m -XX:MaxPermSize=256m
ENV JAVA_OPTS -Djava.security.egd=file:/dev/./urandom
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_BASE /usr/local/tomcat
ENV CATALINA_PID /usr/local/tomcat/temp/tomcat.pid
ENV CATALINA_TMPDIR /usr/local/tomcat/temp

# give 644 permissions to the JDK truststore file
RUN chmod 644 /usr/local/openjdk-11/lib/security/cacerts

# copy the AM war file from the target directory to the webapps directory
COPY target/*.war /usr/local/tomcat/webapps/

# setup Amster
# In this step, we should:
# - set the working directory to the /root directory
# - add local Amster-<version>.zip file from the /target directory to the current remote working directory
# - update the apt-get repository inside the container, install unzip library without any user interaction needed, clean, unzip the Amster-<version>.zip to the current working directory
# - and remove the Amster-<version>.zip file
# Amster version is 7.4.0

WORKDIR /root
COPY target/Amster-7.4.0.zip /root/
RUN apt-get update && apt-get install -y unzip && apt-get install -y jq && apt-get clean && \
    unzip Amster-7.4.0.zip && rm Amster-7.4.0.zip

COPY scripts/entrypoint.sh /root/
COPY scripts/create_authentication_tree_script.sh /root/
RUN  chmod +x /root/entrypoint.sh
RUN  chmod +x /root/create_authentication_tree_script.sh

CMD ./entrypoint.sh