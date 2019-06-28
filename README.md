## The Bruckner Study Book Viewer

This repository holds the source files of the [Bruckner Study Book Viewer](https://apps-mufo.oeaw.ac.at/studienbuch/) and 
the MEI data as well as the XSLT for the harmonic analysis.
These are the results of the two-year project "*Digital musical analysis with MEI on the example of Anton Bruckners' 
compositional studies*" which [he created during his studies with Otto Kitzler](https://www.oeaw.ac.at/ikm/forschung/digital-musicology/digitale-musikanalyse-mit-mei/).

This project pursued two objectives: The first was to create a digital edition of the study book by encoding 
the entire manuscript in the XML-based format of the [Music Encoding Initiative (MEI)](http://www.music-encoding.org), 
including all interventions in the musical text such as deletions and additions as well as remarks and annotations 
by Anton Bruckner and his teacher
found in the page margin and inbetween the staves. 
The transcriptions can be compared in the image viewer with the corresponding facsimile. 

The second aim was to create an automated harmonic analysis, which was tested using the generated data. 
Our approach to programming the analysis is a combination of the well-known [Krumhansl-Schmuckler algorithm for key recognition](https://pdfs.semanticscholar.org/6426/d811de335c61a3145623718b4615a35bb51b.pdf)
and chord recognition aswell as formalized rules for non-chord tones via XSLT. 

### Encoding Documentation

For further information on our encoding guidelines, [please click here](https://github.com/paavomare/Bruckner-Study-Book-Viewer/blob/master/documentation/documentation-encoding.md).

### The Image Viewer: Facsimile and Analysis mode

To visualize the MEI data, we created an image viewer, which comprises two main modes: the Facsimile mode to explore the original manuscript in comparison with a digital in a synoptical view, and the Analysis mode to examine chord progressions using an automated analysis program.

You can find further information on the image viewer by [clicking here](https://github.com/paavomare/Bruckner-Study-Book-Viewer/blob/master/documentation/documentation-image-viewer.md).

### Automated Harmonic Analysis

### Installation of the Image Viewer:

Instructions on installing the image viewer will be included soon. 

