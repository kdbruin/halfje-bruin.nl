---
title: "FreeBSD - Een eigen webserver"
date: "2019-01-27"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - ""
tags:
    - ""
---

Een website is een goede manier om informatie beschikbaar te maken voor anderen, maar ook om informatie voor jezelf te archiveren. Nu doe ik dat al door op m'n eigen website deze artikelen te plaatsen, maar een lokale webserver kan ook gebruikt worden om bijvoorbeeld de resultaten van `poudriere` te bekijken, een lokale cloud te draaien met behulp van `nextcloud`, of een web interface aan te bieden voor de `git` repositories.

## Apache of Nginx

Voor het draaien van een website zijn er een aantal mogelijkheden maar met name `apache` en `nginx` worden hier veelvuldig voor gebruikt. Elk heeft zo zijn voor- en nadelen maar zelf heb ik gekozen voor `apache` aangezien ik daar wat meer ervaring mee heb dan met `nginx`.

## Installatie

Installatie van `apache` is vrij eenvoudig. Het begint met het bouwen van de juiste package en dan is het een kwestie van installeren. Bij de opties moeten de volgende features aangezet zijn: `SSL`, `MPM_SHARED`. Voor de overige opties zijn de defaults voldoende.

\# echo www/apache24 >> /usr/local/etc/poudriere.d/12amd64.pkglist  
\# poudriere ports -u  
\# poudriere options -c www/apache24  
\# poudriere bulk -j 12amd64 -f /usr/local/etc/poudriere.d/12amd64.pkglist

Na het bouwen kan het package geïnstalleerd worden.

\# pkg install www/apache24

## Configuratie

Met het commando

\# service apache24 onestart

kunnen we controleren of de software correct is geïnstalleerd. Open een browser en ga naar `http://filevault.home.lan/` en dan moet de volgende tekst getoond worden.

It works!

We stoppen de `apache` server met `service apache24 onestop` en gaan verder met het installeren van onder andere PHP. Maar eerst voeren we nog even onderstaand commando uit om bij een herstart `apache` automatisch op te starten.

\# sysrc apache24\_enable="YES"

## Installatie van PHP

`PHP` is een veelgebruikte scripttaal voor het schrijven van interactive webpagina's. In dit geval installeren we een van de laatste versie van `PHP`, namelijk 7.2. Er is al wel een nieuwere versie maar deze wordt nog niet veel ondersteund door de diverse `PHP` applicaties.

Als eerste moeten we een aantal PHP packages toevoegen aan ons build systeem en deze bouwen. Tevens voegen we gelijk de `apache` module voor ondersteuning van `PHP` toe.

\# echo lang/php72 >> /usr/local/etc/poudriere.d/12amd64.pkglist  
\# echo lang/php72-extensions >> /usr/local/etc/poudriere.d/12amd64.pkglist  
\# echo www/mod\_php72 >> /usr/local/etc/poudriere.d/12amd64.pkglist  
\# poudriere options -c lang/php72 lang/php72-extensions www/mod\_php72  
\# poudriere bulk -j 12amd64 -f /usr/local/etc/poudriere.d/12amd64.pkglist

Na het bouwen van de packages kunnen we deze vervolgens installeren.

\# pkg update && pkg install php72 mod\_php72

Daarnaast moeten we ook nog een aantal van de `PHP` extensies installeren.

\# pkg install php72-mbstring php72-zlib php72-curl php72-gd php72-json

Voor het gebruik van `PHP` binnen `apache` moet we de geïnstalleerde module toevoegen aan de `apache` configuratie. Voeg aan het bestand `/usr/local/etc/apache24/httpd.conf` de volgende regel toe:

LoadModule php7\_module        libexec/apache24/libphp7.so

Tevens moeten we ervoor zorgen dat `.php` bestanden als zodanig worden behandeld. Hiervoor creëren we het bestand `/usr/local/etc/apache24/modules.d/080_mod_php.conf` met de volgende inhoud:

<FilesMatch "\\.php$">  
    SetHandler application/x-httpd-php  
</FilesMatch>  
  
<FilesMatch "\\.phps$">  
    SetHandler application/x-httpd-php-source  
</FilesMatch>  

Om een en ander te testen voeren we de volgende commando's uit om `apache` opnieuw te starten en maken we een simpele testpagina.

\# echo '<?php phpinfo(); ?>' | tee -a /usr/local/www/apache24/data/info.php  
\# service apache24 restart  

Als we nu naar `http://filevault.home.lan/info.php` gaan, dan moet nu de status pagina voor de `PHP` ondersteuning binnen apache getoond worden.

In een volgend artikel ga ik verder met het toevoegen van SSL ondersteuning.
