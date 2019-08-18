# Installation Instructions

## Note Regarding IIIF Images

This repository does **not** include a local IIIF image server (ours is used with the default configuration).
If you want to provide facsimile images of your own, you will have to set up an image server yourself.
We are using [IIPImage](https://iipimage.sourceforge.io/).

## Docker

You can create a [Docker](https://www.docker.com/) image by building from the included `Dockerfile`.
On Mac/Linux (may require `sudo`, depending on your configuration):

    $ docker build -t bruckner-studienbuch .

You can then run the container, either by using `docker-run.sh` or with:

    $ docker run -it --rm --name studienbuch -p 127.0.0.1:4444:4444 -p 127.0.0.1:8080:8080 bruckner-studienbuch

The Docker build will build everything from source.
This can be useful, if you want to experiment with the code without setting up a dedicated development environment.

## Manual Installation

Feel free to also refer to the `Dockerfile`.
It contains all the necessary steps.

All of the following instructions refer to the `app/` directory.

### Frontend / Viewer App

The Viewer app is a Single-Page-App written in JavaScript.
If you just want to run it, you can use the compiled code in `dist/` and no additional steps are necessary.
In case you want to make changes in the code, you will need to install [Node.js and NPM](https://nodejs.org/). Then, install dependencies with:

    $ npm install

Create a new build with:
    
    $ npm run build

Start a development server (may require additional configuration) with:

    $ npm run start

### Backend / XSLT Servlet

The XSLT servlet provides an HTTP endpoint for XSLT transformations (with result caching), used for the music analysis functionality.
It requires a servlet container, such as [Apache Tomcat](https://tomcat.apache.org/download-90.cgi) (we have tested both version 8 and 9).
Unpack the installation archive and copy the `XSLTServlet.war` file to the `webapps` directory.
Then you can start the server.
On Mac/Linux (substitute directories where applicable):

    $ tar xzf apache-tomcat-9.0.22.tar.gz
    $ cp XSLTServlet.war apache-tomcat-9.0.22/webapps
    $ apache-tomcat-9.0.22/bin/startup.sh

The servlet should now be reachable at `http://localhost:8080/XSLTServlet/`.

### Backend / Python

The `server.py` script, which is responsible for listing/serving data files and providing facsimile data requires [Python](https://www.python.org/downloads/) 3.6 or newer, as well as the `bottle` and `lxml` packages.
You can either install these packages globally, or create a [virtual environment](https://docs.python.org/3/library/venv.html).

Setting up a virtual environment would look something like this on Mac/Linux:

    $ python3 -m venv .venv
    $ . .venv/bin/activate
    (.venv) $ pip install -r requirements.txt

Start the server with (change the location of the data files if applicable):

    (.venv) $ python server.py ../applicationData/data_src

Alternatively, without requiring activation of the venv:

    $ .venv/bin/python server.py ../applicationData/data_src

## Opening the App

If everything is working, you should now be able to open the app by navigating to <http://localhost:4444> in your browser.
