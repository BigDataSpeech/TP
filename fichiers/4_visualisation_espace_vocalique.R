# Ecole d'été Big Data & Speech, Roscoff, Juillet 2018
# TP paramètres acoustiques
# Nicolas Audibert et Cédric Gendrot
# Partie 4 : visualisation d'espaces vocaliques
#############################################################

# Pour visualiser l'espace vocalique en fonction de différentes conditions, nous allons utiliser une partie des fonctionnalités du package phonR
# Nous allons nous appuyer sur le script ci-dessous qui définit les paramètres de la fonction plotVowels de phonR et l'exécute sur chacun des groupes définis par la variable colonne_division, en adaptant les paramètres à nos besoins
# Pour exécuter l'ensemble du script en une seule fois dans RStudio sans devoir copier/coller toutes les instructions à chaque fois, cliquer sur "Source" au dessus du code du script
#
# Exécutez d'abord le script tel-quel pour observer les différences d'espace vocalique entre les deux corpus.
# Répétez ensuite l'opération en appliquant un filtrage pour ne conserver que les voyelles dont la durée est supérieure à 30ms
# Adaptez ensuite les paramètres du script pour explorer :
# - les différences en fonction du lieu d'articulation de la consonne qui se trouve à gauche et/ou à droite de la voyelle
# - les différences entre locuteurs
# - tout autre(s) critère(s) de comparaison disponibles dans le jeu de données proposé et qui peuvent être pertinents
# Vous pouvez également jouer sur le paramétrage pour observer également les différences entre corpus dans le plan F2/F3, ou encore pour afficher le tracé du polygon qui relie les centroïdes
#
# Remarques :
# - Avec un nombre de voyelles aussi important, l'affichage de chacun des exemplaires ne permet pas d'obtenir une figure lisible, même en jouant sur la taille des points
# - Si on choisit l'affichage direct des figures générées plutôt que l'export dans un fichier, on obtient des messages d'avertissement car l'argument "filename" n'est alors pas reconnu
# - Le package phonR inclut également d'autres options de visualisation, pour aller plus loin consultez la documentation en ligne : http://drammock.github.io/phonR/
############################################

# package à installer : phonR
# install.packages("phonR")
# doc en ligne : http://drammock.github.io/phonR/
#
# Valeurs possibles pour variables qui contiennent des valeurs logiques
# F = FALSE
# T = TRUE
# (marche aussi avec TRUE et FALSE en toutes lettres)

# NOM DU FICHIER CONTENANT LES VALEURS DES FORMANTS - A PLACER DANS LE MEME DOSSIER QUE LE SCRIPT, SINON PRECISER LE CHEMIN D'ACCES AVEC LE NOM DU FICHIER
fichier_formants = "acoustique_voy_orales_20loc_ESTER_NCCFr_contexte_freqLex_distCentroide_etendu.txt"

# Détermine si on doit lire le fichier de données ou non
# (on peut mettre F pour désactiver si on lance le script plusieurs fois de suite et qu'on travaille sur un gros fichier long à charger)
readDataFile = F

# DESTINATION DES FIGURES GENEREES
# Par défaut, affichage à l'écran (destination_figures = "screen")
# Remplacer par destination_figures = "pdf" pour directement générer un fichier PDF (ATTENTION, selon la configuration, certains symboles peuvent être remplacés par des carrés)
destination_figures = "screen"
# destination_figures = "pdf"
prefixe_fichiers = "plotVowels_Hz"

# NOM DES COLONNES DANS LE FICHIER DE RESULTATS
colonne_F1 = "F1"
colonne_F2 = "F2"
colonne_F3 = "F3"
# VALEURS LIMITES DES AXES
F1min = 100
F1max = 1200
F2min = 600
F2max = 3000
F3min = 2000
F3max = 4200
# LEGENDES AFFICHEES SUR LES AXES
# Plan F1/F2
titre_axe_horizontal_F1F2 = "F2 (Hz)"
titre_axe_vertical_F1F2 = "F1 (Hz)"
# Plan F2/F3
titre_axe_horizontal_F2F3 = "F3 (Hz)"
titre_axe_vertical_F2F3 = "F2 (Hz)"

# colonne qui définit les symboles des voyelles (arbitraire)
colonne_voyelle = "voyelle"

# colonne qui définit les différences de couleur
# pour avoir une couleur par catégorie de voyelle, mettre la même que colonne_voyelle
colonne_comparaison = "voyelle"

