#!/bin/bash
#Data: 21/05/2022
#Objectiu: Mostrar una sortida amb HTML on es visualitzi un conjunt de gràfiques i taules sobre les denúncies per desaparicions a Catalunya per l'any que s'introdueixi a la comanda (2020 o 2021).
#Nom i tipus dels camps d'entrada: any (enter), nom_mes (text), numero_mes (enter), data (date), r_policial (text), sexe (text), edat (sencer), nombre (booleà), rang_edat (text).
#Operacions realitzades: Càlculs sobre la mitjana, la desviació estàndard i el percentatge sobre les denúncies per desaparicions, tenint en compte el sexe, o els rangs d'edat o els dos. A més a més, s'han fet agrupacions segons les dates o els rangs d'edat i se li ha sumat el nombre de desapareguts.
#Nom i tipus de els nou camps generats: Pel dataset: dates.csv (data (data), nombre (enter)), pels datasets rang_edath.csv i rang_edatd.csv (rang_edat (text), sexe (text) i nombre (enter))

echo -e "Inici de l'execució de l'Script c.sh"
echo -e "-------------------------------------------------------------------\n"

if [ -e dates.csv ]; 
	then
	   gio trash rang_edath.csv
	   gio trash rang_edatd.csv
	   gio trash dates.csv
fi

# INICI BLOC 1
# Agrupem segons les dates i sumem per cada una el nombre de denúncies per desapareguts.
awk 'BEGIN{
FS=","
}
{if (NR == 1) 
	{next }
	{ a[$4] += $8 }
}
END{
	{print "data,nombre" >> "correct.csv"}
	for (i in a) {
	   printf "%s,%s\n",i,a[i] >> "correct.csv"
	}
}' $1
sort -k1 -t, correct.csv >> dates.csv
gio trash correct.csv
# FINAL BLOC 1

# INICI BLOC 2
# A partir d'aquest punt, començarem a redactar el codi per la sortida HTML.
(
# Obrim condició: Si es passa el fitxer del 2020 printem el primer títol. Sinó, printem el segon títol del 2021.
if [ $1 == "denuncies_20.csv" ]; 
	then
	echo "<center><font size=12>Denúncies per desaparicions a Catalunya al 2020</font></center><br/>"
else
  echo "<center><font size=12>Denúncies per desaparicions a Catalunya al 2021</font></center><br/>"
fi

# INICI BLOC 2.1
# Generem un fitxer csv (rand_edath.csv i rang_edatd.csv) nou amb la suma total per rang d'edat i per sexe.
awk 'BEGIN{
FS=","
print "<HTML><BODY>" # Obrim cos i HTML.
}
# Filtrem per homes i edat.
{if (NR!=1 && $6=="Home"){
	if ($9=="De 0 a 14 anys" ){ 
		male_less14+=1
	}
	else if ($9=="De 15 a 29 anys" ){ 
		male_less29+=1
	}
	else if ($9=="De 30 a 44 anys" ){ 
		male_less44+=1
	}
	else if ($9=="De 45 a 64 anys" ){ 
		male_less64+=1
	}
	else if ($9=="De 65 anys i més" ){ 
		male_mes64+=1
	}
     }
 }
 # Filtrem per dones i edat.
{if (NR!=1 && $6=="Dona"){
	if ($9=="De 0 a 14 anys" ){ 
		female_less14+=1
	}
	else if ($9=="De 15 a 29 anys" ){ 
		female_less29+=1
	}
	else if ($9=="De 30 a 44 anys" ){ 
		female_less44+=1
	}
	else if ($9=="De 45 a 64 anys" ){ 
		female_less64+=1
	}
	else if ($9=="De 65 anys i més" ){ 
		female_mes64+=1
	}
     }
}
END{ # Generem els csv: rang_edath.csv (homes) i rang_edatd.csv (dones).

	printf "<14,Home,%s\n", male_less14 >> "rang_edath.csv";
	printf "14-29,Home,%s\n", male_less29 >> "rang_edath.csv";
	printf "30-44,Home,%s\n", male_less44 >> "rang_edath.csv"
	printf "45-64,Home,%s\n", male_less64 >> "rang_edath.csv"
	printf ">64,Home,%s\n", male_mes64 >> "rang_edath.csv"
# Ara ho guardem a rang_edatd.csv per les dones.
	printf "<14,Dona,%s\n", female_less14 >> "rang_edatd.csv"
	printf "14-29,Dona,%s\n", female_less29 >> "rang_edatd.csv"
	printf "30-44,Dona,%s\n", female_less44 >> "rang_edatd.csv"
	printf "45-64,Dona,%s\n", female_less64 >> "rang_edatd.csv"
	printf ">64,Dona,%s", female_mes64 >> "rang_edatd.csv"
	
}' $1
# FINAL BLOC 2.1

