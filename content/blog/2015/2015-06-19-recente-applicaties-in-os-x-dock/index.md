---
title: "Recente applicaties in OS X Dock"
date: "2015-06-19"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - ""
tags:
    - ""
---

Wanneer je een overzicht wilt van de meest recent gebruikte applicaties in je OS X Dock is dat eenvoudig te regelen via een aantal commando's. Deze kunnen via Terminal uitgevoerd worden:

defaults write com.apple.dock persistent-others -array-add '{"tile-data" = {"list-type" = 1;}; "tile-type" = "recents-tile";}'
killall Dock

Het eerste commando voegt een folder met de recente applicaties toe aan het Dock.  
Bron: [How to add recently used apps, docs, and more to your Mac’s Dock](http://www.imore.com/how-add-recently-used-apps-docs-and-more-your-macs-dock)
