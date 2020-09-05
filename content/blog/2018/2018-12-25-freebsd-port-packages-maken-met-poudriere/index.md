---
title: "FreeBSD - Port packages maken met Poudriere"
date: "2018-12-25 12:00:00"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - "sysadmin"
tags:
    - "freebsd"
    - "package management"
    - "poudriere"
---

Je kunt natuurlijk gebruik maken van de port packages welke door FreeBSD beschikbaar worden gesteld maar dan mis je de mogelijkheid om aanpassingen te maken in de configuratie van deze packages. Bijvoorbeeld heb ik geen X11 windows server draaien en dan hoeft dat ook niet in de packages meegenomen te worden.

De oplossing is dus om zelf de port packages te bouwen. Dit kan direct in de ports boom op het systeem maar hier kleven een aantal nadelen aan, met name wat betreft het afhandelen van afhankelijkheden tussen de verschillende ports. Om dit op te vangen maak ik gebruik van `ports-mgmt/poudriere` om in een afgeschermde omgeving de port packages te bouwen welke dan lokaal geïnstalleerd kunnen worden.

## Poudriere configuratie

Voordat we kunnen beginnen moeten we de configuratie voor de standaard port packages aanpassen. Normaal wordt gebruik gemaakt van kwartaalupdates maar we willen dit aanpassen naar de laatste versies. Dit kan door het bestand `/usr/local/etc/pkg/repos/FreeBSD.conf` te maken met de volgende inhoud:

```cfg
FreeBSD: {  
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",  
  mirror_type: "srv",  
  signature_type: "fingerprints",  
  fingerprints: "/usr/share/keys/pkg",  
  enabled: yes  
}
```

Nu dit is aangepast kunnen we `poudriere` installeren. Hierbij wordt gevraagd om ook de laatste versie van `pkg` te installeren. Daarnaast installeren we ook een port voor het afhandelen van de cache.

```shell
# pkg install ports-mgmt/poudriere devel/ccache
```

Na installatie kun je een voorbeeld configuratie vinden in `/usr/local/etc/poudriere.conf.sample` met uitleg over de verschillende parameters welke ingesteld kunnen worden. Voor onze configuratie maken we het bestand `/usr/local/etc/poudriere.conf` met de volgende inhoud:

```cfg
# Poudriere configuration file  
  
ZPOOL=zbase  
ZROOTFS=/p  
FREEBSD_HOST=ftp://ftp.nl.freebsd.org  
RESOLV_CONF=/etc/resolv.conf  
BASEFS=/poudriere  
POUDRIERE_DATA=${BASEFS}/data  
USE_PORTLINT=no  
USE_TMPFS=all  
DISTFILES_CACHE=/poudriere/distfiles  
CHECK_CHANGED_OPTIONS=verbose  
CHECK_CHANGED_DEPS=yes  
PKG_REPO_SIGNING_KEY=/usr/local/etc/pki/poudriere/poudriere.key  
CCACHE_DIR=/var/cache/ccache  
WRKDIR_ARCHIVE_FORMAT=tbz  
NOLINUX=yes  
URL_BASE=http://poudriere.home.lan/poudriere/  
ATOMIC_PACKAGE_REPOSITORY=yes  
COMMIT_PACKAGES_ON_FAILURE=yes  
KEEP_OLD_PACKAGES=yes  
KEEP_OLD_PACKAGES_COUNT=3  
```

Belangrijk in deze configuratie is dat de juiste ZFS pool naam gebruikt wordt, in mijn geval dus `zbase`. Verder configureren we alvast de URL voor de web client zodat we het bouwproces in de gaten kunnen houden.

## Jails, ports en settings