# INICI BLOC 2.2
# Amb Gnuplot generarem les dues gràfiques. Una on mostri l'evolució del nombre de desapareguts, i l'altre que mostri el nombre de desapareguts per sexe i edat. La primera serà una gràfica lineal i la segona de barres.
gnuplot <<EOF_GNUPLOT 
set terminal canvas enhanced size 1000,800;
set encoding utf8;
set multiplot layout 2,1;


set origin 0, 0;
set size 1, 0.5;
set datafile separator",";
set style histogram clustered;
set grid;
set boxwidth 1;
set style fill solid;
set encoding utf8;
set title "NOMBRE DE DESAPAREGUTS PER AMBDÓS SEXES I RANG D'EDAT A CATALUNYA";
set ylabel "Nombre de desapareguts";
plot 'rang_edath.csv' using 3:xtic(1) title "Home" w histograms lt rgb "#009E73",'rang_edatd.csv' using 3:xtic(1) title "Dona" w histograms lt rgb "#9400D3"

set origin 0, 0.6;
set size 1, 0.4
set bmargin 1;
set grid;
set datafile separator",";
set xdata time;
set timefmt "%m-%d";
set xrange ["01-01":"12-01"];
set title "EVOLUCIÓ DEL NOMBRE DE DESAPAREGUTS A CATALUNYA";
set ylabel "Nombre de desapareguts";
plot "dates.csv" using 1:2 title "Desapareguts" with lines;

unset multiplot
EOF_GNUPLOT
# Finalitzem amb gnuplot.
# FINAL BLOC 2.2

echo "<center><p>Gràfiques: D'una banda tenim a la primera gràfica l'evolució de les denúncies per desapareguts. Hem de tenir en compte que el format de la data és: %m/%d. D'altra banda, en el gràfic de barres mostrem el nombre de desapareguts (segons les denúncies registrades) per rangs d'edat. Aquests rangs segueixen la distribució oficial de l'Idescat. A més a més, hem diferenciat per sexe les desaparicions.</p><br/><center>"

# INICI BLOC 2.3
# En aquest punt generarem la primera taula on es mostri les estadístiques generals de desapareguts per sexe. (calcularem: mitjana edat, desviació estàndard edat i percentatge de desapareguts per sexe).
awk 'BEGIN{
FS=","
i=0
male=0
female=0
print "<p></p><br/>"
print "<center><TABLE border=\"1\"></center>" # Obrim taula.
print "<TR><TH colspan="4">Estadístiques dels desapareguts per ambdós sexes </TR></TH>"
print "<TR><TH>Sexe</TH><TH>Mitjana edat</TH><TH>Desviació estàndard</TH><TH>Percentatge</TR></TH>"
} 
# Filtrem per home i dona.
{if (NR!=1){
	if ($6=="Home" ){ 
		male_age[NR-1]=$7
		male+=1
	}
	if ($6=="Dona"){
		female_age[NR-1]=$7
		female+=1
	}
	i+=1 
	}
}
END{
if (i>0){
	for (i=0;i<NR;i++){
		male_sum_age+=male_age[i] # Primer pas per calcula la mitjana (edat, home), sumem tots els valors.
		male_age_exponential+=male_age[i]*male_age[i] # Primer pas per calcular la desviació típica (edat, home), exponenciem cada valor i ho sumem tot.
		female_sum_age+=female_age[i]
		female_age_exponential+=female_age[i]*female_age[i]
	} 
	if (male>0){
		median_male_age= male_sum_age/male # ültim pas per calcular la mitjana (edat, home).
		median_age_male_exponential= median_male_age*median_male_age # Segon pas per calcular la desviació típica (edat, home), exponenciem la mitjana.
		sd_age_male= sqrt((male_age_exponential/male)-median_age_male_exponential) # ültim pas per calcular la desviació típica (edat, home).
	}
	if (female>0){
		median_age_female= (female_sum_age/female)
		median_age_female_exponential= median_age_female*median_age_female
		sd_age_female= sqrt((female_age_exponential/female)-median_age_female_exponential)
	}
# Calculem percentatge per amdós sexes.
percentage_female = (female/i)*100
percentage_male = (male/i)*100
}
printf "<TR><TD>Home</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_male_age, sd_age_male, percentage_male
printf "<TR><TD>Dona</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_age_female, sd_age_female, percentage_female
print "</TABLE>" # Tanquem taula.
print "<center><p>Taula 1: Per aquesta taula es mostra la mitjana d'\''edat dels desapareguts, la desviació estàndard i el percentatge per ambdós sexes.</p><br/><center>"
}' $1
# FINAL BLOC 2.3

