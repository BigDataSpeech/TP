# Ecole d'été Big Data & Speech, Roscoff, Juillet 2018
# TP paramètres acoustiques
# Nicolas Audibert et Cédric Gendrot
# Partie 3 : quelques statistiques sur les durées vocaliques
#############################################################

# Commençons par comparer la distribution des durées vocaliques entre les deux corpus
# Pour cela, nous allons utiliser le package ggplot2 (très utile pour les représentations graphiques) pour afficher les deux distributions de façon superposée
library(ggplot2)
variable_dependante = "dureeMs"
variable_independante = "corpus"
niveau_transparence = 0.25
# On utilise la fonction aes_string à la place de aes car cela permet d'éviter de spécifier "en dur" les variables dépendante et indépendante
fig = ggplot(dataset, aes_string(x=variable_dependante, fill=variable_independante)) + 
  geom_density(alpha=niveau_transparence)
# Il ne reste plus qu'à afficher la figure
print(fig)

# On observe une forme en "dos de crocodile" due au fait que la résolution temporelle de l'alignement forcé est de 10ms
# Dans ce cas de figure, des histogrammes empilés avec des barres représentant chacune 10ms peuvent être plus adaptées
fig2 = ggplot(dataset, aes_string(x=variable_dependante, fill=variable_independante, y = "..density..", colour=variable_independante)) + 
  geom_histogram(alpha=niveau_transparence, binwidth = 10, position = "identity")
print(fig2)
# Comme les deux groupes comparés (ici les corpus) ne comptent pas le même nombre de voyelles, on utilise y = "..density.." pour afficher la densité en y plutôt que le nombre de valeurs, et position="identity" pour normaliser au sein de chacun des deux groupes et pouvoir faire une comparaison directe

# Inconvénient : comme il y a quelques voyelles très longues, on ne voit pas grand-chose
# Nous allons donc "zoomer" sur les durées inférieures ou égales à 250 ms
fig2 = fig2 +
  coord_cartesian(xlim = c(0,250))
# La fonction c correspond à l'opérateur de concaténation, utilisé ici pour construire un vecteur de 2 valeurs
print(fig2)
# On remarque que la proportion de voyelles considérées comme "extra-courtes" (30 ms) par l'alignement est plus importante dans NCCFr que dans ESTER, ce qui peut s'expliquer par la différence de style de parole

# Si on le souhaite, on peut aussi exporter la figure dans un fichier (le format d'export est défini par l'extension)
fichier_export_figure = "comparaison_distributions_duree_voyelles_ESTER_NCCFr.pdf"
ggsave(filename = fichier_export_figure, plot = fig2)

############################

# Que faire si on souhaite obtenir une quantification et pas uniquement une illustration ?
# Dans R, pour obtenir très facilement des tableaux croisés à 2 entrée, on peut utiliser la fonction table
table(dataset$voyelleSup30ms, dataset$corpus)
# Pour obtenir des proportions plutôt que des décomptes, il suffit d'utiliser la fonction prop.table (ici l'argument margin=1 indique que la somme de chaque ligne correspond à 100%)
prop.table(table(dataset$voyelleSup30ms, dataset$corpus), margin = 1)

###########################

# Dans chacun des deux corpus, quelles sont les catégories vocaliques pour lesquelles la proportion de voyelles extra-courtes est la plus importante ?
datasetESTER = dataset[dataset$corpus=="ESTER",]
prop.table(table(datasetESTER$voyelleSup30ms, datasetESTER$voyelle), margin = 1)
datasetNCCFr = dataset[dataset$corpus=="NCCFr",]
prop.table(table(datasetNCCFr$voyelleSup30ms, datasetNCCFr$voyelle), margin = 1)

###########################

# Voyons maintenant le cas particuler du mot "avec" dans lequel on observe fréquemment une réduction de l'une des deux voyelles.
# On peut donc supposer que la proportion de voyelles extra-courtes sera plus importante dans les occurrences de "avec" que dans le reste du corpus.
# Qu'en est-il dans chacun des deux corpus dont nous disposons ? Cela est-il plus vrai en parole conversationnelle qu'en parole journalistique ? Laquelle des deux voyelles est la plus impactée ? Est-ce comparable entre les deux corpus ?

# On commence par sélectionner les occurences de "avec"
datasetAvec = dataset[dataset$mot=="avec",]
# Et on refait un tableau croisé sur le sous-ensemble sélectionné
table(datasetAvec$voyelleSup30ms, datasetAvec$corpus)
prop.table(table(datasetAvec$voyelleSup30ms, datasetAvec$corpus), margin = 1)
# Pour comparer entre /a/ et /E/ au sein de chaque corpus
datasetAvecESTER = datasetAvec[datasetAvec$corpus=="ESTER",]
prop.table(table(datasetAvecESTER$voyelleSup30ms, as.character(datasetAvecESTER$voyelle)), margin = 1)
datasetAvecNCCFr = datasetAvec[datasetAvec$corpus=="NCCFr",]
prop.table(table(datasetAvecNCCFr$voyelleSup30ms, as.character(datasetAvecNCCFr$voyelle)), margin = 1)
# Remarque : on applique ici la fonction as.character pour convertir la variable voyelle avant de générer le tableau croisé, car le type factor inclut toutes les modalités initialement présentes, même si certaines ne sont pas représentées dans le sous-ensemble sélectionné
# Si on ne le faisait pas, on obtiendrait un tableau avec de nombreuses colonnes à 0%
# Illustration sur le cas du corpus ESTER :
prop.table(table(datasetAvecESTER$voyelleSup30ms, datasetAvecESTER$voyelle), margin = 1)

############################

# En plus de questions liées à la durée, on peut aussi observer quels sont les contextes les plus fréquents
table(dataset$contexteGD_lieu)
# On remarque que certains contextes gauche et/ou droit ne sont pas définis (effet de bord de la préparation un peu trop hâtive du jeu de données).
# Heureusement ces cas (qui concernent uniquement le corpus NCCFr) restent minoritaires, on peut raisonnablement supposer que l'impact sur les tendances générales sera faible.

# Comme le nombre de combinaisons différentes entre contexte gauche et droit est important, le résultat n'est pas très lisible.
# Pour voir quels sont les contextes les plus fréquents, on peut trier la table de fréquences du plus grand effectif au plus faible.
sort(table(dataset$contexteGD_lieu), decreasing = T)

# Autre possibilité (qui va nous permettre de combiner 2 critères) : convertir la table de fréquences en objet data.frame
frequences_contextes = as.data.frame(table(dataset$contexteGD_lieu, dataset$corpus))
# Les noms de colonnes par défaut ne sont pas très explicites, rectifions cela
colnames(frequences_contextes) = c("contexteGD_lieu", "corpus", "Noccurences")
# On peut ensuite trier, filtrer, etc.
# Exemple : tri par corpus puis par nombre d'occurrences décroissant
frequences_contextes = frequences_contextes[order(frequences_contextes$corpus, -frequences_contextes$Noccurences),]
############################
# On garde une copie du jeu de données complet pour la suite
datasetFull = dataset
