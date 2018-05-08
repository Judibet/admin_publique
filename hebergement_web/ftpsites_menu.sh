!#/bin/bash

clear

echo -e "\033[33mAjout ou suppression de site, FTP et VHost\033[0m\n"

menu(){
echo -e "\033[36m1] Création\033[0m\n"
echo -e "\033[31m2] Suppression\033[0m\n"
echo -e "\033[1mQ] Quitter\033[0m\n"

read -p "Merci de sélectionner votre choix : " chx

case $chx in
1 | a | A) sh ./ftpsitescreator.sh
;;
2 | b | B) sh ./ftpsitessuppr.sh
;;
3 | c | C | Q | q) echo -e "Au revoir !\n"; exit 0;
;;
*) echo -e "\033[31mMerci d'indiquer un choix valide.\033[0m\n";
menu
;;
esac
}
menu
