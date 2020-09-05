---
title: "FreeBSD - File sharing via NFS"
date: "2018-12-27"
author: "Kees de Bruin"
description: ""
featured: ""
categories:
    - "sysadmin"
tags:
    - "freebsd"
    - "file sharing"
    - "nfs"
---

Om gemakkelijk bij de bestanden op de server te komen is het nodig om de betreffende datasets beschikbaar te maken via het netwerk. Dit kan via bijvoorbeeld AFP of Samba maar aangezien het netwerk hier een Unix netwerk betreft, is de keuze voor NFS snel gemaakt.

Wat betreft de configuratie moeten we eerst aangeven wat er precies beschikbaar gesteld moet worden. Dit doen we in het `/etc/exports` bestand.

```cfg
V4: /  
/usr/home/kdb -network 172.16.123.0 -mask 255.255.255.0 -mapall=kdb:kdb  
/storage/media -network 172.16.123.0 -mask 255.255.255.0 -mapall=media:media  
```

De eerste regel forceert het gebruik van NFS v4 in plaats van v3 wat een aantal voordelen biedt zoals betere beveiliging en hogere snelheid. De 2 volgende regels beschrijven de datasets welke beschikbaar zijn en welke Unix gebruiker en groep gebruikt moet worden.

Voor het starten van de NFS server moeten de volgende regels toegevoegd worden aan `/etc/rc.conf`.

```cfg
# enable NFS server  
nfs_server_enable="YES"  
# use both UDP and TCP, 6 threads  
nfs_server_flags="-u -t -n 6"  
# enable NFS v4, including user/group info  
nfsv4_server_enable="YES"  
nfsuserd_enable="YES"  
# enable RPC binding  
rpcbind_enable="YES"  
# allow RPC mount requests for normal files  
mountd_flags="-r"  
```

Als laatste moeten we nog de NFS service starten.

```shell
# service start nfsd
```

## Referenties

- [FreeBSD Handbook](https://www.freebsd.org/doc/handbook/network-nfs.html)
