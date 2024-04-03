# ForgeRock Access Manager (AM) - Docker Setup

## About

This is a "dockerized" version of a Java (OpenJDK) 11, Apache Tomcat 8.5 and ForgeRock AM 7.3.1 (with Amster 7.4).

Its main purpose is to serve as a faster way to set up Access Manager tool of ForgeRock, to avoid manual steps such as local installments of Java or Apache Tomcat.

For now, this setup is meant to be used for testing and local environments; will take into consideration also upgrading it for production use.

## The Why

Once, I had to add ForgeRock AM support for an application I worked on in recent years. At that time, I never heard of this IDP, and given the limited time I had to make it available,
it felt like most of the time had been wasted on trying to locally configure ForgeRock AM client components: OpenJDK, Apache Tomcat etc.

After pitching up Docker, I realized I can automate these steps so that I take away these burdens if needed for future opportunities.

## The What

This repo contains a list of files as follows:

- Dockerfile: Docker image configuration
- docker-compose.yml: Docker container configuration (added to include the port forwarding and extra hosts)
- /scripts:
  
    -> create_authentication_tree_script.sh: Bash script that sets up an authentication tree within the installed AM client

    -> entrypoint.sh: Bash script that starts Apache Tomcat service and adds the AM default configuration

## The How

  1. Before booting up the setup, make sure you have installed the WAR file for AM (ideally v7.3.1) - and rename it - and the zipped version of Amster (v7.4.0) on your local setup. Once installed, add them into the /target directory.

  **(! You might need to create a ForgeRock account before installing the products mentioned above, even though these do not need any subscription or pay-to-use features.)**

  2. Make sure you create your own .env file containing the variables that are listed inside the .env.sample with values you want to add.

  3. Development was done using a WSL + Docker Engine setup. Assuming you have WSL set up with Docker Engine within, you can just build this using this command (--progress plain flag-value pair can be used for build status tracking):

      docker-compose build [--progress plain] && docker-compose up -d

## Current "Magic"

1. ForgeRock AM is deployed into Apache Tomcat;
2. Using Amster, AM is installed with default configuration (serverURL and amAdmin's password);
3. Using Amster, user session cookie name has been changed to "myNewCookie";
4. Using create_authentication_tree_script.sh, the myAuthenticationTree authentication tree and its nodes are created within the AM client. This is created to be used after integrating with your application so that users can login.

## Future "Magic"

(not in order, might suffer changes)

~~1. Change Session Cookie name from iPlanetDirectoryPro (default name)~~ **Done, check [#1](https://github.com/bogdancojan09/forgerock_am_docker/pull/1)**

2. Set up OAuth2 client
3. Set up new Realm, different from the root/default one
   
~~4. Dynamically set up everything (env vars maybe?)~~ **Done, check a version in [#2](https://github.com/bogdancojan09/forgerock_am_docker/pull/2)**

~~5. Restructure scripts runs when restarting the container locally~~ **Done, check [#3](https://github.com/bogdancojan09/forgerock_am_docker/pull/3)**
