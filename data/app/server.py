import argparse
from collections import defaultdict
from glob import iglob
from io import BytesIO
import json
import os
import re

import bottle # pip install bottle
from bottle import get, response, static_file
from lxml import etree # pip install lxml


FACS_INFO_PATH = './facsimile.xml'
NUM_FACS_PAGES = 337

MEI_NS = 'http://www.music-encoding.org/ns/mei'
mei = lambda e: '{' + MEI_NS + '}' + e
NS_MAP = {'mei': MEI_NS}

state = {
    'document_path': None,
}


def enable_cors(func):

    def _enable_cors(*args, **kwargs):
        response.headers['Access-Control-Allow-Origin'] = '*'
        return func(*args, **kwargs)

    return _enable_cors


def by_numeric_part(path):
    name = path.split('/')[-1]
    match = re.match('.*?(\d+)', name)
    if match is not None:
        return int(match.group(1))
    else:
        return 0


@get('/ls')
@enable_cors
def list_files():
    root = re.sub(f'{os.path.sep}$', '', state['document_path'])
    files_list = map(lambda s: s.replace(f'{root}{os.path.sep}', ''),
                     filter(os.path.isfile,
                            iglob(os.path.join(root, '**'),
                                  recursive=True)))
    sorted_files_list = sorted(
        files_list,
        key=lambda f: (by_numeric_part(f.split('/')[-1]), f)
    )
    with open('titel.json') as titel_file:
        titles = json.load(titel_file)
    return {
        'filenames': [{'name': filename,
                       'label': filename.split('_')[-1].replace('.xml', '') + ': ' + ' // '.join(titles[filename])}
                      for filename in sorted_files_list]
    }


def get_page_info():
    filenames = [f['name'] for f in list_files()['filenames']]
    facs_tree = etree.parse(FACS_INFO_PATH)
    page_labels = [s.get('label') for s in facs_tree.iter('surface')]
    iiif_urls = [g.get('target') for g in facs_tree.iter('graphic')]
    pb_locations = defaultdict(list)
    current_page_label = page_labels[0]
    for filename in filenames:
        internal_page = 0
        tree = etree.parse(BytesIO(get_file(filename)))
        for pb in tree.iter(mei('pb')):
            internal_page += 1
            if internal_page == 1:
                elements_before_first_pb = pb.xpath(
                    'preceding::mei:measure',
                    namespaces=NS_MAP)
                if len(elements_before_first_pb) > 0:
                    pb_locations[current_page_label].append({
                        'filePath': filename,
                        'vrvPage': 0,
                    })
            current_page_label = pb.get('n')
            pb_locations[current_page_label].append({
                'filePath': filename,
                'vrvPage': internal_page,
            })
        if internal_page == 0:
            pb_locations[current_page_label].append({
                'filePath': filename,
                'vrvPage': internal_page,
            })
    return {
        'pages': [{'label': l, 'target': t}
                  for l, t in zip(page_labels, iiif_urls)],
        'locations': {p: pb_locations[p] for p in page_labels},
    }


@get('/facs')
@enable_cors
def get_facs_data():
    return {
        'facsimileData': get_page_info(),
    }


@get('/file/<path:path>')
@enable_cors
def get_file(path):
    root = state['document_path']
    # not using static_file because it doesn't send the CORS headers
    with open(os.path.join(root, path), 'rb') as xf:
        contents = xf.read()
    return contents


@get('/<path:path>')
def get_static_file(path):
    return static_file(path, root='./dist')


@get('/')
def get_index_html():
    return static_file('index.html', root='./dist')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('document_path',
                        help=('path to the top level containing the data, e.g. '
                              '"/.../bruckner-studienbuch/MEI angereichert"'))
    parser.add_argument('-P', '--port', default='4444',
                        help='the port to listen on (default: 4444)')
    parser.add_argument('-d', '--dev', action='store_true',
                        help='enable development mode (auto reload)')
    args = parser.parse_args()
    state['document_path'] = os.path.expanduser(args.document_path)
    if not os.path.isdir(args.document_path):
        raise OSError(f'"{args.document_path}" is not a valid directory!')

    if args.dev:
        bottle.run(host='127.0.0.1', port=args.port, reloader=True)
    else:
        bottle.run(host='127.0.0.1', port=args.port)


if __name__ == '__main__':
    main()
