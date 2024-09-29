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

