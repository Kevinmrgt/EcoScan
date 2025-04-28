#!/bin/bash

# Script pour ajouter le namespace au plugin tflite_flutter

PLUGIN_PATH="$HOME/.pub-cache/hosted/pub.dev/tflite_flutter-0.9.5/android/build.gradle"

if [ -f "$PLUGIN_PATH" ]; then
  echo "Ajout du namespace au plugin tflite_flutter..."
  
  # Créer un fichier temporaire pour la modification
  TMP_FILE=$(mktemp)
  
  # Copie le contenu original dans le fichier temporaire
  cat "$PLUGIN_PATH" > "$TMP_FILE"
  
  # Rechercher la ligne "android {" et ajouter le namespace après
  sed -i '/android {/a \    namespace "com.tfliteflutter.tflite_flutter_plugin"' "$TMP_FILE"
  
  # Remplacer le fichier original par le fichier modifié
  cat "$TMP_FILE" > "$PLUGIN_PATH"
  
  # Supprimer le fichier temporaire
  rm "$TMP_FILE"
  
  echo "Modification réussie!"
else
  echo "Le fichier du plugin tflite_flutter n'a pas été trouvé à l'emplacement attendu."
  exit 1
fi