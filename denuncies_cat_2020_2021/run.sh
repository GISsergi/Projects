#!/bin/bash
#Data: 21/05/2022

# Executem script a.sh.
./a.sh -v &

wait

# Executem script b.sh.
./b.sh denuncies.csv &

wait

# Executem script b.awk.
gawk -f b.awk denuncies1.csv &

wait

# Executem script b1.sh.
./b1.sh denuncies1.csv &

wait

# Executem script c.sh.
./c.sh denuncies_20.csv 
