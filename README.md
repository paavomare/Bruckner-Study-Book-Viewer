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

The second aim was to create an [automated harmonic analysis](https://github.com/paavomare/Bruckner-Study-Book-Viewer/blob/master/documentation/documentation-analysis.md) which was tested using the generated data. 
Our approach to programming the analysis is a combination of the well-known [Krumhansl-Schmuckler algorithm for key recognition](https://pdfs.semanticscholar.org/6426/d811de335c61a3145623718b4615a35bb51b.pdf)
and chord recognition aswell as chord recognition and rules for non-chord tones via XSLT. 

### Encoding Documentation

Although the MEI guidelines provide several elements and attributes for encoding musical documents, some values had to be adapted for the specific demands of this project.

Here you can find further information on our [encoding guidelines](https://github.com/paavomare/Bruckner-Study-Book-Viewer/blob/master/documentation/documentation-encoding.md).

### The Image Viewer: Edition and Analysis mode

To visualize the MEI data, we created an image viewer, which comprises two main modes: the Edition mode to explore the original manuscript in comparison with a digital in a synoptical view, and the Analysis mode to examine chord progressions using an automated analysis program.

We provide a [detailed description of the image viewer](https://github.com/paavomare/Bruckner-Study-Book-Viewer/blob/master/documentation/documentation-image-viewer.md) in our documentation.

### Automated Harmonic Analysis

The automated harmonic analysis is a Roman numeral analysis based on statistical key recognition with the Krumhansl-Schmuckler algorithm in combination with an XSLT-chord recognition based on thirds and a filter that recognizes and classifies foreign chord tones.

Here you can find further information on our [harmonic analysis](https://github.com/paavomare/Bruckner-Study-Book-Viewer/blob/master/documentation/documentation-analysis.md).

### Installation of the Image Viewer

You can find instructions on installing the image viewer [right here](https://github.com/paavomare/Bruckner-Study-Book-Viewer/blob/master/documentation/documentation-viewer-installation.md). 

