from glob import iglob
from io import BytesIO
import os

import requests as r

SERVLET_PATH = 'https://apps-mufo.oeaw.ac.at/Transform/'
# SERVLET_PATH = 'http://localhost:8080/XSLTServlet/'
DATA_PATH = '../bruckner-studienbuch/applicationData/data_src'

PROBLEM_FILES = [
    'Bruckner_013.xml',
    'Bruckner_031.xml',
    'Bruckner_032.xml',
    'Bruckner_042.xml',
    'Bruckner_043.xml',
    'Bruckner_063.xml',
    'Bruckner_103.xml',
    'Bruckner_110.xml',
    'Bruckner_116.xml',
    'Bruckner_118.xml',
    'Bruckner_120.xml',
    'Bruckner_130.xml',
    'Bruckner_131.xml',
    'Bruckner_132.xml',
]

def resp_work(filename):
    data = {
        '__xslID': 'work',
    }
    files = {
        '__xml': open(filename, 'rb'),
    }
    return r.post(SERVLET_PATH, data=data, files=files)


def resp_analyse_by_key(filelike):
    data = {
        '__xslID': 'analyseByKey',
        'profile': 'krumhansl',
        'windowSize': '2',
    }
    files = {
        '__xml': filelike,
    }
    return r.post(SERVLET_PATH, data=data, files=files)


def test_work():
    resp = resp_work()
    assert resp.status_code == r.codes.ok


def main():
    # for fn in map(lambda f: os.path.join(DATA_PATH, f), iglob(DAT):
    for fn in sorted(iglob(os.path.join(DATA_PATH, '*.xml'))):
        print(os.path.basename(fn))
        work_resp = resp_work(fn)
        work_code = work_resp.status_code
        work_data = work_resp.content
        analyse_resp = resp_analyse_by_key(BytesIO(work_data))
        analyse_code = analyse_resp.status_code
        if work_code != 200:
            print('  work:', work_resp.text)
        if analyse_code != 200:
            print('  analyseByKey:', analyse_resp.text)


if __name__ == '__main__':
    main()
