!#/bin/bash

clear

repertoire="";

menu(){
# Menu principal
echo -e "\033[36mScript de création de VHost, sites et comptes FTP\n\033[0m"
testdistrib
testweb
read -p "Nom du site : " nomsite
echo "Nom du site : "$nomsite
read -p "Est-ce bien correct ? (O/n) : " validenom
testnom
}


choixinvalide(){
# Menu si choix non valide
echo -e "\033[31mChoix incorrect !\033[0m\nVeuilez entrer une valeur correcte.\n"
menu
}

testftp(){
# Test et création compte FTP
if grep "^ftp-$nomsite" /etc/passwd > /dev/null;
        then echo -e "\033[31mUtilisateur déjà existant !\n\033[0m"
        read -p "Veuillez spécifier si vous souhaitez continuer ou non ? " choixplus
                case $choixplus in
                annuler | Annuler | ANNULER | 0 | n | N | non | Non | NON | no | No | NO)
                echo -e "Annulation : retour au menu.\n"
                menu
                ;;
                *)
                read -p "Veuillez renseigner un nouveau nom de compte :" nom2
                        if grep "^ftp-$nom2" /etc/passwd > /dev/null;
                                then testftp
                                        else useradd ftp-$nom2 -d $repertoire/$nomsite -G nginx -s /bin/false
                                        passwd ftp-$nom2
                                        useradd ftp-$nom2 -d /$repertoire/$nomsite -G nginx -s /bin/false
                                        passwd ftp-$nom2
                        fi
                ;;
                esac
        else useradd ftp-$nomsite -d $repertoire/$nomsite -G nginx -s /bin/false
        passwd ftp-$nomsite
fi
}

testdistrib(){
# Test de la distribution

OSPKG="";
if [ `uname -r | egrep '(-RELEASE)'` ];
        then OSPKG="BSD";
        elif [ -f /etc/debian_version ];
        then OSPKG=DEBIAN;
        elif [ -f /etc/SuSE-release ];
        then OSPKG=REDHAT;
        elif [ -f /etc/fedora-release ];
        then OSPKG=REDHAT;
        elif [ -f /etc/redhat-release ];
        then OSPKG=REDHAT;
        elif [ -f /etc/centos-release ];
        then OSPKG=REDHAT;
        elif [ `uname -r | egrep '(ARCH)'` ];
        then OSPKG="ARCH";
        else echo -e "\033[31mLa distribution n'est pas supportée.\n\033[0m";
        echo -e "Merci de modifier le script en fonction de votre besoin.\n";
        exit 1;
fi
}

testweb(){
# Test du serveur Web installé en fonction de la distribution

SRVWEB=""

if [ $OSPKG == "REDHAT" ];
        then
                if [ `rpm -qa | grep -qw nginx` ];
                then SRVWEB="NGINX";
                else SRVWEB="APACHE";
                fi
elif [ $OSPKG == "DEBIAN" ];
        then
                if [ `dpkg -l | grep -qw nginx` ];
                then SRVWEB="NGINX";
                else SRVWEB="APACHE";
                fi
elif [ $OSPKG == "ARCH" ];
        then
                if [ `pacman -Qq | grep -qw nginx` ];
                then SRVWEB="NGINX";
                else SRVWEB="APACHE";
                fi
fi
}

debut(){
# Script principal

# APACHE
if [ $SRVWEB == "APACHE" ];
        then
        repertoire="/var/www"
        vhostroot="/etc/apache2"

        # Création du compte FTP
        testftp
        # Création du site
        if [ ! -f $repertoire/$nomsite/index.html ];
        then mkdir -p $repertoire/$nomsite
        echo "<HTML><TITLE>"$nomsite"&bull; Page de test</TITLE><BODY BGCOLOR=\"#eeeeee\"><FONT COLOR=\"darkblue\"><MARQUEE>Page en construction...</MARQUEE></FONT></BODY></HTM>" > /var/www/$nomsite/index.html
        fi
        chmod 644 -R $repertoire/$nomsite
        chown -R www-data:www-data $repertoire/$nomsite

        # Création du VHost
        if [ ! -f $vhostroot/sites-avalaible/$nomsite ];
        then echo -e "<VirtualHost *:80>\nServerName www."$nomsite"\nServerAlias "$nomsite"\nDocumentRoot "$repertoire"/"$nomsite"\n<Directory "$repertoire"/"$nomsite">\nAllowOverride All\nOrder Allow, Deny\nAllow from All\n</Directory>\nErrorLog /var/log/apache2/"$nomsite"-error.log\nCustomLog /var/log/apache2/"$nomsite"-access.log combined\n</VirtualHost>" > $vhostroot/sites-avalaible/$nomsite
        fi
        # Activation du site
        if [ ! -e $vhostroot/sites-enabled/$nomsite ];
        then ln -s $vhostroot/sites-avalaible/$nomsite $vhostroot/sites-enabled/$nomsite
        fi

        # Redémarrage du service Web
        apache2ctl graceful

# NGINX
elif [ $SRVWEB == "NGINX" ];
        then
        repertoire="/usr/share/nginx/html"
        vostroot="/usr/share/nginx"

        # Création compte FTP
        testftp
        # Création site
        if [ ! -f /usr/share/nginx/html/$nomsite/index.html ];
        then mkdir -p $repertoire/$nomsite
        echo "<HTML><TITLE>"$nomsite"&bull; Page de test</TITLE><BODY BGCOLOR=\"#eeeeee\"><FONT COLOR=\"darkblue\"><MARQUEE>Page en construction...</MARQUEE></FONT></BODY></HTM>" > /usr/share/nginx/html/$nomsite/index.html
        fi
        # Attribution des droits
        chmod -R 644 /usr/share/nginx/html/$nomsite
        chown -R nginx:nginx /usr/share/nginx/html/$nomsite
        # Création Server Block (VHost)
        if [ ! -f /usr/share/nginx/sites-avalaible/$nomsite ];
        then
        echo -e "server {\nlisten 80;\nserver_name www."$nomsite"" ""$nomsite";\nroot /usr/share/nginx/"$nomsite"/;\naccess_log /var/log/nginx/"$nomsite"-access.log;\nerror_log /var/log/nginx/"$nomsite"-error.log;\nindex index.html index.htm index.php;\nlocation ~ /\.ht {\ndeny all;\n}\n}\n" > /usr/share/nginx/sites-avalaible/$nomsite
        fi
        # Activation du site
        if [ ! -e /usr/share/nginx/sites-enabled/$nomsite ];
        then
        ln -s /usr/share/nginx/sites-avalaible/$nomsite /usr/share/nginx/sites-enabled/$nomsite
        fi

        # Redémarrage service Web
        service nginx restart

else echo -e "\033[31mLe service web installté n'est pas supporté.\n\033[0m"
exit 1
fi

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

# Ouverture du menu
menu