# colonnes qui contiennent TRUE ou FALSE et servent à filtrer les résultats
# mettre à NULL si pas de filtrage
colonne_filtre1 = NULL
colonne_filtre2 = NULL
# colonne_filtre1 = "voyelleSup30ms"


# colonne qui définit les différents fichiers à générer
# utiliser "contantCol" pour ne pas faire de division et générer un seul fichier, le nom du fichier généré contiendra alors "all"
colonne_division = "corpus"
# colonne_division = "constantCol"

# AFFICHAGE DU PLAN F2/F3
# Non-affiché par défaut (afficher_F2F3 = FALSE)
# Remplacer par afficher_F2F3 = TRUE pour afficher le plan F2/F3 dans une figure supplémentaire en complément F1/F2
afficher_F2F3 = F

# AFFICHAGE DES ELLIPSES DE DISPERSION
# Non-affiché par défaut (afficher_ellipses = FALSE)
# Remplacer par afficher_ellipses = TRUE pour les afficher (nécessite au moins 2 exemplaires par voyelle x condition x division sinon erreur) : 
afficher_ellipses = T

# LARGEUR DES ELLIPSES AFFICHEES SUR LES FIGURES
# Par défaut, 1 écart-type bivarié (largeur_ellipses = 0.6827)
# Remplacer par largeur_ellipses = 0.95 pour l'intervalle de confiance à 95%
largeur_ellipses = 0.6827
# largeur_ellipses = 0.95
remplissage_ellipses = T

# NOMBRE MINIMUM DE POINTS POUR AFFICHER UNE ELLIPSE DE DISPERSION
# npoints_min_affichage_ellipses=3

# AFFICHAGE DE CHAQUE EXEMPLAIRE MESURE
# Par défaut, le symbole de la voyelle est affiché (affichage_points = "text")
# Remplacer par affichage_points = "shape" pour afficher des formes géométriques
# Remplacer par affichage_points = "none" (ou NULL) pour n'afficher que les ellipses de dispersion
# affichage_points = "shape"
affichage_points = "none"
taille_affichage_points = 1
opacite_points = 1

# AFFICHAGE DES CENTROIDES DE CATEGORIES
# Mêmes valeurs que pour affichage_points
affichage_centroides = "text"
taille_affichage_centroides = 1.5
opacite_centroides = 1

# TRACE DU POLYGONE ENTRE CENTROIDES
affichage_polygone = F
remplissage_polygone = F
sommets_polygone = c('a','i','u')
# sommets_polygone = c('a', 'e', 'E' ,'i','u', 'o', 'c')

# TRACE DE L'ENVELOPPE CONVEXE (convex hull) DE CHAQUE CATEGORIE VOCALIQUE
affichage_convhull = F
remplissage_convhull = F

# PARAMETRES GRAPHIQUES GENERAUX
opacite_remplissage = .2
embellissement_auto = T
facteur_taille_cadre = 1.5
facteur_taille_axes = 1.2
facteur_taille_etiq = 1.5
facteur_taille_legende = 1.7
position_legende = "bottomleft"

#___________________________________________________________
# LECTURE DES DONNEES ET TRACE DES FIGURES - ne pas modifier
#___________________________________________________________
library(phonR)

if(readDataFile) {
  datasetFull = read.table(fichier_formants, header=TRUE, sep="\t", encoding="UTF-8", quote="", comment.char = "", stringsAsFactors = T)
}

dataset = datasetFull

# Keep only target vowels
if(!is.null(colonne_filtre1)) {
  dataset = dataset[dataset[,colonne_filtre1]==1,]
  if(!is.null(colonne_filtre2)) {
    dataset = dataset[dataset[,colonne_filtre2]==1,]
  }
}

# Create a constant column to be used as a dummy splitting factor
dataset$constantCol = "all"
dataset$constantCol = as.factor(dataset$constantCol)


