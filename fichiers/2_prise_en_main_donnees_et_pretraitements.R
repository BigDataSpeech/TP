# Ecole d'été Big Data & Speech, Roscoff, Juillet 2018
# TP paramètres acoustiques
# Nicolas Audibert et Cédric Gendrot
# Partie 2 : prise en main du jeu de données dans R et prétraitements
#############################################################

# Nous allons maintenant utiliser un jeu de données correspondant à l'analyse acoustique des
# voyelles orales de 10 locuteurs du corpus ESTER, et de 10 locuteurs du corpus NCCFr
# (dans chacun des deux corpus, les 10 locuteurs les plus prolixes ont été sélectionnés).
# Cette analyse a été effectuée avec un autre script Praat que celui présenté à l'étape 1,
# mais nous allons y retrouver des informations similaires.
# Outre l'analyse acoustique proprement dite, les données ont été enrichies pour ajouter des
# informations sur la fréquence lexicale, ainsi qu'un codage des informations sur le contexte
# gauche et droit dans lequel les voyelles analysées sont produites.
#
# Les symboles utilisés pour représenter les voyelles orales analysées sont ceux du LIMSI.
# Dans la plupart des cas ce sont les mêmes que les symboles SAMPA, à quelques exception près :
# - c (LIMSI) <=> O (SAMPA)
# - x (LIMSI) <=> 9 (SAMPA)
# - @ (LIMSI) <=> 2 (SAMPA)
#
# Nous allons commencer par charger le corpus dans R, voir comment sélectionner des sous-ensembles
# en fonction de différents critères, et faire quelques prétraitements additionnels.
#####################################

# Lecture du fichier de données
fichier_voyelles_ESTER_NCCFr = "acoustique_voy_orales_20loc_ESTER_NCCFr_contexte_freqLex_distCentroide.txt"
dataset = read.table(file = fichier_voyelles_ESTER_NCCFr, sep="\t", header = T, fileEncoding = "UTF-8", quote= "", comment.char = "")
# La question ne se pose pas avec ce jeu de données, mais s'il y a des noms de colonnes avec des espaces ou des caractères spéciaux et qu'on souhaite les conserver au moment de l'importation, il faut ajouter l'argument check.names = FALSE (mais il faut en tenir compte ensuite si on utilise l'opérateur $)

# Pour savoir quelles sont les variables dont on dispose
colnames(dataset)
# ...combien il y en a
ncol(dataset)
# ...et le nombre d'observations
nrow(dataset)

# Pour accéder à une colonne en particulier, on peut utiliser l'opérateur $, par exemple
valeurs_duree = dataset$dureeMs
# Pour sélectionner un nombre variable de colonnes et/ou d'observations, l'opérateur [] est plus souple
# Syntaxe : dataset[indices_observations, indices_ou_noms_colonnes]
# Si on laisse vide l'un des deux, on garde l'ensemble
# Par exemple pour extraire durée et corpus en gardant toutes les lignes :
valeurs_duree_corpus = dataset[,c("dureeMs", "corpus")]
# Les indices des observations sélectionnées peuvent être obtenus à partir de conditions sur les valeurs prises par une ou plusieurs variables
# Par exemple pour ne garder que les occurrences de la voyelle /a/ dans le corpus ESTER :
a_ESTER = dataset[dataset$voyelle=="a" & dataset$corpus=="ESTER",]

##########################
# QUELQUES PRETRAITEMENTS
##########################

