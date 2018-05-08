#!/bin/bash

clear

echo -e "\033[31mSuppresion sites et FTP\033[0m\n"

mensuppr(){
echo -e "\033[31mCette manupulation est irreversible !\033[0m\n"
read -p "Souhaitez-vous continuer ? (O/n) " continuer
case $continuer in
n | N | non | Non | NON | no | No | NO)
        echo "Bonne idée !\nRetour au menu principal.";
        sh ./ftpsites_menu.sh;
        ;;
o | O | oui | Oui | OUI | y | Y | yes | Yes | YES)
        mensuppressions;
        ;;
*)
        echo -e "\033[31mMerci d'indiquer un choix valide.\033[0m";
        menusuppr;
        ;;
esac
}

mensuppressions(){
read -p "Veuillez indiquer le nom du site à supprimer : " nomsitesuppr
echo -e "Vous avez indiqué "$nomsitesuppr".\n"
read -p "Est-ce bien valide ? (O/n) " chxvalide

case $chxvalide in
n | N | non | Non | NON | no | No |NO)
        menusuppression
        ;;
o | O | oui | Oui | OUI | y | Y | yes | Yes | YES)
        echo -e "OK, supression de "$nomsitesuppr".\n";
        userdel ftp-$nomsitesuppr;
        if [ -d /var/wwww/$nomsitesuppr ];
        then rm -rf /var/www/$nomsitesuppr;
        if [ -d /usr/share/nginx/html/$nomsitesuppr ];
        then rm -rf /usr/share/nginx/html/$nomsitesuppr;
        if [ -f /etc/apache2/sites-avalaible/$nomsitesuppr ];
        then rm /etc/apache2/sites-avalaible/$nomsitesuppr;
        if [ -e /etc/apache2/sites-enabled/$nomsitesuppr ];
        then rm /etc/apache2/sites-enabled/$nomsitesuppr;
        if [ -f /usr/share/nginx/sites-avalaible/$nomsitesuppr ];
        then rm /usr/share/nginx/sites-avalaible/$nomsitesuppr;
        if [ -e /usr/share/nginx/sites-enabled/$nomsitesuppr ];
        then rm /usr/share/nginx/sites-enabled/$nomsitesuppr;

        echo "La suppression a bien été effectuée !\n";

        ;;
*)
        echo -e "\033[31mMerci d'indiquer un choix valide.\033[0m";
        menusuppression
        ;;
esac
}
