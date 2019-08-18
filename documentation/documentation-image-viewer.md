# Bruckner Studienbuch Viewer Technical Notes
 
In this section, we would like to provide some insight into the architecture of the viewer app, and into why certain things were done the way they were done, while at the same time highlighting some parts of the code that may be interesting or useful for similar projects.
In case you have questions about any of this, or other aspects of the app, we will of course be happy to answer them.

## Basic Architecture

The app consists of:

+ A _Single-Page-App_ client, implemented in JavaScript, for viewing and interacting with the Studienbuch in the browser;

+ a server, implemented in Python, responsible for:

    + providing a list of available MEI files / titles;
    + serving MEI as well as other static files;
    + providing a list of available facsimile pages and to which MEI files (and sub-pages) they correspond.

+ an XSLT servlet, implemented in Java, responsible for transforming MEI data with XSLT (with result caching).

In retrospect, it would probably have been better to use [eXist-db](http://exist-db.org/exist/apps/homepage/index.html) for both serving files and server-side processing.
The main reasons it was not used, were limited familiarity (and XQuery skills) and Python's comparative ease and flexibility.
The primary motivation for the XSLT servlet was, that at one point, our XSLTs took a very long time to execute, so caching made a big difference.

## Analyse / XSLT Data Flow

When it comes to working with MEI, the heavy lifting is being done by XSLT stylesheets.
In the "Analyse" mode, every MEI file is first transformed with the `process2work.xsl` stylesheet (removing variants, resolving shortcuts, ...).
The result of that transformation is then used for subsequent Analyse-requests (`analyseByKey.xsl`).

## Zooming / Panning of the MEI Encoding

For displaying the MEI encoding, we are of course using the wonderful [Verovio toolkit](https://www.verovio.org/index.xhtml).
The manuscript pages (which are being served via [IIIF](https://iiif.io/)) are presented using the [OpenSeadragon](https://openseadragon.github.io/) image viewer.
We thought it would be interesting to also apply free zooming and panning to Verovio's rendering of the music.
This is achieved by using Verovio's SVG output (which happily remains accessible via the DOM) as an overlay over a transparent background, while using "fictional" tile sources to enable paging (see `VerovioViewer.js` for details).

The app uses the [React](https://reactjs.org/) library, which works out great for managing application state and user interface controls, but whose declarative nature proved to be quite a challenge to bring into harmony with the rather imperative nature of the Verovio toolkit.
In retrospect, the vision of encapsulating the whole viewer logic in components, may not have been such a good idea.
Or maybe it was a good idea, but not executed all that well.
Unfortunately, there was no time to find out.

## Showing the MEI Corresponding to a Manuscript Page

In the "Edition" mode, paging is synchronized between the manuscript pages and the MEI encoding.
For this to be possible, there needs to be a mechanism for getting the MEI corresponding to the current manuscript page.
In principle, this works via the `@n` attributes of the page break (`pb`) elements.
However, our data consists of many separate files, which are organized mainly with the musical content, and not page breaks, in mind.
The case of a new piece of music starting in the middle of a page was especially challenging, as (at the time of implementation) Verovio did not provide this functionality for rendering this case at all.
This was addressed by:

+ creating an index of manuscript pages and the corresponding file and internal page (see `get_page_info()` in `server.py`);
+ when necessary, doing two Verovio-renderings and merging the results "manually" (see `showComposite()` and `mergeSVG()` in `ZoomingVerovio.js`).

This approach was meant to be integrated with the original implementation (which only knew how to deal with single files; the original plan was to dynamically create a single MEI file for each page, assembling a `scoreDef`; there were problems with that, like ties), but unfortunately, there was no time for that.
For this reason, there are currently two separate implementations for "Edition" and "Analyse" mode.

## Annotation Transcription Display

The overlays containing the transcriptions of text annotations were created with the help of the [Vertaktoid](https://github.com/cemfi/vertaktoid) application, which allows marking up images on a tablet and creating MEI-`zone`-data from the process.
These "fake-measures" were matched to the corresponding `annot` elements via an `@n` attribute.
Then we created a static version of the `annot` data via an external pipeline (see `annotData.js`; the actual overlays are created in `handleAnnot()` in `App.js`).
