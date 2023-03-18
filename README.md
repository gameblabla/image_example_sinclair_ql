Image example for Sinclair QL in C
==================================

Displays a screen mode 8 image on the Sinclair QL with 
various algos that can be turned on and off :
- Aplib
- ZX0
- nrv2s

They are all pretty slow unfortunately...
Something like ZX1/Mega variant would greatly help.

# Compressing the image/anything

For Aplib, compress with apultra.
```
apultra MYSCR.SCR8 IMGAP
```

For ZX0, make sure not to use classic mode or it will fail.
```
zx0 MYSCR.SCR8 IMGZX0
```

nrv2s doesn't have an open source encoder but the proprietary one that
uses UPX is on that repo.
```
nrv2x -e MYSCR.SCR8 IMGNV
```

# Compiling

Make sure you have QDOS-GCC available as well as as68 (assembler),
there's a docker available (qdos-devel) that you can use to compile your programs 
but if you do use docker, you'll have to manually change run.sh or
extract the files from the docker and install them to your Linux machine.
