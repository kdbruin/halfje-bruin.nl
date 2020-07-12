---
title: "FreeBSD - Port packages maken met Poudriere"
date: "2018-12-25"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - ""
tags:
    - ""
---

Je kunt natuurlijk gebruik maken van de port packages welke door FreeBSD beschikbaar worden gesteld maar dan mis je de mogelijkheid om aanpassingen te maken in de configuratie van deze packages. Bijvoorbeeld heb ik geen X11 windows server draaien en dan hoeft dat ook niet in de packages meegenomen te worden.

De oplossing is dus om zelf de port packages te bouwen. Dit kan direct in de ports boom op het systeem maar hier kleven een aantal nadelen aan, met name wat betreft het afhandelen van afhankelijkheden tussen de verschillende ports. Om dit op te vangen maak ik gebruik van `ports-mgmt/poudriere` om in een afgeschermde omgeving de port packages te bouwen welke dan lokaal geïnstalleerd kunnen worden.

## Poudriere configuratie

Voordat we kunnen beginnen moeten we de configuratie voor de standaard port packages aanpassen. Normaal wordt gebruik gemaakt van kwartaalupdates maar we willen dit aanpassen naar de laatste versies. Dit kan door het bestand `/usr/local/etc/pkg/repos/FreeBSD.conf` te maken met de volgende inhoud:

FreeBSD: {  
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",  
  mirror\_type: "srv",  
  signature\_type: "fingerprints",  
  fingerprints: "/usr/share/keys/pkg",  
  enabled: yes  
}

Nu dit is aangepast kunnen we `poudriere` installeren. Hierbij wordt gevraagd om ook de laatste versie van `pkg` te installeren. Daarnaast installeren we ook een port voor het afhandelen van de cache.

\# pkg install ports-mgmt/poudriere devel/ccache

Na installatie kun je een voorbeeld configuratie vinden in `/usr/local/etc/poudriere.conf.sample` met uitleg over de verschillende parameters welke ingesteld kunnen worden. Voor onze configuratie maken we het bestand `/usr/local/etc/poudriere.conf` met de volgende inhoud:

\# Poudriere configuration file  
  
ZPOOL=zbase  
ZROOTFS=/p  
FREEBSD\_HOST=ftp://ftp.nl.freebsd.org  
RESOLV\_CONF=/etc/resolv.conf  
BASEFS=/poudriere  
POUDRIERE\_DATA=${BASEFS}/data  
USE\_PORTLINT=no  
USE\_TMPFS=all  
DISTFILES\_CACHE=/poudriere/distfiles  
CHECK\_CHANGED\_OPTIONS=verbose  
CHECK\_CHANGED\_DEPS=yes  
PKG\_REPO\_SIGNING\_KEY=/usr/local/etc/pki/poudriere/poudriere.key  
CCACHE\_DIR=/var/cache/ccache  
WRKDIR\_ARCHIVE\_FORMAT=tbz  
NOLINUX=yes  
URL\_BASE=http://poudriere.home.lan/poudriere/  
ATOMIC\_PACKAGE\_REPOSITORY=yes  
COMMIT\_PACKAGES\_ON\_FAILURE=yes  
KEEP\_OLD\_PACKAGES=yes  
KEEP\_OLD\_PACKAGES\_COUNT=3  

Belangrijk in deze configuratie is dat de juiste ZFS pool naam gebruikt wordt, in mijn geval dus `zbase`. Verder configureren we alvast de URL voor de web client zodat we het bouwproces in de gaten kunnen houden.

## Jails, ports en settings

