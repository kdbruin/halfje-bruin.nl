---
author: "Kees de Bruin"
title: "{{ replaceRE "^\\d\\d\\d\\d-\\d\\d-\\d\\d-" "" .Name | humanize | title }}"
date: "{{ replaceRE "^(\\d\\d\\d\\d-\\d\\d-\\d\\d)-.*" "$1" .Name }}"
description: ""
series:
    - ""
categories:
    - ""
tags:
    - ""
images:
- src: ""
draft: true
---
