# Pour utiliser une webcam avec Unreal Engine 5 sur macOS, tu peux suivre les étapes ci-dessous :

1. Installer les dépendances
Unreal Engine ne gère pas directement les webcams sur macOS par défaut, il faut donc passer par des plugins et bibliothèques externes.

OpenCV : une bibliothèque très populaire pour l'acquisition et le traitement d'images, y compris la capture de vidéo à partir d'une webcam. Unreal Engine peut interagir avec OpenCV via le plugin UnrealCV ou directement via du code C++.
Media Framework d'Unreal Engine : c'est un outil natif qui gère la lecture de médias comme des vidéos. Cependant, il n'a pas de prise en charge native pour les webcams sur macOS.
2. Installer OpenCV
Si OpenCV n'est pas déjà installé sur ton Mac, tu peux l'installer via Homebrew :

bash
```
brew install opencv
```
3. Configurer Unreal Engine pour utiliser OpenCV
Tu peux ajouter OpenCV dans Unreal en passant par un projet C++. Voici comment :

Crée un projet Unreal en C++.
Ajoute OpenCV à ton projet Unreal en modifiant le fichier .Build.cs de ton projet pour inclure les bibliothèques OpenCV :
cpp
```
PublicAdditionalLibraries.Add("/usr/local/lib/libopencv_core.dylib");
PublicAdditionalLibraries.Add("/usr/local/lib/libopencv_highgui.dylib");
PublicIncludePaths.Add("/usr/local/include");
```

Assure-toi de bien configurer le path vers OpenCV.
4. Écrire du code pour capturer le flux vidéo de la webcam
Une fois OpenCV intégré dans Unreal, tu peux utiliser le code suivant pour capturer un flux vidéo depuis ta webcam :

cpp
```
Copy code
#include <opencv2/opencv.hpp>

void CaptureWebcam()
{
    cv::VideoCapture cap(0); // 0 pour la première webcam

    if (!cap.isOpened()) {
        UE_LOG(LogTemp, Error, TEXT("Impossible d'ouvrir la webcam."));
        return;
    }

    cv::Mat frame;
    while (true) {
        cap >> frame;
        if (frame.empty()) {
            break;
        }

        // Convertir la frame pour l'utiliser dans Unreal Engine (si nécessaire)
        // Par exemple, créer une texture à partir de la frame OpenCV
    }

    cap.release();
}
```
Ce code capture des images de la webcam et tu peux ensuite convertir chaque image en texture utilisable dans Unreal Engine.

5. Créer une texture dynamique dans Unreal
Pour afficher le flux webcam dans Unreal, tu devras convertir les images OpenCV en texture dynamique Unreal Engine (en utilisant UTexture2D).

6. Utiliser un plugin Unreal (Optionnel)
Si tu souhaites éviter l'intégration manuelle, tu peux chercher des plugins Unreal dans le Marketplace qui facilitent l'utilisation de webcams, bien que beaucoup de ces plugins soient conçus pour Windows.

En résumé, la méthode la plus courante est de passer par OpenCV pour capturer le flux vidéo et l'intégrer dans Unreal Engine sous macOS.

Si ton projet Unreal Engine 5 est principalement en Blueprint et que tu souhaites utiliser une webcam sur macOS, voici une alternative qui ne nécessite pas de coder directement en C++ :

1. Utiliser le Plugin Unreal Engine Media Framework
Bien que le Media Framework d'Unreal Engine ne supporte pas directement la capture d'une webcam sur macOS, tu peux contourner cela en utilisant des outils externes pour transformer le flux de la webcam en un fichier vidéo, puis l'utiliser comme source Media.

Étapes :

Utiliser un logiciel tiers pour capturer le flux vidéo de la webcam :
Tu peux utiliser un logiciel comme OBS Studio ou ffmpeg pour capturer en temps réel le flux de la webcam et l'enregistrer en tant que fichier vidéo, ou mieux, le diffuser en streaming en direct (RTMP ou autre protocole).
Configurer un flux RTMP :
Avec OBS ou ffmpeg, tu peux diffuser en direct le flux webcam vers un serveur RTMP local ou distant.
Exemple de commande ffmpeg pour diffuser un flux en RTMP :
```
bash
Copy code
ffmpeg -f avfoundation -i "0" -f flv rtmp://localhost/live/stream
```
Créer une source Media dans Unreal Engine :
Dans Unreal Engine, tu peux utiliser un Media Player pour lire un flux RTMP.
Ouvre ton projet, va dans le Content Browser, fais un clic droit et sélectionne Media > Media Player. Cela te permettra de lire des vidéos ou des flux en streaming dans ton projet Blueprint.
Ensuite, dans les propriétés de ton Media Player, entre l’URL de ton flux RTMP (par exemple, rtmp://localhost/live/stream).
Afficher le flux dans Unreal :
Après avoir créé ton Media Player, tu peux associer ce flux à une texture dans un Material Blueprint.
Ensuite, applique ce material sur n'importe quel objet ou surface dans ta scène pour afficher le flux webcam.
2. Utiliser un Plugin de Webcam via Blueprint
Si tu préfères ne pas configurer manuellement un flux externe, tu peux explorer des plugins spécifiques qui exposent des fonctions de webcam directement utilisables dans Blueprint. Par exemple :

VaQuoleUI (pour les versions précédentes d'Unreal) permet d'intégrer des éléments d'interface utilisateur (y compris les flux de caméra) en HTML5 dans Unreal. Bien qu'il ne soit pas mis à jour pour les versions récentes d'Unreal Engine 5, il pourrait servir de base si adapté.
Webcam Texture Plugin : Tu pourrais rechercher des plugins dans le Marketplace qui offrent une intégration directe de la webcam, certains peuvent être compatibles avec macOS. Si un plugin est disponible, il te permettra de capturer des vidéos via Blueprint directement sans avoir à gérer des flux externes.
3. Blueprint Solution avec OSC (Open Sound Control)
Une autre solution consiste à utiliser un programme externe comme Processing pour capturer la webcam et envoyer des données en temps réel à Unreal Engine via OSC (Open Sound Control). Il existe des plugins Blueprint dans Unreal qui prennent en charge OSC pour recevoir les données, y compris les images.
En résumé :
Si tu souhaites une solution 100 % Blueprint, tu devras utiliser des outils externes pour capturer et diffuser le flux vidéo de la webcam, que tu pourras ensuite lire dans Unreal via le Media Framework. Une alternative serait de trouver un plugin dans le Marketplace qui expose la webcam directement en Blueprint, bien que cela soit plus rare sur macOS.

# nginx et rtmp

Construction du container

```
docker buildx build . --tag nginx-rtmp:1.0 .
```

```
docker run -d -p 1935:1935 --name nginx-rtmp .
```



2. Redémarrer le flux avec ffmpeg
Maintenant que le serveur RTMP est configuré et fonctionnel, tu peux redémarrer ton flux avec ffmpeg :
```
bash
ffmpeg -f avfoundation -framerate 24 -video_size 1920x1080 -i "0" -f flv rtmp://localhost/live/stream
```
Cela devrait fonctionner et permettre à ffmpeg de se connecter à ton serveur RTMP local sur le port 1935. Ensuite, tu peux lire le flux dans Unreal Engine en utilisant l'URL RTMP : rtmp://localhost/live/stream.

3. Lecture du flux dans Unreal Engine
Configure un Media Player dans Unreal pour lire l'URL RTMP (rtmp://localhost/live/stream) et applique ce flux vidéo sur une texture ou un objet dans ton projet.

Si tu rencontres toujours des problèmes, n'hésite pas à me le faire savoir !

