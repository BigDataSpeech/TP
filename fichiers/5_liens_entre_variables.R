# Ecole d'été Big Data & Speech, Roscoff, Juillet 2018
# TP paramètres acoustiques
# Nicolas Audibert et Cédric Gendrot
# Partie 5 : exploration de liens entre variables
#############################################################

# Nous allons enfin exploiter les variables correspondant aux mesures de centralisation/dispersion dans l'espace vocalique, et notamment distanceCentroideBark qui mesure la distance euclidienne entre chaque voyelle et le centre de l'espace vocalique du locuteur dans l'espace F1/F2 converti en Bark
# Comme prédit par la théorie H&H de Lindblom et abondamment documenté dans la littérature, on s'attend à ce que les voyelles plus longues soient plus périphériques, et donc à ce que cette distance augmente avec la durée
# Voyons ce qu'il en est dans chacun des deux corpus, en nous appuyant sur des fonctions permettant de comparer des nuages de points ou figures équivalentes
######################################

# On a stocké précédemment le jeu de données complet dans la variable datasetFull, il suffit de le récupérer
dataset = datasetFull

# Mais si on a fermé la session ou vidé l'espace de travail entre temps, on peut aussi le charger à nouveau
fichier_entree = "acoustique_voy_orales_20loc_ESTER_NCCFr_contexte_freqLex_distCentroide_etendu.txt"
dataset = read.table(fichier_entree, header=TRUE, sep="\t", encoding="UTF-8", quote="", comment.char = "")

# Commençons par afficher un nuage de points qui représente la distance au centroïde en fonction de la durée, avec une couleur différente pour chacun des deux corpus
# Pour cela il faut tout d'abord charger la fonction get_scatterplot_with_independant_variable (qui utilise les packages plyr et ggplot2)
source("get_scatterplot_with_independant_variable.R")
# On peut ensuite appeler cette fonction pour générer le nuage de point et afficher les coefficients de corrélation correspondants
fig = get_scatterplot_with_independant_variable(
  dataset,
  x_variable = "dureeMs",
  y_variable = "distanceCentroideBark",
  independent_variable = "corpus",
  display_generated_figure=TRUE,
  display_correlation_coefficients_in_legend=TRUE,
  use_rank_correlation=FALSE
)
# On a bien une corrélation positive bien que modérée entre ces deux variables dans chacun des deux, mais sur un jeu de données aussi volumineux le nuage de points est peu lisible

# Une alternative possible est d'afficher un graphe de densité 2D, qui indique par des nuances de couleur la densité de points présents dans les différentes zones du graphe
# En revanche ce type de graphe n'est pas compatible avec le fait de superposer sur un même graphe les différentes modalités de la variable indépendante
# Nous allons donc générer une figure distincte pour chacun des deux corpus, en prenant soin de conserver la même échelle pour permettre la comparaison
# Pour cela nous allons utiliser la fonction get_scatterplot_for_each_modality_of_independant_variable
source("get_scatterplot_for_each_modality_of_independant_variable.R")

figVect = get_scatterplot_for_each_modality_of_independant_variable(
  dataset,
  x_variable = "dureeMs",
  y_variable = "distanceCentroideBark",
  independent_variable = "corpus",
  scaleX=NULL,
  scaleY=NULL,
  display_as_2d_density_plots=TRUE,
  display_generated_figures=TRUE,
  display_values_count=TRUE,
  display_correlation_coefficients=TRUE,
  use_rank_correlation=FALSE
)

# Etant donné qu'une faible proportion de voyelles ont des valeurs élevées de durée et/ou de distance au centroïde, le paramétrage automatique des limites de la figure ne permet pas de bien visualiser ce qu'il se passe dans la plage de valeurs pour laquelle la densité de voyelles est beaucoup plus élevées.
# Nous allons donc générer à nouveau ces figures, en faisant un zoom sur cette plage de valeurs
figVect = get_scatterplot_for_each_modality_of_independant_variable(
  dataset,
  x_variable = "dureeMs",
  y_variable = "distanceCentroideBark",
  independent_variable = "corpus",
  scaleX=c(0,150),
  scaleY=c(0,4),
  display_as_2d_density_plots=TRUE,
  display_generated_figures=TRUE,
  display_values_count=TRUE,
  display_correlation_coefficients=TRUE,
  use_rank_correlation=FALSE
)

# Comme nous avons pu l'observer précédemment, les deux corpus incluent un certain nombre d'occurrences de schwa (étiqueté "x"), qui pourraient expliquer au moins en partie le lien plus faible qu'attendu entre nos variables
# Voyons ce qu'il en est si nous excluons le schwa de l'analyse
datasetSansSchwa = dataset[dataset$voyelle!="x",]
figVect = get_scatterplot_for_each_modality_of_independant_variable(
  datasetSansSchwa,
  x_variable = "dureeMs",
  y_variable = "distanceCentroideBark",
  independent_variable = "corpus",
  scaleX=c(0,150),
  scaleY=c(0,4),
  display_as_2d_density_plots=TRUE,
  display_generated_figures=TRUE,
  display_values_count=TRUE,
  display_correlation_coefficients=TRUE,
  use_rank_correlation=FALSE,
  figures_base_title="schwa exclu"
)

#####################
# A vous de jouer.
# Qu'observe-t-on si on exlut également la voyelle mi-fermée antérieure arrondie (étiquetée @) ?
# N'oublions pas qu'on s'est limité ici à des calculs de distance dans l'espace F1/F2 en négligeant F3. Que peut-on dire en se limitant à un sous-ensemble de voyelles pour lesquelles il n'y a pas d'opposition d'arrondissement en français ?
# Qu'en est-il des différences entre locuteurs ?
# Observe-t-on des différences en fonction de la fréquence lexicale ? On pourrait par exemple s'attendre à ce que les voyelles produites dans les mots rares soient plus hyperarticulées.
#####################

#####################
# Pour les plus rapides : exploration interactive de nuages de points
# Ouvrez le script app.R dans le dossier interactive_scatterplot_explorer_v0.8
# Il s'agit d'une application qui utilise le package shiny, que vous pouvez lancer dans RStudio en cliquant sur "Run App" (même emplacement que "Source" dans le cas d'un script classique).
# Après avoir chargé un fichier de données, sélectionnez deux variables X et Y, et le cas échéant une variables indépendante et/ou une variable de filtrage.
# L'application vous permet non seulement de visualiser des nuages de points, mais aussi de sélectionner une zone du graphique pour visualiser dans le jeu de données à quoi correspondent les points sélectionnés.
#
# Avertissement : cette application est encore en cours de développement et n'est pas totalement exempte de bugs, en particulier dans le cas de la manipulation de jeux de données volumineux. Il peut arriver dans certains cas que l'application plante ou que certaines commandes soient "gelées".
