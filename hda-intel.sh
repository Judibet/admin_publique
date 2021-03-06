#!/bin/bash
# CONSTANTES #
AUDIO_INTEL="lsmod | grep snd_hda_intel | head -n 1 | awk '{print  $1}' | tr '[:upper:]' '[:lower:]'"
REP_CONFIG="/etc/modprobe.d/"
FICHIER_CONFIG="snd-hda-intel.conf"
if [[ $(whoami) != "root" ]]; then
	ACTIVE_ROOT="sudo"
fi

# FONCTIONS #
function TestW(){
	# Variables locales
	local CodeRetour=${1}						# Code retour
	#
	if [[ "${CodeRetour}" -ne 0 ]]; then
		echo " Erreur d'écriture survenue"
		exit 1
	fi
}

function TestFichier(){
	# Variables locales
	local ChoixValide=0						# Type de choix
	local CodeRetour=0						# Code retour
	#
	if [[ ! -z $(grep -ri snd-hda-intel "${REP_CONFIG}") ]]; then
		echo " Configuration du fichier audio Intel détectée"
		while [[ ${ChoixValide} -ne 1 ]];
			do
			read -p " Souhaitez-vous continuer ? (O/n) " ChoixContinuer
			case "${ChoixContinuer}" in
				"O" | "o" )
					local ChoixValide=1
				;;
				"N" | "n" )
					local ChoixValide=1
					echo " Sortie du script"
					exit 0
				;;
				* )
					local ChoixValide=0
				;;
			esac
		done
	else
		if [[ ! -e "${REP_CONFIG}/${FICHIER_CONFIG}"  ]]; then
			$(ACTIVE_ROOT) touch "${REP_CONFIG}/${FICHIER_CONFIG}"	2>&1
			local CodeRetour=${?}
			TestW ${CodeRetour}
		fi
		EcritureConfig
	fi
}

function EcritureConfig(){
	# Variables locales
	local CodeRetour=0						# Code retour
	#
	echo " Configuration pour audio Intel en cours..."
	# Écriture dans le fichier
	$(ACTIVE_ROOT) echo "# Permet d'avoir le son !
	options snd-hda-intel model=auto

	# Alias pour les cartes
	alias char-major-116 snd
	alias snd-card-0 snd-hda-intel
	alias snd-card-1 snd-hda-intel

	# Changement d'index du périphérique
	options snd-hda-intel id=Generic_1 index=0
	options snd-hda-intel id=Generic index=1

	" >> "${REP_CONFIG}/${FICHIER_CONFIG}"				2>&1
	local CodeRetour=${?}
	TestW ${CodeRetour}
}

function DemandeReboot(){
	# Variables locales
	local ChoixValide=0						# Type de choix
	#
	echo " Pour appliquer la configuration, il est préférable de lancer le poste (et non le service)"
	while [[ ${ChoixValide} -ne 1 ]];
		do
		read -p " Souhaitez-vous redémarrer ? (O/n) " ChoixRedemarre
		case ${ChoixRedemarre} in
			"O" | "o" )
				local ChoixValide=1
				echo " Rédémarrage en cours..."
				sleep 5
				init 6
			;;
			"N" | "n" )
				local ChoixValide=1
				echo " Très bien mais pensez à redémarrer votre poste pour que les modifications s'appliquent !"
				exit 0
			;;
			* )
				local ChoixValide=0
			;;
		esac
	done
}

# DÉBUT DU SCRIPT #
TestFichier
DemandeReboot

# FIN #
exit 0
