#####################################################################################################################
# extract_acoustic_parameters_from_selected_labels_v9.praat
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
# This version of the script assumes that a Strings object with the list of TextGrid files to be processed is selected.
# It is typically called by either extract_acoustic_parameters_from_selected_labels_v9_regex.praat or extract_acoustic_parameters_from_selected_labels_v9_fileslist.praat.
#
# Author: Nicolas Audibert, LPP UMR7018, January 2011 - last modified December 2017
#####################################################################################################################

form Extract_acoustic_parameters
	comment Folder with textgrids (all textgrids must have the same structure)
	text textgrids_folder stimuli_concatenes
	comment Folder with sounds (leave empty if same as textgrids folder or to extract only duration and context)
	text wavefiles_folder
	comment Output file
	text results_file resultats_analyse_acoustique.txt
	comment Index of the tier with labels to be processed
	positive reference_tier 2
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
	text extraction_points_definition_file positions_11points.txt
	positive minF0 75
	positive maxF0 600
	# comment Speakers gender (used to parameterize formants extraction)
	optionmenu speakers_gender: 1
	option M
	option F
	positive nDetectedFormants 5
	comment Text file that contains the labels to be processed (leave empty to process all non-empty labels)
	text dictionary_file voyelles_aiu.txt
	positive offset_for_acoustic_parameters_extraction_milliseconds 50
	natural target_channel 1
endform

# Clear info window
clearinfo

# Get the list of textgrids (selected Strings object)
flist = selected("Strings")
ntextgrids = Get number of strings

# Check parameters values
if wavefiles_folder$ = ""
	wavefiles_folder$ = textgrids_folder$
endif
if dictionary_file$ = ""
	filter_labels = 0
else
	filter_labels = 1
	# Get list of segments to be extracted from reference tier
	stringsDictionary = Read Strings from raw text file: dictionary_file$
	dictionarySize = Get number of strings
endif
# Get the names and relative position of the points in a Matrix object
extracted_points_relative_times = Read Matrix from raw text file: extraction_points_definition_file$
n_extracted_points = Get number of rows

# Write the results file header
#fileappend 'results_file$' textgrid_file'tab$'label'tab$'previousLabel'tab$'followingLabel'tab$'start'tab$'end'tab$'duration(s)'tab$'mean_f0(Hz)'tab$'f0_point1(Hz)'tab$'f0_point2(Hz)'tab$'f0_point3(Hz)'newline$'
writeFile: results_file$, "textgrid_file", tab$, "label", tab$, "start_time", tab$,"end_time", tab$, "duration(s)"
if extract_left_and_right_context
	appendFile: results_file$, tab$, "previousLabel", tab$, "followingLabel"
endif
if extract_F0
	appendFile: results_file$, tab$, "mean_F0(Hz)"
	for ipoint from 1 to n_extracted_points
		selectObject: extracted_points_relative_times
		current_point_relative_postition = Get value in cell: ipoint, 1
		appendFile: results_file$, tab$, "F0_pt"+fixed$(ipoint,0)+"_"+fixed$(round(100*current_point_relative_postition),0)+"%(Hz)"
	endfor
	if get_median
		appendFile: results_file$, tab$, "median_F0(Hz)"
	endif
	if get_standard_deviation
		appendFile: results_file$, tab$, "std_dev_F0(Hz)"
	endif
	if get_min_max_with_time
		appendFile: results_file$, tab$, "min_F0(Hz)", tab$, "min_F0_relative_time", tab$, "max_F0(Hz)", tab$, "max_F0_relative_time"
	endif
endif
if extract_intensity
	appendFile: results_file$, tab$, "mean_intensity(dB)"
	for ipoint from 1 to n_extracted_points
		selectObject: extracted_points_relative_times
		current_point_relative_postition = Get value in cell: ipoint, 1
		appendFile: results_file$, tab$, "intensity_pt"+fixed$(ipoint,0)+"_"+fixed$(round(100*current_point_relative_postition),0)+"%(dB)"
	endfor
	if get_median
		appendFile: results_file$, tab$, "median_intensity(dB)"
	endif
	if get_standard_deviation
		appendFile: results_file$, tab$, "std_dev_intensity(dB)"
	endif
	if get_min_max_with_time
		appendFile: results_file$, tab$, "min_intensity(dB)", tab$, "min_intensity_relative_time", tab$, "max_intensity(dB)", tab$, "max_intensity_relative_time"
	endif
