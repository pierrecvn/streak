#!/bin/bash

# Script pour créer des commits backdatés du 1er au 19 mars 2026
# Nombre de commits aléatoire entre 1 et 12 par jour
# Usage: ./backdate_commits.sh

set -e

YEAR=2026
MONTH=02
START_DAY=1
END_DAY=28
TOTAL=0

echo "🚀 Création de commits backdatés du ${MONTH}/${START_DAY} au ${MONTH}/${END_DAY}/${YEAR}..."
echo ""

# Vérifie qu'on est bien dans un repo git
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "❌ Erreur : ce répertoire n'est pas un repo git."
  exit 1
fi

LOG_FILE=".commit_log"

for DAY in $(seq $START_DAY $END_DAY); do
  LABEL=$(printf "%04d-%02d-%02d" $YEAR $MONTH $DAY)

  # Nombre de commits aléatoire entre 1 et 12
  NUM_COMMITS=$(( (RANDOM % 12) + 1 ))

  echo "📅 $LABEL — $NUM_COMMITS commit(s)"

  for i in $(seq 1 $NUM_COMMITS); do
    # Heure aléatoire entre 08:00 et 22:00
    HOUR=$(( (RANDOM % 14) + 8 ))
    MIN=$(( RANDOM % 60 ))
    SEC=$(( RANDOM % 60 ))
    DATE=$(printf "%04d-%02d-%02d %02d:%02d:%02d +0100" $YEAR $MONTH $DAY $HOUR $MIN $SEC)

    echo "[$LABEL #$i] update at $HOUR:$MIN:$SEC" >> "$LOG_FILE"
    git add "$LOG_FILE"

    export GIT_AUTHOR_DATE="$DATE"
    export GIT_COMMITTER_DATE="$DATE"

    git commit -m "chore: update $LABEL ($i/$NUM_COMMITS)" --quiet

    unset GIT_AUTHOR_DATE
    unset GIT_COMMITTER_DATE

    TOTAL=$(( TOTAL + 1 ))
  done

  echo "  ✅ $NUM_COMMITS commits créés pour $LABEL"
done

echo ""
echo "🎉 Done! $TOTAL commits créés sur $(($END_DAY - $START_DAY + 1)) jours."
echo ""
echo "📋 Vérification des derniers commits :"
git log --pretty=format:"%h %ad %s" --date=format:"%Y-%m-%d %H:%M" | head -30
echo ""
echo "Pour pousser les commits :"
echo "  git push origin <ta-branche>"