# INICI BLOC 2.4
# Ampliem les estadístiques. Calculem la mitjana i la desviació estàndard de l'edat i el percentatge per sexe i rang d'edat.
awk 'BEGIN{
FS=","
i14=0
i29=0
i44=0
i64=0
i65=0
total_male_less14=0
total_male_less29=0
total_male_less44=0
total_male_less64=0
total_male_mes64=0
total_female_less14=0
total_female_less29=0
total_female_less44=0
total_female_less64=0
total_female_mes64=0

print "<center><TABLE border=\"1\"></center>" # Obrim taula.
print "<TR><TH colspan="5">Estadístiques per ambdós sexes i rang de edat</TR></TH>"
print "<TR><TH>Edat</TH><TH>Sexe</TH><TH>Mitjana edat</TH><TH>Desviació estàndard</TH><TH>Percentatge</TR></TH>"
}
# Filtrem per rang de edat i sexe.
{if (NR!=1 && $9=="De 0 a 14 anys"){
	if ($6=="Home" ){ 
		male_less14[NR-1]=$7
		total_male_less14+=1
		
	}
	if ($6=="Dona"){
		female_less14[NR-1]=$7
		total_female_less14+=1
	}
	i14+=1 
	}
}
{if (NR!=1 && $9=="De 15 a 29 anys"){
	if ($6=="Home" ){ 
		male_less29[NR-1]=$7
		total_male_less29+=1
	}
	if ($6=="Dona"){
		female_less29[NR-1]=$7
		total_female_less29+=1
	}
	i29+=1 
	}
}
{if (NR!=1 && $9=="De 30 a 44 anys"){
	if ($6=="Home" ){ 
		male_less44[NR-1]=$7
		total_male_less44+=1
	}
	if ($6=="Dona"){
		female_less44[NR-1]=$7
		total_female_less44+=1
	}
	i44+=1 
	}
}
{if (NR!=1 && $9=="De 45 a 64 anys"){
	if ($6=="Home" ){ 
		male_less64[NR-1]=$7
		total_male_less64+=1
	}
	if ($6=="Dona"){
		female_less64[NR-1]=$7
		total_female_less64+=1
	}
	i64+=1 
	}
}
{if (NR!=1 && $9=="De 65 anys i més"){
	if ($6=="Home" ){ 
		male_mes64[NR-1]=$7
		total_male_mes64+=1
	}
	if ($6=="Dona"){
		female_mes64[NR-1]=$7
		total_female_mes64+=1
	}
	i65+=1 
	}
}
END{ # Comencem a realitzar les operacions.
	for (i=0;i<NR;i++){
	
		male_l14+=male_less14[i] 
		male_l14_exponential+=male_less14[i]*male_less14[i] 
		female_l14+=female_less14[i]
		female_l14_exponential+=female_less14[i]*female_less14[i]
		
		male_l29+=male_less29[i] 
		male_l29_exponential+=male_less29[i]*male_less29[i] 
		female_l29+=female_less29[i]
		female_l29_exponential+=female_less29[i]*female_less29[i]

		male_l44+=male_less44[i] 
		male_l44_exponential+=male_less44[i]*male_less44[i] 
		female_l44+=female_less44[i]
		female_l44_exponential+=female_less44[i]*female_less44[i]
		
		male_l64+=male_less64[i] 
		male_l64_exponential+=male_less64[i]*male_less64[i] 
		female_l64+=female_less64[i]
		female_l64_exponential+=female_less64[i]*female_less64[i]

		male_m65+=male_mes64[i] 
		male_m65_exponential+=male_mes64[i]*male_mes64[i] 
		female_m65+=female_mes64[i]
		female_m65_exponential+=female_mes64[i]*female_mes64[i]


		median_male_l14= male_l14/total_male_less14
		median_l14_male_exponential= median_male_l14*median_male_l14 
		sd_l14_male= sqrt((male_l14_exponential/total_male_less14)-median_l14_male_exponential)
		
		median_male_l29= male_l29/total_male_less29
		median_l29_male_exponential= median_male_l29*median_male_l29 
		sd_l29_male= sqrt((male_l29_exponential/total_male_less29)-median_l29_male_exponential)
		
		median_male_l44= male_l44/total_male_less44
		median_l44_male_exponential= median_male_l44*median_male_l44 
		sd_l44_male= sqrt((male_l44_exponential/total_male_less44)-median_l44_male_exponential)
		
		median_male_l64= male_l64/total_male_less64
		median_l64_male_exponential= median_male_l64*median_male_l64 
		sd_l64_male= sqrt((male_l64_exponential/total_male_less64)-median_l64_male_exponential)

		median_male_m65= male_m65/total_male_mes64
		median_m65_male_exponential= median_male_m65*median_male_m65 
		sd_m65_male= sqrt((male_m65_exponential/total_male_mes64)-median_m65_male_exponential)


		median_female_l14= female_l14/total_female_less14
		median_l14_female_exponential= median_female_l14*median_female_l14 
		sd_l14_female= sqrt((female_l14_exponential/total_female_less14)-median_l14_female_exponential)
		
		median_female_l29= female_l29/total_female_less29
		median_l29_female_exponential= median_female_l29*median_female_l29 
		sd_l29_female= sqrt((female_l29_exponential/total_female_less29)-median_l29_female_exponential)
		
		median_female_l44= female_l44/total_female_less44
		median_l44_female_exponential= median_female_l44*median_female_l44 
		sd_l44_female= sqrt((female_l44_exponential/total_female_less44)-median_l44_female_exponential)
		
		median_female_l64= female_l64/total_female_less64
		median_l64_female_exponential= median_female_l64*median_female_l64 
		sd_l64_female= sqrt((female_l64_exponential/total_female_less64)-median_l64_female_exponential)

		median_female_m65= female_m65/total_female_mes64
		median_m65_female_exponential= median_female_m65*median_female_m65 
		sd_m65_female= sqrt((female_m65_exponential/total_female_mes64)-median_m65_female_exponential)
	
# Calculem percentatge de medalles per amdós sexes.
percentage_male_l14 = (total_male_less14/i14)*100
percentage_male_l29 = (total_male_less29/i29)*100
percentage_male_l44 = (total_male_less44/i44)*100
percentage_male_l64 = (total_male_less64/i64)*100
percentage_male_m65 = (total_male_mes64/i65)*100

percentage_female_l14 = (total_female_less14/i14)*100
percentage_female_l29 = (total_female_less29/i29)*100
percentage_female_l44 = (total_female_less44/i44)*100
percentage_female_l64 = (total_female_less64/i64)*100
percentage_female_m65 = (total_female_mes64/i65)*100
}
# Passem a omplir la taula.

printf "<TR><TD rowspan="2"><15</TD><TD>H</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_male_l14, sd_l14_male, percentage_male_l14
printf "<TR><TD>D</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_female_l14, sd_l14_female, percentage_female_l14

printf "<TR><TD rowspan="2">15-29</TD><TD>H</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_male_l29, sd_l29_male, percentage_male_l29
printf "<TR><TD>D</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_female_l29, sd_l29_female, percentage_female_l29

printf "<TR><TD rowspan="2">30-44</TD><TD>H</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_male_l44, sd_l44_male, percentage_male_l44
printf "<TR><TD>D</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_female_l44, sd_l44_female, percentage_female_l44

printf "<TR><TD rowspan="2">45-64</TD><TD>H</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_male_l64, sd_l64_male, percentage_male_l64
printf "<TR><TD>D</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_female_l64, sd_l64_female, percentage_female_l64

printf "<TR><TD rowspan="2">>64</TD><TD>H</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_male_m65, sd_m65_male, percentage_male_m65
printf "<TR><TD>D</TD><TD>%.2f</TD><TD>%.2f</TD><TD>%.2f</TR></TH>", median_female_m65, sd_m65_female, percentage_female_m65
print "</TABLE>" # Tanquem taula.
print "<center><p>Taula 2: Estadístiques generals de les denúncies per desaparicions que es van donar a Catalunya. Podem veure la mitjana d'\''edat, la desviació estàndard de l'\''edat i el percentatge total. L'\''estructura de la taula està distribuïda per rangs d'\''edat.</p><br/><center>"
}' $1
# FINAL BLOC 2.4

