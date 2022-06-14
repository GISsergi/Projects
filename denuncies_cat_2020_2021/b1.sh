#!/bin/bash
#Data: 21/05/2022
#Objectius de l'script: Reduïr el nombre de caracters de la columna r_policial. A més a més de filtrar en dos csv separats les dades que corresponen al 2020, i al 2021.
#Nom i tipus dels camps manipulats: r_policial(caràcter) any (sencer)

echo -e "Inici de l'execució de l'Script b1.sh"
echo -e "-------------------------------------------------------------------\n"

if [ -e denuncies_20.csv ]; 
	then
	  gio trash denuncies_20.csv
	  gio trash denuncies_21.csv
	  gio trash denuncies2.csv
fi

# Guardem el nom del csv denuncies4.csv a file.
file="denuncies2.csv"
# Iterem pel csv per reduir el nom de les regions policials. Ho fem amb while.
{
read
while IFS=, read any nom_mes numero_mes data r_policial sexe edat nombre rang_edat
do
# Obrim condicions per filtrar per regions policials.
 if [ "$r_policial" = "RP METROPOLITANA SUD" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPMS,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP METROPOLITANA NORD" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPMN,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP CENTRAL" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPC,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP CAMP DE TARRAGONA" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPCT,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP PONENT" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPP,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP GIRONA" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPG,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP METROPOLITANA BARCELONA" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPB,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP PIRINEU OCCIDENTAL" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPPO,$sexe,$edat,$nombre,$rang_edat" >> $file;
 elif [ "$r_policial" = "RP TERRES DE L'EBRE" ]; 
  then
   echo -e "$any,$nom_mes,$numero_mes,$data,RPTE,$sexe,$edat,$nombre,$rang_edat" >> $file;
 fi
done
} < $1

# Afegim header al nou csv.
sed -i '1 i\any,nom_mes,numero_mes,data,r_policial,sexe,edat,nombre,rang_edat' $file

# Comprovem que el nou csv generat no tingui valors buits o amb espai.
errors=$(tail -n +2 $file | grep -E ",,|, ," | wc -l)
echo -e "S'ha generat un nou script: denuncies2.csv. S'han detectat $errors camp/s buits o amb un espai.\n"

# Filtrem amb grep aquells registres de l'any 2020 i ho guardem a denuncies_20.csv.
tail -n +1 $file | grep -E "^.{3}[0].*" >> denuncies_20.csv
sed -i '1 i\any,nom_mes,numero_mes,data,r_policial,sexe,edat,nombre,rang_edat' denuncies_20.csv

# Comprovem que el nou csv generat no tingui valors buits o amb espai.
errors_20=$(tail -n +2 denuncies_20.csv | grep -E ",,|, ," | wc -l)
echo -e "S'ha generat un nou script: denuncies_20.csv. S'han detectat $errors_20 camps buits o amb un espai.\n"

# Filtrem amb grep aquells registres de l'any 2020 i ho guardem a denuncies_21.csv.
tail -n +2 $file | grep -E "^.{3}[1].*"  >> denuncies_21.csv
sed -i '1 i\any,nom_mes,numero_mes,data,r_policial,sexe,edat,nombre,rang_edat' denuncies_21.csv

# Comprovem que el nou csv generat no tingui valors buits o amb espai.
errors_21=$(tail -n +2 denuncies_21.csv | grep -E ",,|, ," | wc -l)
echo -e "S'ha generat un nou script: denuncies_21.csv. S'han detectat $errors_21 camps buits o amb un espai.\n"

# Comprovem que la suma del nombre de registres dels nous csv generats sigui igual que l'original.
total_rows_20=$(tail -n+2 denuncies_20.csv | wc -l)
total_rows_21=$(tail -n+2 denuncies_21.csv | wc -l)
total_rows=$(expr $total_rows_20 + $total_rows_21)
echo -e "La suma total de files pels nous csv: denuncies_20.csv i denuncies_21.csv és $total_rows. Amb el que corroborem que totes les dades s'han filtrat correctament.\n"

echo -e "L'Script b1.sh s'ha executat correctament.\n"
echo -e "-------------------------------------------------------------------"