# Ajout de catégories de frequence lexicale pour chaque corpus, dans la variable classe_freq_lex
dataset$classe_freq_lex = ""
# Pour découper en 3 classes de même effectif pour le corpus ESTER, on commence par calculer les quantiles à 33% et 66%
quantileFreq33ESTER = quantile(dataset$frequence_lex[dataset$corpus=="ESTER"],.33)
quantileFreq66ESTER = quantile(dataset$frequence_lex[dataset$corpus=="ESTER"],.66)
# Puis on attribue à la variable classe_freq_lex des valeurs symboliques dépendant de la fréquence du mot dans le corpus
dataset$classe_freq_lex[dataset$corpus=="ESTER" & dataset$frequence_lex<=quantileFreq66ESTER] = "moyen"
dataset$classe_freq_lex[dataset$corpus=="ESTER" & dataset$frequence_lex<=quantileFreq33ESTER] = "rare"
dataset$classe_freq_lex[dataset$corpus=="ESTER" & dataset$frequence_lex>quantileFreq66ESTER] = "frequent"
# Idem pour NCCFr
quantileFreq33NCCFr = quantile(dataset$frequence_lex[dataset$corpus=="NCCFr"],.33)
quantileFreq66NCCFr = quantile(dataset$frequence_lex[dataset$corpus=="NCCFr"],.66)
dataset$classe_freq_lex[dataset$corpus=="NCCFr" & dataset$frequence_lex<=quantileFreq66NCCFr] = "moyen"
dataset$classe_freq_lex[dataset$corpus=="NCCFr" & dataset$frequence_lex<=quantileFreq33NCCFr] = "rare"
dataset$classe_freq_lex[dataset$corpus=="NCCFr" & dataset$frequence_lex>quantileFreq66NCCFr] = "frequent"
# Pour finir, on convertit au format factor la colonne qu'on vient d'ajouter, ce qui n'est pas indispensable pour tous les calculs mais permet dans certains cas de gagner en temps de traitement
dataset$classe_freq_lex = as.factor(dataset$classe_freq_lex)

# On fait la même chose pour la durée, pour les deux corpus confondus
dataset$classe_duree = ""
quantileDuree33 = quantile(dataset$dureeMs,.33)
quantileDuree66 = quantile(dataset$dureeMs,.66)
dataset$classe_duree[dataset$dureeMs<=quantileDuree66] = "moyenne"
dataset$classe_duree[dataset$dureeMs<=quantileDuree33] = "breve"
dataset$classe_duree[dataset$dureeMs>quantileDuree66] = "longue"
dataset$classe_duree = as.factor(dataset$classe_duree)
# Et on ajoute une colonne avec une valeur logique pour indiquer quelles sont les voyelles dont la durée attribuée par l'aligmement forcé est de plus de 30 ms (30 ms étant le minimum permis par le système, les voyelles de 30 ms sont susceptibles d'être des productions éloignées du modèle acoustique de la voyelle considérée, typiquement car on se trouve en présence d'une forme réduite du mot)
dataset$voyelleSup30ms = TRUE
dataset$voyelleSup30ms[dataset$dureeMs == 30] = FALSE

# Pour pouvoir explorer l'influence du contexte consonantique, on ajoute également une colonne pour indiquer à la fois le contexte gauche et droit (notamment en termes de lieu d'articulation, mais on peut le faire également pour le mode et le voisement)
# Pour obtenir cela, il suffit de concaténer l'information de deux colonnes dans une nouvelle colonne; ce n'est pas indispensable mais on peut insérer le caractère _ entre les deux pour une question de lisibilité
dataset$contexteGD_lieu = paste0(dataset$contexteG_lieu, "_", dataset$contexteD_lieu)
dataset$contexteGD_lieu = as.factor(dataset$contexteGD_lieu)
dataset$contexteGD_mode = paste0(dataset$contexteG_mode, "_", dataset$contexteD_mode)
dataset$contexteGD_mode = as.factor(dataset$contexteGD_mode)
dataset$contexteGD_voisement = paste0(dataset$contexteG_voisement, "_", dataset$contexteD_voisement)
dataset$contexteGD_voisement = as.factor(dataset$contexteGD_voisement)

# Pour finir, on peut exporter dans un fichier texte la version étendue (avec les nouvelles colonnes) du fichier de données
fichier_voyelles_ESTER_NCCFr_etendu = "acoustique_voy_orales_20loc_ESTER_NCCFr_contexte_freqLex_distCentroide_etendu.txt"
write.table(dataset, file = fichier_voyelles_ESTER_NCCFr_etendu, sep = "\t", row.names = F, quote = F)
