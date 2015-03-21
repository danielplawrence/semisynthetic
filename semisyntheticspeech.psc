# Script for creating semisynthetic speech following Alku, Tiitinen & Naatanen (1999).
#First estimates the source of speech, the glottal flow, from a natural utterance using LPC inverse filtering. 
#The glottal flow obtained is then used as an excitation to an artificial digital filter that models the formant structure of speech.