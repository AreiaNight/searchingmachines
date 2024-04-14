#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
	echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n\n"

	exit 1
}

#Ctrl+c
trap ctrl_c INT 

#Variables globales 
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
	echo -e "\n${purpleColour}[+] Uso de comandos ${endColour}"
	echo -e "\t${greenColour}-u: Actualizar basde de datos${endColour}"
	echo -e "\t${greenColour}-m: Searching command${endColour}"
	echo -e "\t${greenColour}-i: Searching IP machine${endColour}"
	echo -e "\t${greenColour}-y: Youtube video link${endColour}"
	echo -e "\t${greenColour}-d: Searching por dificultad${endColour}"
	echo -e "\t${greenColour}-o: Searching por sistema opreativo${endColour}"
	echo -e "\t${greenColour}-s: Searching por sistema skills${endColour}"
	echo -e "\t${greenColour}-h: Panel de ayuda${endColour}"	
}

function searchMachine(){
	machineName="$1"

	echo -e "\n\n${greenColour}Listando propiedades de: $machineName${endColour}\n"
	cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" |  grep -vE "id:|sku:|resulta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/:/ 󱦰 /'
}

function searchIp(){

	ipAddress="$1"
	machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/:/ 󱦰 /')"

	echo -e "\nLa maquina correspondiente a $ipAddress es $machineName"
	echo -e -n  "Quieres mas info? (Y/N): "
	read replay 

	if [ $replay == "Y" ]; then
		searchMachine $machineName
	else 
		echo -e "\nEntendible, tenga un buen dia estimade"
	fi 
}

function youtubeLink(){

	machineName="$1"

	youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" |  grep -vE "id:|sku:|resulta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube: " | awk 'NF{print $NF}')" 
	
	if [ -n "$youtubeLink" ]; then

    echo -e "\nEl enlace del video de $machineName es: $youtubeLink"


	else

    echo -e "Error 404"

	fi

}

function searchDificulty(){

	dificultad="$1"

	maquinasDificultad="$(cat bundle.js | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column )"

	if [ -n "maquinasDificultad" ]; then

		echo -e "\nLas maquinas con dificultada $dificultad son:\n\n$maquinasDificultad"
	else 
		echo "La maquina que buscas no exite o no esta"
	fi 

}

function machineOS(){

	os="$1"

	machineos="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ -n "machineos" ]; then 
		echo -e "\nLas maquinas con sistema operativo $os son:\n\n$machineos"
	else 
		echo -e "No hay de este sistema opreativo"
	fi 

}

function levelDifficulty(){

	dificultad="$1"
	os="$2"

	lvlDif="$(cat bundle.js | grep "so: \"$os\"" -C 5 | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	echo -e "Vamos a buscar las maquinas con dificultad $dificultad y con sistema operativo $os\n\n$lvlDif"

}

function skillListing (){

	skills="$1"

	skillList="$(cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	echo -e "\nLas maquinas con la/s skill/s $skills son:\n\n$skillList"

}

function updateFiles(){

	echo -e "\n\nComprobando acualizaciones"

if [ -f bundle.js ]; then
	tput civi
    echo -e "\n\nEl archivo existe\n\n"
    curl -s "$main_url" > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    valorTemp=$(md5sum bundle_temp.js | awk '{print $1}')
    valorOriginal=$(md5sum bundle.js | awk '{print $1}')
    tput cnorm

    if [ "$valorTemp" == "$valorOriginal" ]; then
    	tput civis
    	echo -e "\nNo hay acualizaciones"
    	rm bundle_temp.js
    	tput cnorm
    else 
    	tput civis
    	echo -e "\n\nHay actualizaciones | Acualizado"
    	rm bundle.js && mv bundle_temp.js bundle.js 
    	tput cnorm
    fi 
    

else
	tput civis 
    echo -e "El archivo no existe\n\n"
    echo -e "\nIniciando actualizaciones"
    curl -s "$main_url" > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n\nTodos los archivos han sido actualizados"
    tput cnorm
fi

}

#Indicadores 
declare -i parameter_counter=0

#catalizadores -> Estan dentro de indicadores

declare -i catalizeLevel_parameter=0
declare -i catalizeOs_parameter=0 


while getopts "m:i:y:d:o:s:uh" arg; do
	
	case $arg in

		m) machineName=$OPTARG; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		i) ipAddress=$OPTARG; let parameter_counter+=3;;
		y) machineName=$OPTARG; let parameter_counter+=4;;
		d) dificultad=$OPTARG; catalizeLevel_parameter=1; let parameter_counter+=5;;
		o) os=$OPTARG; catalizeOs_parameter=1; let parameter_counter+=6;;
		s) skills=$OPTARG; let parameter_counter=+7;;
		#c) certificated=$OPTARG; let parameter_counter=+8;;
		h) ;;

	esac 
done

#Validar casos con parameter counters 
if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIp $ipAddress
elif [ $parameter_counter -eq 4 ]; then 
	youtubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	searchDificulty $dificultad
elif [ $parameter_counter -eq 6 ]; then
	machineOS $os
elif [ $parameter_counter -eq 7 ]; then
	skillListing "$skills"
elif [ $catalizeLevel_parameter -eq 1 ] && [ $catalizeOs_parameter -eq 1 ]; then
	levelDifficulty $dificultad $os
else
	helpPanel
fi

