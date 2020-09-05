---
title: "FreeBSD - DNS en DHCP"
date: "2018-12-25 13:00:00"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - "sysadmin"
tags:
    - "freebsd"
    - "networking"
    - "dns"
    - "dhcp"
---

Hoewel de Fritz!Box redelijk te configureren valt met betrekking tot DNS en DHCP, is het toch lastig om hostnamen te koppelen aan bijvoorbeeld een MAC adres en hier dan een vast IP adres aan toe te kennen. Door gebruik te maken van `dns/dnsmasq` is het mogelijk om zowel de DNS alsook de DHCP functionaliteit beschikbaar te maken.

## Installatie

We voegen `dns/dnsmasq` toe aan de lijst van port packages welke gebouwd moeten worden met `poudriere` en configureren het port package. Hierbij gebruiken we alle defaults.

```shell
# poudriere options -j 12amd64 dns/dnsmasq
```

Na het bouwen kunnen we het port package installeren.

```shell
# pkg update && pkg install dns/dnsmasq
```

## Configuratie

De configuratie staat in het bestand `/usr/local/etc/dnsmasq.conf` en bevat al een voorbeeld configuratie. Deze verwijderen we en beginnen vanaf scratch.

Als eerste stellen we ons eigen domein in en forceren dat dit altijd gebruikt wordt. Ook zorgen we ervoor dat niet-publieke IP adressen niet doorgestuurd worden naar de upstream DNS servers.

```cfg
# Hosts zonder domein worden niet doorgestuurd  
domain-needed  
  
# Niet-routeerbare IP adressen worden genegeerd  
bogus-priv  
  
# Forceer eigen domein wanneer het niet wordt gebruikt  
domain=home.lan  
expand-hosts  
local=/home.lan/  
```

Vervolgens stellen we de IP adressen in waarop `dnsmasq` moet luisteren naar requests.

```cfg
# Luister naar requests op IP adres 127.0.0.1 (localhost) en 172.16.123.11 (server IP)  
listen-address=127.0.0.1  
listen-address=172.16.123.11  

# Luister op alle interfaces  
bind-interfaces  
```

Als laatste vertellen we `dnsmasq` welke upstream DNS servers gebruikt moeten worden.

```cfg
# Upstream DNS - Google en OpenDNS  
strict-order  
server=8.8.8.8  
server=208.67.220.220  
server=8.8.4.4  
server=208.67.222.222  
```

Tot zover de DNS configuratie en kunnen we verder met de DHCP configuratie. Hiervoor stellen we IP adresbereik in van waaruit de IP adressen uitgedeeld worden. Verder definiëren we ook de opties voor de DHCP client zoals DNS server en router.

```cfg
# DHCP  
dhcp-range=172.16.123.100,172.16.123.200,255.255.255.0,24h  
dhcp-option=option:router,172.16.123.1  
dhcp-option=option:dns-server,172.16.123.11  
  
# Bewaar DHCP leases  
dhcp-leasefile=/var/db/dnsmasq/dnsmasq.leases  
```

Normaal gesproken kun je er als DHCP client niet van uit gaan dat je altijd hetzelfde IP adres krijgt toegewezen. Op basis van het MAC adres kunnen we dit echter wel forceren door voor elk MAC adres een `dhcp-host` regel toe te voegen.

```cfg
dhcp-host=xx:xx:xx:xx:xx:xx,<ip-adres>  
```

Voor alle belangrijke systemen, zoals de Fritz!Box, de WiFi versterkers en de computers, heb ik een regel toegevoegd zodat ze altijd hetzelfde IP adres krijgen toegewezen. Voor mobiele telefoons en de tablets heb ik dit niet gedaan.

Tot slot hebben we nog de mogelijkheid om aan een IP adres een host naam te koppelen. Dit kan dus alleen voor systemen welke een vast IP adres hebben. We maken een bestand `/usr/local/etc/hosts` waarin we deze koppeling vastleggen.

```cfg
# Localhost  
127.0.0.1     localhost  
  
# Overige hosts  
<ip-adres>    <host naam> <host alias>
```

In de `dnsmasq` configuratie voegen we de volgende regel toe om de koppeling daadwerkelijk te gebruiken.

```cfg
# Hosts file  
addn-hosts=/usr/local/etc/hosts
```

We kunnen de configuratie testen met het commando:

```shell
# dnsmasq --test
```

## Service starten

Omdat het niet gewenst is om meerdere DHCP servers op 1 netwerk te hebben, moeten we eerst de DHCP server in de Fritz!Box uitzetten. Let op dat alleen de IPv4 DHCP server wordt uitgezet.

Om gebruik te maken van onze eigen DNS service moet het bestand `/etc/resolv.conf` aangepast worden.

```cfg
# Search local domain  
search local  
nameserver 172.16.123.11  
```

Vervolgens kunnen we de `dnsmasq` service opstarten.

```shell
# service dnsmasq onestart
```

Hernieuw de DHCP leases op de verschillende computers of verbreek eventjes de WiFi verbinding van mobiele apparaten om te controleren dat een nieuw IP adres wordt toegekend. Bezoek ook een aantal websites om te zien dat externe hosts nog benaderbaar zijn en gebruik tools als `dig` of `nslookup` om te zien of zowel het juiste IP adres wordt gevonden voor een host naam en ook onze eigen DNS server wordt gebruikt.

Als alles correct functioneert voegen we nog een regel toe aan `/etc/rc.conf` zodat de service automatisch wordt opgestart bij het starten van de server. Ook definiëren we de naam van het configuratiebestand.

```cfg
# - DNS cache and DHCP server  
dnsmasq_enable="YES"  
dnsmasq_conf="/usr/local/etc/dnsmasq.conf"
```

## Referenties

- [Configuring dnsmasq in a BSD Jail on FreeNAS 11](https://east.fm/posts/dnsmasq-FreeNAS/index.html#)
- [DHCP/DNS Server on FreeNAS](https://hendroff.wordpress.com/2018/05/06/dhcp-dns-server-on-freenas/)