Om gebruik te kunnen maken van `poudriere` moeten we eerst een jail maken waarin de port packages gebouwd gaan worden. Dit en de vervolg stappen staan uitgebreid beschreven in het [FreeBSD Handbook](https://www.freebsd.org/doc/handbook/ports-poudriere.html).

```shell
# poudriere jail -c -j 12amd64 -v 12.0-RELEASE  
```

Vervolgens moeten we de ports tree ophalen. Deze bevat de `makefile`s en patches voor alle beschikbare port packages.

```shell
# poudriere ports -c
```

Het bestand `/usr/local/etc/poudriere.d/make.conf` bevat de algemene opties voor het bouwen van de ports.

```cfg
# Use the OpenSSL port version where possible  
DEFAULT_VERSIONS+=      ssl=openssl  
  
# Default versions for some programs  
DEFAULT_VERSIONS+=      bdb=5  
DEFAULT_VERSIONS+=      mysql=10.2m  
DEFAULT_VERSIONS+=      perl5=5.26  
DEFAULT_VERSIONS+=      python=2.7  
DEFAULT_VERSIONS+=      python2=2.7  
DEFAULT_VERSIONS+=      python3=3.6  
DEFAULT_VERSIONS+=      ruby=2.4  
DEFAULT_VERSIONS+=      apache=2.4  
DEFAULT_VERSIONS+=      php=7.2  
  
# Enable some features by default  
OPTIONS_SET+=   PKGNG  
OPTIONS_SET+=   MANPAGES  
OPTIONS_SET+=   VP8  
OPTIONS_SET+=   ICONV  
OPTIONS_SET+=   GSSAPI_MIT  
OPTIONS_SET+=   READLINE_PORT  
OPTIONS_SET+=   SSP_PORTS  
  
# Disable some features by default  
OPTIONS_UNSET+= X11  
OPTIONS_UNSET+= WAYLAND  
OPTIONS_UNSET+= CUPS  
OPTIONS_UNSET+= LDAP  
OPTIONS_UNSET+= TCL  
OPTIONS_UNSET+= WXGTK  
OPTIONS_UNSET+= OPENGL  
OPTIONS_UNSET+= EGL  
OPTIONS_UNSET+= NLS  
OPTIONS_UNSET+= EXAMPLES  
OPTIONS_UNSET+= LUA  
OPTIONS_UNSET+= DEBUG  
OPTIONS_UNSET+= SOUND  
OPTIONS_UNSET+= ALSA  
OPTIONS_UNSET+= PULSEAUDIO  
OPTIONS_UNSET+= DOCBOOK  
OPTIONS_UNSET+= GSSAPI_BASE  
```

Als laatste maken we het bestand `/usr/local/etc/poudriere.d/12amd64.pkglist` met hierin alle port packages welke we gebouwd willen hebben.

```cfg
ports-mgmt/pkg  
ports-mgmt/poudriere  
devel/ccache  
ports-mgmt/dialog4ports
```

Hoewel we de algemene instellingen voor de port packages hebben aangemaakt, moeten we ook de individuele port packages nog configureren.

```shell
# poudriere options -j 12amd64 -f /usr/local/etc/poudriere.d/12amd64.pkglist
```

Dit zal alle gedefinieerde port packages aflopen, inclusief alle afhankelijke packages, en ons de mogelijkheid geven om de configuratie aan te passen. Deze configuratie wordt opgeslagen zodat dit niet elke keer gedaan hoeft te worden.

## Port packages bouwen en gebruiken

Nu alle configuratie is gedaan, is het tijd om de port packages te bouwen. Hierbij zal `poudriere` zelf aangeven of er nog ontbrekende directories gemaakt moeten worden.

```shell
# poudriere bulk -j 12amd64 -f /usr/local/etc/poudriere.d/12amd64.pkglist
```

Als dit klaar is, dan kunnen we de gebouwde port packages gaan gebruiken op ons systeem. We moeten `pkg` dan wel vertellen waar de port packages staan. Dit doen we door het bestand `/usr/local/etc/pkg/repos/Poudriere.conf` te maken:

```cfg
Poudriere: {  
  url: "file:///poudriere/data/packages/12amd64-default",  
  signature_type: "pubkey",  
  pubkey: "/usr/local/etc/pki/poudriere/poudriere.crt",  
  priority: 100,  
  enabled: yes  
}  
```

Met de huidige configuratie worden ook nog port packages gebruikt van de officiële FreeBSD repository en dat willen we niet. Om dit uit te zetten veranderen we in `/usr/local/etc/pkg/repos/FreeBSD.conf` de parameter `enabled` naar `no`.

We kunnen nu de officiële port packages vervangen door de zojuist gebouwde port packages.

```shell
# pkg update  
# pkg upgrade -f
```