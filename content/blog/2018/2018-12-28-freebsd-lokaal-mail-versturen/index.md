---
title: "FreeBSD - Lokaal mail versturen"
date: "2018-12-28"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - ""
tags:
    - ""
---

Diverse processen die draaien op de server kunnen via e-mail status berichten en logs versturen. Deze blijven echter op het systeem staan zodat het lastig is om deze berichten te lezen. Door gebruik te maken van `mail/postfix` wordt het mogelijk om deze e-mails via Gmail door te sturen.

## Installatie

We starten met het bouwen van het installatie package via `poudriere` door dit aan de lijst van packages toe te voegen, de instellingen aan te passen en dan alles te bouwen. Bij de opties moet `SASL` aangezet zijn, voor de andere opties kunnen de defaults gebruikt worden.

\# echo mail/postfix >> /usr/local/etc/poudriere.d/12amd64.pkglist  
\# poudriere ports -u  
\# poudriere options -j 12amd64 -c mail/postfix  
\# poudriere bulk -j 12amd64 -f /usr/local/etc/poudriere.d/12amd64.pkglist

Als het installatie package gebouwd is kan het geïnstalleerd worden.

\# pkg install mail/postfix

Bevestig de vraag of `postfix` geactiveerd moet worden met een `y`. Dit zorgt ervoor dat we in plaats van `sendmail` nu `postfix` gaan gebruiken. Om `sendmail` helemaal uit te schakelen zijn nog een aantal acties nodig. Deze acties worden beschreven bij de installatie van het `postfix` package.

In het bestand `/etc/rc.conf` zorgen we ervoor dat `sendmail` niet meer wordt opgestart en dat we in plaats hiervan `postfix` opstarten.

\# - disable sendmail  
sendmail\_enable="NONE"  
  
\# - enable postfix  
postfix\_enable="YES"  

Voeg onderstaande regels toe aan het bestand `/etc/periodic.conf` om deze `sendmail` specifieke zaken uit te zetten.

\# disable sendmail tasks  
daily\_clean\_hoststat\_enable="NO"  
daily\_status\_mail\_rejects\_enable="NO"  
daily\_status\_include\_submit\_mailq="NO"  
daily\_submit\_queuerun="NO"  

## Gmail authenticatie

Om mail door te kunnen sturen naar Gmail is het nodig om de juiste account gegevens vast te leggen. Dit doen we in het bestand `/usr/local/etc/postfix/sasl_passwd`.

\[smtp.gmail.com\]:587    username@gmail.com:password

Vul hierbij het juiste e-mail adres en Gmail wachtwoord in. Verder moeten we ervoor zorgen dat alleen `root` het bestand kan lezen.

chmod 600 /usr/local/etc/postfix/sasl\_passwd  

## Postfix configuratie

De configuratie van `postfix` is redelijk simpel. Vervang de inhoud van `/usr/local/etc/postfix/main.cf` met de volgende regels.

\# General options  
queue\_directory = /var/spool/postfix  
command\_directory = /usr/local/sbin  
daemon\_directory = /usr/local/libexec/postfix  
data\_directory = /var/db/postfix  
mail\_owner = postfix  
unknown\_local\_recipient\_reject\_code = 550  
debug\_peer\_level = 2  
  
\# Alias maps  
alias\_maps = hash:/etc/aliases  
virtual\_alias\_maps = hash:/usr/local/etc/postfix/virtual  
  
\# Address rewriting  
recipient\_canonical\_maps = hash:/usr/local/etc/postfix/canonical  
  
\# My hostname, domain, origin, networks  
myhostname = filevault.home.lan  
mydomain = home.lan  
myorigin = home.lan  
inet\_interfaces = 172.16.123.11  
inet\_protocols = ipv4  
mynetworks = 127.0.0.0/8, 172.16.123.0/24  
  
\# SASL options  
smtp\_sasl\_auth\_enable = yes  
smtp\_sasl\_password\_maps = hash:/usr/local/etc/postfix/sasl\_passwd  
smtp\_sasl\_security\_options = noanonymous  
  
\# TLS options  
smtp\_use\_tls = yes  
smtp\_tls\_security\_level = encrypt  
tls\_random\_source = dev:/dev/urandom  
  
\# Relay host  
relayhost = \[smtp.gmail.com\]:587  
  
\# Disable compatibility mode  
compatibility\_level = 2  

Belangrijk hierbij is dat de gegevens van het lokale netwerk correct zijn zoals host naam en IP adres van de server, lokale domein naam en op welk IP netwerk de server zit. De `SASL`, `TLS` en `relayhost` configuratie zijn nodig voor het doorsturen van mail naar Gmail.

De `virtual_alias_maps` zorgt ervoor dat alle gebruikers herschreven worden naar mijn Gmail e-mail adres. Zet hiervoor de volgende regel in het `/usr/local/etc/postfix/virtual` bestand.

.\*    username@gmail.com

In het bestand `/etc/aliases` moet alleen de alias voor `root` aangepast worden.

root: username@gmail.com

Run nu het commando `newaliases` om de alias database aan te maken.

\# newaliases

Het bestand `/usr/local/etc/postfix/canonical` wordt gebruikt om de lokaal gebruikte domein namen om te zetten.

@poudriere.home.lan    username@gmail.com  
@git.home.lan          username@gmail.com  
@home.lan              username@gmail.com

De databases voor de verschillende configuratie bestanden moeten nu nog aangemaakt worden. Voor de aliases is dit al gedaan via `newaliases`, de overige moeten gemaakt worden met behulp van `postmap`.

\# postmap /usr/local/etc/postfix/sasl\_passwd  
\# postmap /usr/local/etc/postfix/canonical  
\# postmap /usr/local/etc/postfix/virtual

We kunnen nu `postfix` opstarten.

\# service postfix start

## Veiligheidniveau bij Gmail aanpassen

Normaal gesproken kunnen we geen mail via Gmail doorsturen. Hiervoor moet de instelling **Allow less secure apps** aangezet worden. Meer hierover kun je lezen op de support pagina [Allowing less secure apps to access your account](https://support.google.com/accounts/answer/6010255) van Google.

## Test e-mail versturen

Het versturen van een test e-mail is erg eenvoudig.

\# echo "Test" | mail -s "Test" test@domain.com

In de verzonden items bij Gmail moet je nu dit bericht zien. Onafhankelijk vanaf welk gebruikersaccount dit is verstuurd, de afzender moet gelijk zijn aan het e-mail adres zoals ingevuld in `/usr/local/etc/postfix/virtual`.

## Referenties

- [Configure Postfix to use Gmail as a Mail Relay](https://www.howtoforge.com/tutorial/configure-postfix-to-use-gmail-as-a-mail-relay/)
- [Configuring Postfix on FreeBSD to relay mail through Gmail](http://dnaeon.github.io/configuring-postfix-on-freebsd-to-relay-mail-through-gmail/)