# INICI BLOC 2.5
# En aquest punt generarem una tercera taula per mostrar el total de desapareguts i el seu percentatge respecte el total, segons les regions policials a Catalunya.
awk 'BEGIN{
FS=","
i=0
RPG=0
RPPO=0
RPMS=0
RPCT=0
RPTE=0
RPB=0
RPP=0
RPC=0
RPMN=0
print "<center><TABLE border=\"1\"></center>" # Obrim taula.
print "<TR><TH colspan="3">Desapareguts per regions policials a Catalunya</TH></TR>"
print "<TR><TH>Regió policial</TH><TH>Total desapareguts</TH><TH>Percentatge</TH></TR>"
}
{total_lost+=$8} # Total desapareguts.

# Comencem a filtrar per regions policials.
{if (NR!=1 && $5=="RPG"){
	RPG+=1	
	}
}
{if (NR!=1 && $5=="RPPO"){
	RPPO+=1	
	}
}
{if (NR!=1 && $5=="RPMS"){
	RPMS+=1	
	}
}
{if (NR!=1 && $5=="RPCT"){
	RPCT+=1	
	}
}
{if (NR!=1 && $5=="RPTE"){
	RPTE+=1	
	}
}
{if (NR!=1 && $5=="RPB"){
	RPB+=1	
	}
}
{if (NR!=1 && $5=="RPP"){
	RPP+=1	
	}
}
{if (NR!=1 && $5=="RPC"){
	RPC+=1	
	}
}
{if (NR!=1 && $5=="RPMN"){
	RPMN+=1	
	}
}
END{
# Calculem percentatge per amdós sexes.
percentage_RPG = (RPG/total_lost)*100
percentage_RPPO = (RPPO/total_lost)*100
percentage_RPMS = (RPMS/total_lost)*100
percentage_RPCT = (RPCT/total_lost)*100
percentage_RPTE = (RPTE/total_lost)*100
percentage_RPB = (RPB/total_lost)*100
percentage_RPP = (RPP/total_lost)*100
percentage_RPC = (RPC/total_lost)*100
percentage_RPMN = (RPMN/total_lost)*100

# Omplim la taula.

printf "<TR><TD>RG Barcelona</TD><TD>%s</TD><TD>%.2f</TD><", RPB, percentage_RPB
printf "<TR><TD>RG Camp de Tarragona</TD><TD>%s</TD><TD>%.2f</TD><", RPCT, percentage_RPCT
printf "<TR><TD>RG Central</TD><TD>%s</TD><TD>%.2f</TD><", RPC, percentage_RPC
printf "<TR><TD>RG Girona</TD><TD>%s</TD><TD>%.2f</TD><", RPG, percentage_RPG
printf "<TR><TD>RG Pirineu Occ</TD><TD>%s</TD><TD>%.2f</TD><", RPPO, percentage_RPPO
printf "<TR><TD>RG Metropolitana Nord</TD><TD>%s</TD><TD>%.2f</TD><", RPMN, percentage_RPMN
printf "<TR><TD>RG Metropolitana Sud</TD><TD>%s</TD><TD>%.2f</TD><", RPMS, percentage_RPMS
printf "<TR><TD>RP Ponent</TD><TD>%s</TD><TD>%.2f</TD><", RPP, percentage_RPP
printf "<TR><TD>RG Terres de l'\''ebre</TD><TD>%s</TD><TD>%.2f</TD><", RPTE, percentage_RPTE
print "</TABLE><br/>" # Tanquem taula.
print "Taula 3: En aquesta taula podem veure el total de denúncies per regió policial que es van donar a Catalunya."
print "</BODY></HTML>" # Tanquem cos i HTML.
}' $1
# FINAL BLOC 2.5
# Finalitzem amb les operacions.
) > presentacio.html # Guardem el resultat a presentacio.html.

echo -e "L'Script c.sh s'ha executat correctament.\n"
echo -e "-------------------------------------------------------------------"

# Obrim l'html una vegada executat tot l'script.
xdg-open presentacio.html






 

