# # # # #
# Estimate formant contours using polynomial functions
# # # # #
formants=4
maxformant=5000
ncoeff=10
formant=1
steps=100
form 
	text source_segment /Users/pplsuser/semisynthetic/Original_A_token.wav
endform
Read from file... 'source_segment$'
dur=Get total duration
step_size=dur/steps
points=steps+1
# # # # # Get the formants
To Formant (burg)... 0.001 formants maxformant 0.025 5000
beginPause ("Which formant do you want to model?")
	f = endPause ("F1", "F2", "F3", "Done", 2)
	if f=1
	formant$="F1"
	endif
	Down to Table: "no", "yes", 6, "no", 3, "no", 3, "no"
	Rename... values
	points=Get number of rows
Set column label (label): "time(s)", "time"
Set column label (label): "F1(Hz)", "F1"
Set column label (label): "F2(Hz)", "F2"
Set column label (label): "F3(Hz)", "F3"
Set column label (label): "F4(Hz)", "F4"
# # # # # Fit the regression
Create Table with column names... regression_analysis points time1
	for c from 2 to ncoeff
		Append column... time'c'
		endfor

	for n from 1 to points
		select Table values
		sample_point = Get value... n time
		formant = Table_values[n,1]
		select Table regression_analysis
		for c from 1 to ncoeff
			Set numeric value... n time'c' sample_point^c
			endfor
		endfor
To linear regression
Write to text file... regression_report.txt
	Remove
	Read Strings from raw text file... regression_report.txt
	filedelete regression_report.txt
line$ = Get string... 4
	intercept = extractNumber (line$, "intercept =")
	for c from 1 to ncoeff
		line$ = Get string... 5 + (c * 5)
		coeff'c' = extractNumber (line$, "value =")	
		endfor

	plus Table regression_analysis
	Remove

	clearinfo
	print 'newline$''tab$'Below are the parameters of the current polynomial function:'newline$''newline$'
	print 'tab$'intercept = 'tab$''intercept:3''newline$'
	for c from 1 to ncoeff
		coeff = coeff'c'
		print 'tab$'coefficient 'c' = 'tab$''coeff:3''newline$'
		endfor
		
select Table values
	for i from 1 to points
		time = Get value... i time
		fitted = intercept
		for c from 1 to ncoeff
			fitted = fitted + (coeff'c'*(time^c))
			Set numeric value... i fitted fitted
			endfor
		endfor


	### Draw Spectrogram and formant values

	Erase all
	do ("Select outer viewport...", 0, 8.5, 0, 6.5)
	select Table values
	Red
	Scatter plot (mark)... time begview endview formant 0 maxview 1 no .
	Yellow
	Scatter plot (mark)... time begview endview fitted 0 maxview 1 no .
	