endif
if extract_formants
	appendFile: results_file$, tab$, "mean_F1(Hz)"
	for ipoint from 1 to n_extracted_points
		selectObject: extracted_points_relative_times
		current_point_relative_postition = Get value in cell: ipoint, 1
		appendFile: results_file$, tab$, "F1_pt"+fixed$(ipoint,0)+"_"+fixed$(round(100*current_point_relative_postition),0)+"%(Hz)"
	endfor
	if get_median
		appendFile: results_file$, tab$, "median_F1(Hz)"
	endif
	if get_standard_deviation
		appendFile: results_file$, tab$, "std_dev_F1(Hz)"
	endif
	if get_min_max_with_time
		appendFile: results_file$, tab$, "min_F1(Hz)", tab$, "min_F1_relative_time", tab$, "max_F1(Hz)", tab$, "max_F1_relative_time"
	endif
	appendFile: results_file$, tab$, "mean_F2(Hz)"
	for ipoint from 1 to n_extracted_points
		selectObject: extracted_points_relative_times
		current_point_relative_postition = Get value in cell: ipoint, 1
		appendFile: results_file$, tab$, "F2_pt"+fixed$(ipoint,0)+"_"+fixed$(round(100*current_point_relative_postition),0)+"%(Hz)"
	endfor
	if get_median
		appendFile: results_file$, tab$, "median_F2(Hz)"
	endif
	if get_standard_deviation
		appendFile: results_file$, tab$, "std_dev_F2(Hz)"
	endif
	if get_min_max_with_time
		appendFile: results_file$, tab$, "min_F2(Hz)", tab$, "min_F2_relative_time", tab$, "max_F2(Hz)", tab$, "max_F2_relative_time"
	endif
	appendFile: results_file$, tab$, "mean_F3(Hz)"
	for ipoint from 1 to n_extracted_points
		selectObject: extracted_points_relative_times
		current_point_relative_postition = Get value in cell: ipoint, 1
		appendFile: results_file$, tab$, "F3_pt"+fixed$(ipoint,0)+"_"+fixed$(round(100*current_point_relative_postition),0)+"%(Hz)"
	endfor
	if get_median
		appendFile: results_file$, tab$, "median_F3(Hz)"
	endif
	if get_standard_deviation
		appendFile: results_file$, tab$, "std_dev_F3(Hz)"
	endif
	if get_min_max_with_time
		appendFile: results_file$, tab$, "min_F3(Hz)", tab$, "min_F3_relative_time", tab$, "max_F3(Hz)", tab$, "max_F3_relative_time"
	endif
	appendFile: results_file$, tab$, "mean_F4(Hz)"
	for ipoint from 1 to n_extracted_points
		selectObject: extracted_points_relative_times
		current_point_relative_postition = Get value in cell: ipoint, 1
		appendFile: results_file$, tab$, "F4_pt"+fixed$(ipoint,0)+"_"+fixed$(round(100*current_point_relative_postition),0)+"%(Hz)"
	endfor
	if get_median
		appendFile: results_file$, tab$, "median_F4(Hz)"
	endif
	if get_standard_deviation
		appendFile: results_file$, tab$, "std_dev_F4(Hz)"
	endif
	if get_min_max_with_time
		appendFile: results_file$, tab$, "min_F4(Hz)", tab$, "min_F4_relative_time", tab$, "max_F4(Hz)", tab$, "max_F4_relative_time"
	endif
endif

# The rest of the results file header will be written only when processing the first textgrid
header_written = 0
# Init ntiers to 0 before actual number of tiers is known
ntiers = 0

# fileappend "'results_file$'" 'newline$'