Om gebruik te kunnen maken van `poudriere` moeten we eerst een jail maken waarin de port packages gebouwd gaan worden. Dit en de vervolg stappen staan uitgebreid beschreven in het [FreeBSD Handbook](https://www.freebsd.org/doc/handbook/ports-poudriere.html).

\# poudriere jail -c -j 12amd64 -v 12.0-RELEASE  

Vervolgens moeten we de ports tree ophalen. Deze bevat de `makefile`s en patches voor alle beschikbare port packages.

\# poudriere ports -c

Het bestand `/usr/local/etc/poudriere.d/make.conf` bevat de algemene opties voor het bouwen van de ports.

\# Use the OpenSSL port version where possible  
DEFAULT\_VERSIONS+=      ssl=openssl  
  
\# Default versions for some programs  
DEFAULT\_VERSIONS+=      bdb=5  
DEFAULT\_VERSIONS+=      mysql=10.2m  
DEFAULT\_VERSIONS+=      perl5=5.26  
DEFAULT\_VERSIONS+=      python=2.7  
DEFAULT\_VERSIONS+=      python2=2.7  
DEFAULT\_VERSIONS+=      python3=3.6  
DEFAULT\_VERSIONS+=      ruby=2.4  
DEFAULT\_VERSIONS+=      apache=2.4  
DEFAULT\_VERSIONS+=      php=7.2  
  
\# Enable some features by default  
OPTIONS\_SET+=   PKGNG  
OPTIONS\_SET+=   MANPAGES  
OPTIONS\_SET+=   VP8  
OPTIONS\_SET+=   ICONV  
OPTIONS\_SET+=   GSSAPI\_MIT  
OPTIONS\_SET+=   READLINE\_PORT  
OPTIONS\_SET+=   SSP\_PORTS  
  
\# Disable some features by default  
OPTIONS\_UNSET+= X11  
OPTIONS\_UNSET+= WAYLAND  
OPTIONS\_UNSET+= CUPS  
OPTIONS\_UNSET+= LDAP  
OPTIONS\_UNSET+= TCL  
OPTIONS\_UNSET+= WXGTK  
OPTIONS\_UNSET+= OPENGL  
OPTIONS\_UNSET+= EGL  
OPTIONS\_UNSET+= NLS  
OPTIONS\_UNSET+= EXAMPLES  
OPTIONS\_UNSET+= LUA  
OPTIONS\_UNSET+= DEBUG  
OPTIONS\_UNSET+= SOUND  
OPTIONS\_UNSET+= ALSA  
OPTIONS\_UNSET+= PULSEAUDIO  
OPTIONS\_UNSET+= DOCBOOK  
OPTIONS\_UNSET+= GSSAPI\_BASE  

Als laatste maken we het bestand `/usr/local/etc/poudriere.d/12amd64.pkglist` met hierin alle port packages welke we gebouwd willen hebben.

ports-mgmt/pkg  
ports-mgmt/poudriere  
devel/ccache  
ports-mgmt/dialog4ports

Hoewel we de algemene instellingen voor de port packages hebben aangemaakt, moeten we ook de individuele port packages nog configureren.

\# poudriere options -j 12amd64 -f /usr/local/etc/poudriere.d/12amd64.pkglist

Dit zal alle gedefinieerde port packages aflopen, inclusief alle afhankelijke packages, en ons de mogelijkheid geven om de configuratie aan te passen. Deze configuratie wordt opgeslagen zodat dit niet elke keer gedaan hoeft te worden.

## Port packages bouwen en gebruiken

Nu alle configuratie is gedaan, is het tijd om de port packages te bouwen. Hierbij zal `poudriere` zelf aangeven of er nog ontbrekende directories gemaakt moeten worden.

\# poudriere bulk -j 12amd64 -f /usr/local/etc/poudriere.d/12amd64.pkglist

Als dit klaar is, dan kunnen we de gebouwde port packages gaan gebruiken op ons systeem. We moeten `pkg` dan wel vertellen waar de port packages staan. Dit doen we door het bestand `/usr/local/etc/pkg/repos/Poudriere.conf` te maken:

Poudriere: {  
  url: "file:///poudriere/data/packages/12amd64-default",  
  signature\_type: "pubkey",  
  pubkey: "/usr/local/etc/pki/poudriere/poudriere.crt",  
  priority: 100,  
  enabled: yes  
}  

Met de huidige configuratie worden ook nog port packages gebruikt van de officiële FreeBSD repository en dat willen we niet. Om dit uit te zetten veranderen we in `/usr/local/etc/pkg/repos/FreeBSD.conf` de parameter `enabled` naar `no`.

We kunnen nu de officiële port packages vervangen door de zojuist gebouwde port packages.

\# pkg update  
\# pkg upgrade -f