# Split into groups according to the values in column colonne_division
valeurs_colonne_division=subset(dataset, select=colonne_division)
groupes=levels(valeurs_colonne_division[,1])
for (groupe in groupes) {
  message(groupe,"\n")
  dataset_tmp = dataset[subset(dataset, select=colonne_division)==groupe,]
  # Discard rows with undefined F1 or F2 values
  dataset_tmp = dataset_tmp[!is.na(dataset_tmp[,colonne_F1]) & !is.na(dataset_tmp[,colonne_F2]),]
  
  # Process input parameters
  if(affichage_points=="text") {
    affichage_points_boolean = T
    symboles_affichage_points = dataset_tmp[,colonne_voyelle]
  } else {
    if(affichage_points=="shape") {
      affichage_points_boolean = T
      # symboles_affichage_points = formes_predefinies
      symboles_affichage_points = NULL
    } else {
      affichage_points_boolean = F
      symboles_affichage_points = NULL
    }
  }
  if(affichage_centroides=="text") {
    affichage_centroides_boolean = T
    symboles_affichage_centroides = dataset_tmp[,colonne_voyelle]
  } else {
    if(affichage_centroides=="shape") {
      affichage_centroides_boolean = T
      symboles_affichage_centroides = NULL
    } else {
      affichage_centroides_boolean = F
      symboles_affichage_centroides = NULL
    }
  }
  
  if(destination_figures=="pdf") {
    fichier_destination = paste0(prefixe_fichiers,"_",groupe,".pdf")
    if(afficher_F2F3)
      fichier_destination_F2F3 = paste0(prefixe_fichiers,"_",groupe,"_F2F3.pdf")
  } else {
    fichier_destination = NULL
    if(afficher_F2F3)
      fichier_destination_F2F3 = NULL
  }
  
  plotVowels(f1=dataset_tmp[,colonne_F1],
             f2=dataset_tmp[,colonne_F2],
             vowel=dataset_tmp[,colonne_voyelle],
             xlab=titre_axe_horizontal_F1F2,
             ylab=titre_axe_vertical_F1F2,
             group=dataset_tmp[,colonne_comparaison],
             plot.tokens=affichage_points_boolean,
             pch.tokens=symboles_affichage_points,
             cex.tokens=taille_affichage_points,
             alpha.tokens=opacite_points,
             plot.means=affichage_centroides_boolean,
             pch.means=symboles_affichage_centroides,
             cex.means=taille_affichage_centroides,
             alpha.means=opacite_centroides,
             poly.line=affichage_polygone,
             poly.order=sommets_polygone,
             poly.fill=remplissage_polygone,
             hull.line = affichage_convhull,
             hull.fill = remplissage_convhull,
             main=groupe,
             ellipse.line=afficher_ellipses,
             ellipse.conf=largeur_ellipses,
             ellipse.fill=remplissage_ellipses,
             output = destination_figures,
             filename=fichier_destination,
             var.col.by=dataset_tmp[,colonne_comparaison],
             fill.opacity=opacite_remplissage,
             legend.kwd=position_legende,
             pretty=embellissement_auto,
             xlim=c(F2max,F2min),
             ylim=c(F1max,F1min),
             cex.main = facteur_taille_cadre,
             cex.axis = facteur_taille_axes,
             cex.lab = facteur_taille_etiq,
             legend.args = list(cex = facteur_taille_legende))
  if (afficher_F2F3) {
    # Discard rows with undefined F3 values
    dataset_tmp = dataset_tmp[!is.na(dataset_tmp[,colonne_F3]),]
    
    plotVowels(f1=dataset_tmp[,colonne_F3],
               f2=dataset_tmp[,colonne_F2],
               vowel=dataset_tmp[,colonne_voyelle],
               xlab=titre_axe_horizontal_F2F3,
               ylab=titre_axe_vertical_F2F3,
               group=dataset_tmp[,colonne_comparaison],
               plot.tokens=affichage_points_boolean,
               pch.tokens=symboles_affichage_points,
               cex.tokens=taille_affichage_points,
               alpha.tokens=opacite_points,
               plot.means=affichage_centroides_boolean,
               pch.means=symboles_affichage_centroides,
               cex.means=taille_affichage_centroides,
               alpha.means=opacite_centroides,
               poly.line=affichage_polygone,
               poly.order=sommets_polygone,
               poly.fill=remplissage_polygone,
               hull.line = affichage_convhull,
               hull.fill = remplissage_convhull,
               main=groupe,
               ellipse.line=afficher_ellipses,
               ellipse.conf=largeur_ellipses,
               ellipse.fill=remplissage_ellipses,
               output = destination_figures,
               filename=fichier_destination_F2F3,
               var.col.by=dataset_tmp[,colonne_comparaison],
               fill.opacity=opacite_remplissage,
               legend.kwd=position_legende,
               pretty=embellissement_auto,
               xlim=c(F2max,F2min),
               ylim=c(F3max,F3min),
               cex.main = facteur_taille_cadre,
               cex.axis = facteur_taille_axes,
               cex.lab = facteur_taille_etiq,
               legend.args = list(cex = facteur_taille_legende))
  }
}