# Loop every selected textgrid
for itextgrid to ntextgrids
	# Get its name, display it in 'info' windows and read it
	selectObject: flist
	tg$ = Get string: itextgrid
	appendInfoLine: "Processing file ", tg$, "..."
	current_tg = Read from file: "'textgrids_folder$'/'tg$'"

	if header_written = 0
		# Finish writing results file header on the first loop increment
		selectObject: current_tg
		ntiers = Get number of tiers
		if secondary_tier>0
			# Get the name of the selected secondary tier
			selectObject: current_tg
			tiername$ = Get tier name: secondary_tier
			appendFile: results_file$, tab$, tiername$
			if extract_left_and_right_context
				appendFile: results_file$, tab$, "previous_'tiername$'", tab$, "next_'tiername$'"
			endif
		elsif secondary_tier = -1
			# Get the names of all interval tiers
			for itier from 1 to ntiers
				# Ignore it if it's the reference tier (already processed) or a point tier (no labels to extract)
				selectObject: current_tg
				interv_tier = Is interval tier: itier
				if itier<>reference_tier and interv_tier=1
					# Get tier name and write it to results file
					selectObject: current_tg
					tiername$ = Get tier name: itier
					appendFile: results_file$, tab$, tiername$
					if extract_left_and_right_context
						appendFile: results_file$, tab$, "previous_'tiername$'", tab$, "next_'tiername$'"
					endif
				endif
			endfor
		endif
		# Append a linebreak to results file to finish writing the header
		appendFile: results_file$, newline$
		header_written = 1
	endif

	# Read corresponding sound if at least one type of acoustic analysis is selected
	if extract_F0+extract_intensity+extract_formants>0
		snd$ = tg$ - ".TextGrid" + ".wav"
		current_snd = Open long sound file: "'wavefiles_folder$'/'snd$'"
		current_snd_total_duration = Get total duration
	endif

	# Extract info from every non-empty interval
	selectObject: current_tg
	ninterv = Get number of intervals: reference_tier
	# Loop every interval on reference tier
	for iinterv from 1 to ninterv
		selectObject: current_tg
		label$ = Get label of interval: reference_tier, iinterv
		# Do something only if the interval label is not empty and matches the set of symbols to be processed (if defined)
		if length(label$)>0
			# Check if the current label is included in the dictionary
			foundString = 0
			if filter_labels
				if dictionarySize > 0
					currentStringIndex = 1
					while foundString = 0 and currentStringIndex <= dictionarySize
						selectObject: stringsDictionary
						currentString$ = Get string: currentStringIndex
						if label$ = currentString$
							foundString = 1
						endif
						currentStringIndex = currentStringIndex + 1
					endwhile
				endif
			endif
			# If filtering is on, extract values only if the current phoneme is included
			if filter_labels = 0 or foundString = 1
				selectObject: current_tg
				#  Extract phonemic context
				if extract_left_and_right_context
					if iinterv>1
						previousLabel$ = Get label of interval: reference_tier, iinterv-1
					else
						previousLabel$ = "--undefined--"
					endif
					if iinterv<ninterv
						followingLabel$ = Get label of interval: reference_tier, iinterv+1
					else
						followingLabel$ = "--undefined--"
					endif
				endif
				# Extract start and end times, and calculate segment duration
				start_time = Get start point: reference_tier, iinterv
				end_time = Get end point: reference_tier, iinterv
				duration = end_time-start_time

				# Get the signal extract as a Sound object, and compute acoustic parameters
				if extract_F0+extract_intensity+extract_formants>0
					# Get the start and end time of the signal extract ( Sound object including offset before and after the target interval)
					extract_start_time = start_time - offset_for_acoustic_parameters_extraction_milliseconds/1000
					extract_end_time = end_time + offset_for_acoustic_parameters_extraction_milliseconds/1000
					# Check that the extract start and end times are not off limits
					if extract_start_time < 0
						extract_start_time = 0
					endif
					if extract_end_time > current_snd_total_duration
						extract_end_time = current_snd_total_duration
					endif
					selectObject: current_snd
					current_snd_extract = Extract part: extract_start_time, extract_end_time, "yes"
					nChannels = Get number of channels
					if nChannels > 1
						current_snd_extract_tmp = current_snd_extract
						current_snd_extract = Extract one channel: target_channel
						removeObject: current_snd_extract_tmp
					endif

					# Get F0, intensity and formants values of the extract if requested
					# Store values extracted for each target point in TableOfReal objects
					if extract_F0
						selectObject: current_snd_extract
						current_pitch = To Pitch: 0, minF0, maxF0
						f0_values_extracted_points = Create TableOfReal: "f0_values", n_extracted_points, 1
						for ipoint from 1 to n_extracted_points
							selectObject: extracted_points_relative_times
							current_point_relative_position = Get value in cell: ipoint, 1
							current_point_time = start_time + (current_point_relative_position * duration)
							selectObject: current_pitch
							current_value = Get value at time: current_point_time, "Hertz", "Linear"
							selectObject: f0_values_extracted_points
							Set value: ipoint, 1, current_value
						endfor
						selectObject: current_pitch
						mean_f0 = Get mean: start_time, end_time, "Hertz"
						if get_median
							median_f0 = Get quantile: start_time, end_time, 0.5, "Hertz"
						endif
						if get_standard_deviation
							std_f0 = Get standard deviation: start_time, end_time, "Hertz"
						endif
						if get_min_max_with_time
							min_f0 = Get minimum: start_time, end_time, "Hertz", "Parabolic"
							min_f0_relative_time = Get time of minimum: start_time, end_time, "Hertz", "Parabolic"
							min_f0_relative_time = (min_f0_relative_time - start_time) / duration
							max_f0 = Get maximum: start_time, end_time, "Hertz", "Parabolic"
							max_f0_relative_time = Get time of maximum: start_time, end_time, "Hertz", "Parabolic"
							max_f0_relative_time = (max_f0_relative_time - start_time) / duration
						endif
						removeObject: current_pitch
					endif
					if extract_intensity
						selectObject: current_snd_extract
						current_intensity = To Intensity: 70, 0, "no"
						intensity_values_extracted_points = Create TableOfReal: "intensity_values", n_extracted_points, 1
						for ipoint from 1 to n_extracted_points
							selectObject: extracted_points_relative_times
							current_point_relative_position = Get value in cell: ipoint, 1
							current_point_time = start_time + (current_point_relative_position * duration)
							selectObject: current_intensity
							current_value = Get value at time: current_point_time, "Cubic"
							selectObject: intensity_values_extracted_points
							Set value: ipoint, 1, current_value
						endfor
						selectObject: current_intensity
						mean_intensity = Get mean: start_time, end_time, "dB"
						if get_median
							median_intensity = Get quantile: start_time, end_time, 0.5
						endif
						if get_standard_deviation
							std_intensity = Get standard deviation: start_time, end_time
						endif
						if get_min_max_with_time
							min_intensity = Get minimum: start_time, end_time, "Cubic"
							min_intensity_relative_time = Get time of minimum: start_time, end_time, "Cubic"
							min_intensity_relative_time = (min_intensity_relative_time - start_time) / duration
							max_intensity = Get maximum: start_time, end_time, "Cubic"
							max_intensity_relative_time = Get time of maximum: start_time, end_time, "Cubic"
							max_intensity_relative_time = (max_intensity_relative_time - start_time) / duration
						endif
						removeObject: current_intensity
					endif
					if extract_formants
						selectObject: current_snd_extract
						if (speakers_gender$ = "M")
							current_formant = To Formant (burg): 0, 5, 5000, 0.025, 50
						else
							current_formant = To Formant (burg): 0, 5, 5500, 0.025, 50
						endif
						f1_values_extracted_points = Create TableOfReal: "f1_values", n_extracted_points, 1
						for ipoint from 1 to n_extracted_points
							selectObject: extracted_points_relative_times
							current_point_relative_position = Get value in cell: ipoint, 1
							current_point_time = start_time + (current_point_relative_position * duration)
							selectObject: current_formant
							current_value = Get value at time: 1, current_point_time, "Hertz", "Linear"
							selectObject: f1_values_extracted_points
							Set value: ipoint, 1, current_value
						endfor
						selectObject: current_formant
						mean_f1 = Get mean: 1, start_time, end_time, "Hertz"
						if get_median
							median_f1 = Get quantile: 1, start_time, end_time, "hertz", 0.5
						endif
						if get_standard_deviation
							std_f1 = Get standard deviation: 1, start_time, end_time, "Hertz"
						endif
						if get_min_max_with_time
							min_f1 = Get minimum: 1, start_time, end_time, "Hertz", "Parabolic"
							min_f1_relative_time = Get time of minimum: 1, start_time, end_time, "Hertz", "Parabolic"
							min_f1_relative_time = (min_f1_relative_time - start_time) / duration
							max_f1 = Get maximum: 1, start_time, end_time, "Hertz", "Parabolic"
							max_f1_relative_time = Get time of maximum: 1, start_time, end_time, "Hertz", "Parabolic"
							max_f1_relative_time = (max_f1_relative_time - start_time) / duration
						endif

						f2_values_extracted_points = Create TableOfReal: "f2_values", n_extracted_points, 1
						for ipoint from 1 to n_extracted_points
							selectObject: extracted_points_relative_times
							current_point_relative_position = Get value in cell: ipoint, 1
							current_point_time = start_time + (current_point_relative_position * duration)
							selectObject: current_formant
							current_value = Get value at time: 2, current_point_time, "Hertz", "Linear"
							selectObject: f2_values_extracted_points
							Set value: ipoint, 1, current_value
						endfor
						selectObject: current_formant
						mean_f2 = Get mean: 2, start_time, end_time, "Hertz"
						if get_median
							median_f2 = Get quantile: 2, start_time, end_time, "hertz", 0.5
						endif
						if get_standard_deviation
							std_f2 = Get standard deviation: 2, start_time, end_time, "Hertz"
						endif
						if get_min_max_with_time
							min_f2 = Get minimum: 2, start_time, end_time, "Hertz", "Parabolic"
							min_f2_relative_time = Get time of minimum: 2, start_time, end_time, "Hertz", "Parabolic"
							min_f2_relative_time = (min_f2_relative_time - start_time) / duration
							max_f2 = Get maximum: 2, start_time, end_time, "Hertz", "Parabolic"
							max_f2_relative_time = Get time of maximum: 2, start_time, end_time, "Hertz", "Parabolic"
							max_f2_relative_time = (max_f2_relative_time - start_time) / duration
						endif

						f3_values_extracted_points = Create TableOfReal: "f3_values", n_extracted_points, 1
						for ipoint from 1 to n_extracted_points
							selectObject: extracted_points_relative_times
							current_point_relative_position = Get value in cell: ipoint, 1
							current_point_time = start_time + (current_point_relative_position * duration)
							selectObject: current_formant
							current_value = Get value at time: 3, current_point_time, "Hertz", "Linear"
							selectObject: f3_values_extracted_points
							Set value: ipoint, 1, current_value
						endfor
						selectObject: current_formant
						mean_f3 = Get mean: 3, start_time, end_time, "Hertz"
						if get_median
							median_f3 = Get quantile: 3, start_time, end_time, "hertz", 0.5
						endif
						if get_standard_deviation
							std_f3 = Get standard deviation: 3, start_time, end_time, "Hertz"
						endif
						if get_min_max_with_time
							min_f3 = Get minimum: 3, start_time, end_time, "Hertz", "Parabolic"
							min_f3_relative_time = Get time of minimum: 3, start_time, end_time, "Hertz", "Parabolic"
							min_f3_relative_time = (min_f3_relative_time - start_time) / duration
							max_f3 = Get maximum: 3, start_time, end_time, "Hertz", "Parabolic"
							max_f3_relative_time = Get time of maximum: 3, start_time, end_time, "Hertz", "Parabolic"
							max_f3_relative_time = (max_f3_relative_time - start_time) / duration
						endif

						f4_values_extracted_points = Create TableOfReal: "f4_values", n_extracted_points, 1
						for ipoint from 1 to n_extracted_points
							selectObject: extracted_points_relative_times
							current_point_relative_position = Get value in cell: ipoint, 1
							current_point_time = start_time + (current_point_relative_position * duration)
							selectObject: current_formant
							current_value = Get value at time: 4, current_point_time, "Hertz", "Linear"
							selectObject: f4_values_extracted_points
							Set value: ipoint, 1, current_value
						endfor
						selectObject: current_formant
						mean_f4 = Get mean: 4, start_time, end_time, "Hertz"
						if get_median
							median_f4 = Get quantile: 4, start_time, end_time, "hertz", 0.5
						endif
						if get_standard_deviation
							std_f4 = Get standard deviation: 4, start_time, end_time, "Hertz"
						endif
						if get_min_max_with_time
							min_f4 = Get minimum: 4, start_time, end_time, "Hertz", "Parabolic"
							min_f4_relative_time = Get time of minimum: 4, start_time, end_time, "Hertz", "Parabolic"
							min_f4_relative_time = (min_f4_relative_time - start_time) / duration
							max_f4 = Get maximum: 4, start_time, end_time, "Hertz", "Parabolic"
							max_f4_relative_time = Get time of maximum: 4, start_time, end_time, "Hertz", "Parabolic"
							max_f4_relative_time = (max_f4_relative_time - start_time) / duration
						endif

						removeObject: current_formant
					endif
					removeObject: current_snd_extract
				endif

				# Write information to results file
				appendFile: results_file$, tg$, tab$, label$, tab$, start_time, tab$, end_time, tab$, duration
				if extract_left_and_right_context
					appendFile: results_file$, tab$, previousLabel$, tab$, followingLabel$
				endif
				# F0
				if extract_F0
					appendFile: results_file$, tab$, mean_f0
					selectObject: f0_values_extracted_points
					for ipoint from 1 to n_extracted_points
						current_point_value = Get value: ipoint, 1
						appendFile: results_file$, tab$, current_point_value
					endfor
					if get_median
						appendFile: results_file$, tab$, median_f0
					endif
					if get_standard_deviation
						appendFile: results_file$, tab$, std_f0
					endif
					if get_min_max_with_time
						appendFile: results_file$, tab$, min_f0, tab$, min_f0_relative_time, tab$, max_f0, tab$, max_f0_relative_time
					endif
				endif
				# intensity
				if extract_intensity
					appendFile: results_file$, tab$, mean_intensity
					selectObject: intensity_values_extracted_points
					for ipoint from 1 to n_extracted_points
						current_point_value = Get value: ipoint, 1
						appendFile: results_file$, tab$, current_point_value
					endfor
					if get_median
						appendFile: results_file$, tab$, median_intensity
					endif
					if get_standard_deviation
						appendFile: results_file$, tab$, std_intensity
					endif
					if get_min_max_with_time
						appendFile: results_file$, tab$, min_intensity, tab$, min_intensity_relative_time, tab$, max_intensity, tab$, max_intensity_relative_time
					endif
				endif
				# formants
				if extract_formants
					appendFile: results_file$, tab$, mean_f1
					selectObject: f1_values_extracted_points
					for ipoint from 1 to n_extracted_points
						current_point_value = Get value: ipoint, 1
						appendFile: results_file$, tab$, current_point_value
					endfor
					if get_median
						appendFile: results_file$, tab$, median_f1
					endif
					if get_standard_deviation
						appendFile: results_file$, tab$, std_f1
					endif
					if get_min_max_with_time
						appendFile: results_file$, tab$, min_f1, tab$, min_f1_relative_time, tab$, max_f1, tab$, max_f1_relative_time
					endif
					appendFile: results_file$, tab$, mean_f2
					selectObject: f2_values_extracted_points
					for ipoint from 1 to n_extracted_points
						current_point_value = Get value: ipoint, 1
						appendFile: results_file$, tab$, current_point_value
					endfor
					if get_median
						appendFile: results_file$, tab$, median_f2
					endif
					if get_standard_deviation
						appendFile: results_file$, tab$, std_f2
					endif
					if get_min_max_with_time
						appendFile: results_file$, tab$, min_f2, tab$, min_f2_relative_time, tab$, max_f2, tab$, max_f2_relative_time
					endif
					appendFile: results_file$, tab$, mean_f3
					selectObject: f3_values_extracted_points
					for ipoint from 1 to n_extracted_points
						current_point_value = Get value: ipoint, 1
						appendFile: results_file$, tab$, current_point_value
					endfor
					if get_median
						appendFile: results_file$, tab$, median_f3
					endif
					if get_standard_deviation
						appendFile: results_file$, tab$, std_f3
					endif
					if get_min_max_with_time
						appendFile: results_file$, tab$, min_f3, tab$, min_f3_relative_time, tab$, max_f3, tab$, max_f3_relative_time
					endif
					appendFile: results_file$, tab$, mean_f4
					selectObject: f4_values_extracted_points
					for ipoint from 1 to n_extracted_points
						current_point_value = Get value: ipoint, 1
						appendFile: results_file$, tab$, current_point_value
					endfor
					if get_median
						appendFile: results_file$, tab$, median_f4
					endif
					if get_standard_deviation
						appendFile: results_file$, tab$, std_f4
					endif
					if get_min_max_with_time
						appendFile: results_file$, tab$, min_f4, tab$, min_f4_relative_time, tab$, max_f4, tab$, max_f4_relative_time
					endif
				endif
				# Clean-up: remove temporary storage of values extracted on each point
				if extract_F0
					removeObject: f0_values_extracted_points
				endif
				if extract_intensity
					removeObject: intensity_values_extracted_points
				endif
				if extract_formants
					removeObject: f1_values_extracted_points, f2_values_extracted_points, f3_values_extracted_points, f4_values_extracted_points
				endif

				# Extract labels from other tiers and append information to the results file
				# Get interval midpoint (used as reference to extract information from other tiers)
				mid_point = start_time + duration/2
				if secondary_tier>0
					# Get the corresponding label on the selected secondary tier
					selectObject: current_tg
					intervtmp = Get interval at time: itier, mid_point
					secondaryTierlabel$ = Get label of interval: itier, intervtmp
					appendFile: results_file$, tab$, secondaryTierlabel$
					if extract_left_and_right_context
						if intervtmp-1 > 0
							previousLabelSecondaryTier$ = Get label of interval: itier, intervtmp-1
						else
							previousLabelSecondaryTier$ = "--undefined--"
						endif
						nIntervalsSecondaryTier = Get number of intervals: itier
						if intervtmp+1 <= nIntervalsSecondaryTier
							followingLabelSecondaryTier$ = Get label of interval: itier, intervtmp+1
						else
							followingLabelSecondaryTier$ = "--undefined--"
						endif
						appendFile: results_file$, tab$, previousLabelSecondaryTier$, tab$, followingLabelSecondaryTier$
					endif
				elsif secondary_tier = -1
					# Get the corresponding labels on all interval tiers
					# Loop every tier
					for itier from 1 to ntiers
						# Ignore it if it's the reference tier (already processed) or a point tier (no labels to extract)
						selectObject: current_tg
						interv_tier = Is interval tier: itier
						if itier<>reference_tier and interv_tier=1
							selectObject: current_tg
							# Get label at reference tier's current interval midpoint and append it to results file
							intervtmp = Get interval at time: itier, mid_point
							secondaryTierlabel$ = Get label of interval: itier, intervtmp
							appendFile: results_file$, tab$, secondaryTierlabel$
							if extract_left_and_right_context
								if intervtmp-1 > 0
									previousLabelSecondaryTier$ = Get label of interval: itier, intervtmp-1
								else
									previousLabelSecondaryTier$ = "--undefined--"
								endif
								nIntervalsSecondaryTier = Get number of intervals: itier
								if intervtmp+1 <= nIntervalsSecondaryTier
									followingLabelSecondaryTier$ = Get label of interval: itier, intervtmp+1
								else
									followingLabelSecondaryTier$ = "--undefined--"
								endif
								appendFile: results_file$, tab$, previousLabelSecondaryTier$, tab$, followingLabelSecondaryTier$
							endif
						endif
					endfor
				endif

				# Append a line break to the results file before proceeding to the next interval
				appendFile: results_file$, newline$
			endif
		endif
	endfor
	# Clean-up: remove current textgrid, pitch, intensity, formant and sound objects
	removeObject: current_tg
	if extract_F0+extract_intensity+extract_formants>0
		removeObject: current_snd
	endif
endfor

appendInfoLine: newline$, "Processed ", ntextgrids, " files."

# Clean-up: remove lists of textgrids and vowels
removeObject: flist, extracted_points_relative_times
if filter_labels = 1
	removeObject: stringsDictionary
endif
