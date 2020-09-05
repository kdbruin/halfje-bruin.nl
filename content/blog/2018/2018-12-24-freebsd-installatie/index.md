---
title: "FreeBSD - Installatie"
date: "2018-12-24 13:00:00"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - "sysadmin"
tags:
    - "freebsd"
---

De installatie van een nieuw FreeBSD systeem is erg eenvoudig en staat duidelijk beschreven in het [FreeBSD handboek](https://www.freebsd.org/doc/handbook/). In het kort komt het erop neer dat je een specifiek image op een USB stick zet, de betreffende machine opstart en dan voor installatie kiest.

## Voorbereidingen

Voor de installatie gebruik ik de memstick image (`FreeBSD-12.0-RELEASE-amd64-memstick.img`) welke ik met het oude systeem op een USB stick zet om straks mee op te kunnen starten.

Verder is het nog een kwestie van de machine open schroeven en de nieuwe SSD monteren. Er is nog een plekje vrij in de herberg en na het aansluiten van de voedings- en SATA kabels kan de kast weer dicht.

## Installatie

Na het opstarten van het systeem kom ik nog steeds in de huidige installatie terecht dus even in de BIOS aanzetten dat er ook vanaf een USB stick opgestart mag worden en daarna kan de installatie beginnen.

Het is een vrij recht toe recht aan proces en bij de indeling van de SSD kies ik voor `ZFS on Root` met een swap partitie van 32GB (dubbele van het interne geheugen) en de rest voor de root. Het voordeel van deze methode is dat er gebruik gemaakt wordt van een zogenaamd boot environment wat het upgraden van het systeem later wat gemakkelijker maakt.

Na het afronden van de installatie is het tijd het systeem opnieuw op te starten en wederom kom ik in het oude systeem terecht. Nogmaals de BIOS in om de volgorde van de verschillende systeem disks aan te passen zodat het nieuwe systeem als eerste wordt gekozen.

Nogmaals opstarten en het nieuwe systeem is klaar voor gebruik. Nu alleen nog even de software opnieuw installeren.
