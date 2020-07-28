---
author: "Kees de Bruin"
title: "Symbolische link naar Documents folder"
date: "2020-05-23"
description: ""
categories:
    - "sysadmin"
tags:
    - "macos"
---

Om ruimte te besparen op de systeem SSD heb ik in m'n iMac een extra SSD geïnstalleerd waarop ik m'n data bewaar. Omdat ik niet m'n home folder wil verplaatsen naar de data SSD gebruik ik symbolische links naar de verschillende belangrijke folders zoals Documents, Downloads, Movies, Music en Pictures welke nu op de data SSD staan.

Echter, bij een herstart van macOS wordt de symbolische link naar de Documents (en ook de Desktop) folder weer verwijderd en dat levert de nodige problemen op met bijvoorbeeld syncthing. Na wat zoeken blijkt het vrij eenvoudig te zijn om dit te ondervangen.

Als eerste moet de link gelegd worden (let op dat de Documents folder leeg is!):

    sudo rm -rf ~/Documents
    ln -sf /Volumes/DataSSD/Documents ~/Documents

Om ervoor te zorgen dat de symbolische link niet wordt verwijderd, open dan de hoe folder in Finder en selecteer de Documents folder. Kies vervolgens Get Info in het context menu. Zorg ervoor dat Locked is geselecteerd zoals te zien in onderstaande afbeelding.

{{< img src="img/Screenshot-2020-05-23-at-09.07.00.png" >}}
