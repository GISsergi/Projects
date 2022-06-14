#!/bin/bash
#Data: 21/05/2022

echo -e "Inici de l'execució de l'Script a.sh"
echo -e "-------------------------------------------------------------------\n"

# Guardem l'URL a path, i el nom del csv a file.
path="https://analisi.transparenciacatalunya.cat/api/views/bp4b-qsst/rows.csv?accessType=DOWNLOAD"
file="Den_ncies_de_persones_desaparegudes.csv"
newfile="denuncies.csv"

# Obrim condició. Si existeix l'últim fitxer que es va crear, fem neteja. 
if [ -e denuncies_20.csv ]; 
	then
	  gio trash denuncies_20.csv
	  gio trash denuncies_21.csv
	  gio trash denuncies1.csv
	  gio trash denuncies2.csv
fi

# Si el fitxer denuncies.csv no existeix el descarreguem de l'URL proporcionada.
if [[ ! -f $newfile ]];
then
    echo -e "Procedim a descarregar el csv de denúncies per desapareguts\n"
    curl $path > $file
    mv $file $newfile
fi


# Calculem el total de columnes i de files.
total_columns=$(head -1 $newfile | sed 's/[^,]//g' | wc -c)
total_rows=$(tail -n+2 $newfile | wc -l)

# Obrim condició: si no s'ha passat un paràmetre d'entrada a la comanda mostrem path, nombre columnes i files.
if [ -z "$1" ]; 
	then
	 echo -e "La URL de descàrrega és: $path.\n\n""El nombre de columnes és:"$total_columns "\nMentre que el nombre de registres és:" $total_rows  
# Si s'ha passat un paràmetre (o altre cosa) mostrem path, total de columnes i files, el format del fitxer i el tipus de dades de cada columna.	 
else
  echo -e "La URL de descàrrega és: $path.\n\n""El nombre de columnes és:"$total_columns "\nMentre que el nombre de registres és:" $total_rows"\n"  
  echo -e "EL format del nostre fitxer és: ${newfile##*.}\n"
  echo -e "Els tipus de dades per a cada columna són els següents:\n"
  csvstat --type $newfile 

# Verifiquem que la columna Date té dates. És a dir, analitzem si segueixen totes el mateix patró (xx/xx/xxxx).

awk -F ',' 'total=0 {if ($4~/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}/) total+=1}END{if ($total~$total_rows) print "\nPodem comprovar que la columna Date segueix el mateix patró (xx/xx/xxxx) en tots els registres. Amb el que podem confirmar que tots tenen el mateix format de data."}' $newfile
fi

echo -e "L'Script a.sh s'ha executat correctament.\n"
echo -e "-------------------------------------------------------------------"




