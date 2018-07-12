#####################################################################################################################
# extract_acoustic_parameters_from_selected_labels_v9_fileslist.praat
#
# This script extracts from a set of matched sound files and textgrid objects every label
# matching a set defined in a text file with their start and end time and duration. If no text file is specified,
# all non-empty intervals are processed.
# Aligned labels on other tiers can be optionally extracted (either one selected secondary tier or all other),
# as well as previous and next labels on each target tier.
# The following acoustic parameters can be extracted on request(averaged on the whole interval and on a
# variable number of user-defined points + min, max with time and standard deviation on request):
# - F0
# - Intensity
# - Formants 1 to 4
# The script assumes that matched textgrid and sound files have the same name, and that all textgrids
# have the same structure.
#
# This version of the script selects .TextGrid files listed in the input file.
#
# Author: Nicolas Audibert, LPP UMR7018, January 2011 - last modified December 2017
#####################################################################################################################

form Extract_acoustic_parameters
	comment Folder with textgrids (all textgrids must have the same structure)
	text textgrids_folder extraits_NCCFr
	comment Text file with the list of .TextGrid files to be processed
	sentence textgrid_files_list liste_fichiers_TextGrid_extraits_NCCFr.txt
	comment Folder with sounds (leave empty if same as textgrids folder or to extract only duration and context)
	text wavefiles_folder
	comment Output file
	text results_file resultats_analyse_acoustique.txt
	comment Index of the tier with labels to be processed
	positive reference_tier 1
	comment Index of the other interval tier from which labels should be extracted (0 = none, -1 = all interval tiers)
	integer secondary_tier -1
	boolean Extract_F0 1
	boolean Extract_intensity 1
	boolean Extract_formants 1
	boolean Extract_left_and_right_context 1
	boolean Get_median 1
	boolean Get_standard_deviation 1
	boolean Get_min_max_with_time 1
	comment File with relative positions of the target points for parameters extraction
	text extraction_points_definition_file positions_5points.txt
	positive minF0 75
	positive maxF0 600
	comment Speakers gender (used to parameterize formants extraction)
	optionmenu speakers_gender: 1
	option M
	option F
	positive nDetectedFormants 5
	comment Text file that contains the labels to be processed (leave empty to process all non-empty labels)
	text dictionary_file voyelles_orales_francais_LIMSI.txt
	positive offset_for_acoustic_parameters_extraction_milliseconds 50
	natural target_channel 1
endform

# Clear info window
clearinfo

# Read the list of textgrids from the specified file
flist = Read Strings from raw text file: textgrid_files_list$

# Call the main script
runScript: "extract_acoustic_parameters_from_selected_labels_v9.praat", textgrids_folder$, wavefiles_folder$, results_file$, reference_tier, secondary_tier, extract_F0, extract_intensity, extract_formants, extract_left_and_right_context, get_median, get_standard_deviation, get_min_max_with_time, extraction_points_definition_file$, minF0, maxF0, speakers_gender$, nDetectedFormants, dictionary_file$, offset_for_acoustic_parameters_extraction_milliseconds, target_channel
