#Example of basic LPC-inverse filtering in Praat

#First we resample and estimate the LPC filter:
Resample: 10000, 50
To LPC (burg): 8, 0.025, 0.005, 50

#Subtracting the LPC filter from the original signal
#gives us the LPC residual -- an estimation of the glottal flow
selectObject: "Sound untitled_10000"
plusObject: "LPC untitled_10000"
Filter (inverse)

#Now we create and modify a formant object
selectObject: "LPC untitled_10000"
To Formant
Formula (frequencies): "if row = 2 then self + 200 else self fi"
Formula (frequencies): "if row = 2 then self + 200 else self fi"

#Exciting the modified filter with the LPC residual gives us a resynthesized vowel
selectObject: "Sound untitled_10000"
plusObject: "Formant untitled_10000"
Filter
