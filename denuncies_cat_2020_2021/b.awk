#! /usr/bin/awk -F inplace
#Data: 21/05/2022
#Objectius de l'script: Modificar la columna de les dates per aconseguir el format: %m-%d.
#Nom i tipus dels camps manipulats: data (data)

END{
{print "Inici de l'execució de l'Script b.awk"}
{print "-------------------------------------------------------------------"}
{print ""}
}

# Modifiquem el format de les dates amb awk.
BEGIN {
FS=OFS=","
}
# Separem les dates per / i ho guardem a date.
{split($4,date,"/")}

# Guardem les columnes i la nova columna de dates modificada.
{if (NR){
	any[NR-2]= $1
	nom_mes[NR-2]= $2
	numero_mes[NR-2]= $3
	dates_noves[NR-2]= date[2] "-" date[1]
	r_policial[NR-2]= $5
	sexe[NR-2]= $6
	edat[NR-2]= $7
	nombre[NR-2]= $8
	rang_edat[NR-2]= $9
	}
}
END{ # Comencem a generar el nou csv amb el header.
	{print "any,nom_mes,numero_mes,data,r_policial,sexe,edat,nombre,rang_edat" > "denuncies1.csv"}
# Obrim bucle per iterar per les array i omplir el csv de dades.
	for (i=0;i<NR;i++){
		{print any[i]","nom_mes[i]","numero_mes[i]","dates_noves[i]","r_policial[i]","sexe[i]","edat[i]","nombre[i]","rang_edat[i] >> "denuncies1.csv"}
	} # Finalitza el bucle.
	
{print "S'ha modificat l'script: denuncies1.csv."}
{print "L'Script b1.sh s'ha executat correctament."}
{print ""}
{print "-------------------------------------------------------------------"}
}

