TODO: Update this.

# ForgeRock Access Manager (AM) - Docker Setup

This is a "dockerized" version of a Java (OpenJDK) 11, Apache Tomcat 8.5 and ForgeRock AM 7.3.1 (with Amster 7.4).
Its main purpose is to serve as a faster way to set up Access Manager tool of ForgeRock, to avoid burdens such as local installments of Java or Apache Tomcat.

Development was done using a WSL + Docker Engine setup. Assuming you have WSL set up with Docker Engine within, you can just build this using this command:

    docker-compose build [--progress plain] && docker-compose up -d