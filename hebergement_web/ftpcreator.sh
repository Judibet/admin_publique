!#/bin/bash
clear
menu(){
echo -e "\033[36mScript de création de comptes FTP\n\033[0m"
read -p "Nom du site : " nomsite
echo "Nom du site : "$nomsite
read -p "Est-ce bien correct ? (O/n) : " validenom
testnom
}

choixinvalide(){
echo -e "\033[31mChoix incorrect !\033[0m\nVeuilez entrer une valeur correcte.\n"
menu
}

debut(){
#mkdir -p /var/www/$nomsite
#useradd -d /var/www/$nomsite ftp-$nomsite
#passwd ftp-$nomsite
#echo "<HTML><TITLE>"$nomsite"&bull; Page de test</TITLE><BODY BGCOLOR=\"#eeeeee\"><FONT COLOR=\"darkblue\"><MARQUEE>Page en construction...</MARQUEE></FONT></BODY></HTM>" > /var/www/$nomsite/index.html

mkdir -p /usr/share/nginx/html/$nomsite
useradd -d /usr/share/nginx/html/$nomsite ftp-$nomsite
passwd ftp-$nomsite
echo "<HTML><TITLE>"$nomsite"&bull; Page de test</TITLE><BODY BGCOLOR=\"#eeeeee\"><FONT COLOR=\"darkblue\"><MARQUEE>Page en construction...</MARQUEE></FONT></BODY></HTM>" > /usr/share/html/$nomsite/index.html
chown -R $ftp-nomsite:nginx /usr/share/nginx/html/$nomsite
}

testnom(){
case "$validenom" in
        o | O | oui | Oui | OUI | y | Y | yes | Yes | YES) debut
        ;;
        n | N | non | NON | no | No | NO ) menu
        ;;
        *) choixinvalide
        ;;
esac
}

#Ouverture du menu
menu
