#!/bin/bash
#Data: 21/05/2022
#Objectius de l'script: Establir una nova columna amb els rangs d'edat segons la columna edat. I netejar les dades de valors buits o amb espais.
#Nom i tipus dels camps manipulats: edat (sencer), nombre (booleà), Nou camp: rang_edat(text) 

echo -e "Inici de l'execució de l'Script b.sh"
echo -e "-------------------------------------------------------------------\n"


if [ -e denuncies1.csv ]; 
	then
	  gio trash denuncies1.csv
fi

# Generem una columna nova segons el rang d'edat.
{
# Iterem pel csv a partir d'un while.
read
while IFS=, read any nom_mes numero_mes data r_policial sexe edat nombre 
do
# Obrim condicions per filtrar per edats.
 if [[ $edat -le 14 ]]; 
  then
   echo "$any,$nom_mes,$numero_mes,$data,$r_policial,$sexe,$edat,$nombre,De 0 a 14 anys" >> denuncies1.csv;
 elif [[ $edat -gt 14 ]] && [[ $edat -le 29 ]];
  then
   echo "$any,$nom_mes,$numero_mes,$data,$r_policial,$sexe,$edat,$nombre,De 15 a 29 anys" >> denuncies1.csv;
 elif [[ $edat -gt 29 ]] && [[ $edat -le 44 ]];
  then
   echo "$any,$nom_mes,$numero_mes,$data,$r_policial,$sexe,$edat,$nombre,De 30 a 44 anys" >> denuncies1.csv;
 elif [[ $edat -gt 44 ]] && [[ $edat -le 64 ]];
  then
   echo "$any,$nom_mes,$numero_mes,$data,$r_policial,$sexe,$edat,$nombre,De 45 a 64 anys" >> denuncies1.csv;
 elif [[ $edat -gt 64 ]];
  then
   echo "$any,$nom_mes,$numero_mes,$data,$r_policial,$sexe,$edat,$nombre,De 65 anys i més" >> denuncies1.csv;
 fi
done # Finalitza el bucle.
} < $1

# Afegim headers.
sed -i '1 i\any,nom_mes,numero_mes,data,r_policial,sexe,edat,nombre,rang_edat' denuncies1.csv

# Comprovem que el nou csv generat no tingui valors buits o amb espai.
errors=$(tail -n +2 denuncies1.csv | grep -E ",,|, ," | wc -l)
which=$(tail -n +2 denuncies1.csv | grep -E ",,|, ,")

echo -e "S'ha generat un nou script: denuncies1.csv. S'han detectat $errors camps buits o amb un espai.\n"

# Obrim condició: si s'ha detectat un error, comptem si aquests són > 0.
if [ $errors -gt 0 ];
then
 echo "S'ha detectat un error a la línia: $which"
fi

echo -e "Procedim a eliminar les línies que tenen un espai buit o en blanc.\n"

# Eliminem files que no tenen comptavilitzat el nombre de desapareguts (en aquest cas és una fila).
sed -i '/,,/d' ./denuncies1.csv

echo -e "L'Script b1.sh s'ha executat correctament.\n"
echo -e "-------------------------------------------------------------------"


