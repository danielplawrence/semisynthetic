form 
	text source_segment /Users/pplsuser/semisynthetic/Original_A_token.wav
	text source_contour /Users/pplsuser/FAVE/FAVE-extract-york/contour.csv
	text preceding_segment /Users/pplsuser/semisynthetic/preceding_segment.wav
	text following_segment /Users/pplsuser/semisynthetic/following_segment.wav
endform


bandwidth_estimation$ = "Normal" 
#"Normal" or "Hawks & Miller 1995"
speaker_sex$ = "Male"
f0=200
minf=4
hf_rest=1
pitch_track=0
filter_cutoff=4000
filter_crossover=2000

Read from file: source_segment$
source_seg_duration=Get total duration
time_scaled=source_seg_duration/100
Rename... Original_A_token
source_segment$=selected$("Sound")
if pitch_track=1
call F0_extract 'source_segment$'
endif

Read from file: preceding_segment$
preceding_segment$=selected$("Sound")

Read from file: following_segment$
following_segment$=selected$("Sound")

###Set up polynomials for bandwidth prediction#####

	low_k=165.327516
	Create Polynomial: "low_x", 1, 5, "-0.673636734000000015 0.001808744460000000 -0.000004522016820000 0.000000007495140000 -0.000000000004702192  "
	high_k=15.8146139
	Create Polynomial: "high_x", 1, 5, "0.0810159009000000068790 -0.0000979728215000000004 0.0000000528725064000000 -0.0000000000107099264000 0.0000000000000007915285  "

##########################################


call HPfilter 'source_segment$' filter_cutoff filter_crossover
call LPfilter 'source_segment$' filter_cutoff filter_crossover

Read Table from comma-separated file: source_contour$
contour$=selected$("Table")
select Table 'contour$'
Down to TableOfReal: "1"
To Matrix
Rename... contour
@extractSource
call Contour Matrix_contour 'source_segment$' grid
call concatenate 0.07 
procedure Contour .matrix$ .source$ .name$
Create FormantGrid... grid 0 source_seg_duration 2 550 1100 60 50
	for f from 1 to 2
		Remove formant points between... 'f' 0 source_seg_duration
		Remove bandwidth points between... 'f' 0 source_seg_duration
	endfor
for f from 1 to 2
		for point from 1 to 100
			newval=Matrix_contour[point,f+2]
			time=time_scaled*point
			select FormantGrid grid
			if newval>0
				Add formant point... 'f' 'time' 'newval'
			endif
		endfor
call setBandWidths grid 'f'
	endfor
target_grid$=selected$("FormantGrid")
select FormantGrid 'target_grid$'
plus Sound '.source$'
Filter
Rename... '.name$'
Save as WAV file: "/Users/pplsuser/semisynthetic/synthesized_contour.wav"
###LP filter
call HPfilter '.name$' filter_cutoff filter_crossover
###Delete original
select Sound '.name$'
plus IntensityTier '.name$'_LF_portion_intensity
Remove
###Restore HF energy
call addHF '.name$'_LF_portion '.target$'_HP_portion
Rename... '.name$'
endproc

#########################################################
procedure extractSource
	select Sound 'source_segment$'
	Resample... 10000 50
	target_resamp$ = selected$("Sound")
	target_int= Get intensity (dB)
	To LPC (burg)... 16 0.025 0.005 50
	plus Sound 'target_resamp$'
	Filter (inverse)
	Resample... 48000 50
	Scale intensity... target_int
	source_seg_duration= Get total duration
	Rename... whitened_source
	whitened_source$ = selected$("Sound")
endproc

##Hann filtering
procedure HPfilter .target$ .cutoff .cross
	select Sound '.target$'
	Filter (pass Hann band)... 0 .cutoff .cross
	original_LF_intensity = Get intensity (dB)
	To Intensity... 100 0 yes
	Down to IntensityTier
	Rename... '.target$'_LF_portion_intensity
	select Intensity '.target$'_band
	Remove
	select Sound '.target$'_band
	Rename... '.target$'_LF_portion
	last_LF$=selected$("Sound")
endproc

procedure LPfilter .target$ .cutoff .cross
	select Sound '.target$'
	Filter (stop Hann band)... 0 .cutoff .cross
	select Sound '.target$'_band
	Rename... '.target$'_HP_portion
endproc	

##HF component restoration 
procedure addHF .sound$ .filteredsound$
	select Sound '.sound$'
if hf_rest=1
	Formula... self [col] + Sound_Original_A_token_HP_portion [col]
endif
endproc

procedure F0_extract .target$
	select Sound '.target$'
	oldsource$=selected$("Sound")
	To Manipulation... 0.01 75 600
	View & Edit
	editor Manipulation '.target$'
	pause Check accuracy of F0 tracking, modify as desired
	Publish resynthesis
	Close
	endeditor
	Rename... "Pitch manipulated A token"
	source$=selected$("Sound")
	select Manipulation 'oldsource$'
	Extract pitch tier
	f0=Get mean (points)... 0 0
	select PitchTier 'oldsource$'
	select Sound 'oldsource$'
	plus Manipulation 'oldsource$'
	Remove
endproc


procedure setBandWidths .grid$ .formant
call predictBand .formant
	select FormantGrid '.grid$'
		if .formant =1
			Add bandwidth point... 1 0.5 predictBand.value
		endif
		if .formant =2
			Add bandwidth point... 2 0.5 predictBand.value
		endif
		if .formant =3
			Add bandwidth point... 3 0.5 predictBand.value
		endif
		if .formant=4
			Add bandwidth point... 4 0.5 predictBand.value
		endif
		if .formant=5
			Add bandwidth point... 5 0.5 predictBand.value
		endif
endproc

procedure predictBand .formantname
f1BW = 75
	f2BW = 85
	f3BW = 90
	f4BW = 100
	f5BW = 210
		if .formantname =1
			.value=f1BW
		endif
		if .formantname =2
			.value=f2BW
		endif
		if .formantname =3
			.value=f3BW
		endif
		if .formantname=4
			value=f4BW
		endif
		if .formantname=5
			.value=f5BW
		endif
endproc

procedure concatenate .cross
	select Sound 'preceding_segment$'
			plus Sound grid
			Concatenate with overlap... '.cross'
			temp_chain$=selected$("Sound")
			select Sound 'following_segment$'
			Copy... following_segment_temp
			select Sound 'temp_chain$'
			plus Sound following_segment_temp
			Concatenate with overlap... '.cross'
			Rename... synthesized contour
			current$=selected$("Sound")
			select Sound 'temp_chain$'
			plus Sound following_segment_temp
			Remove
endproc