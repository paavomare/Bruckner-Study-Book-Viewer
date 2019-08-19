import pytest
import requests as r

SERVLET_PATH = 'http://localhost:8080/Transform/'


def resp_work():
    data = {
        '__xslID': 'work',
    }
    files = {
        '__xml': open('./test_data/kitzler_001_cleanedup.xml', 'rb'),
    }
    return r.post(SERVLET_PATH, data=data, files=files)


def resp_analyse_by_key():
    data = {
        '__xslID': 'analyseByKey',
        'profile': 'krumhansl',
        'windowSize': '4',
    }
    files = {
        '__xml': open('./test_data/kitzler_001_cleanedup_work.xml', 'rb'),
    }
    return r.post(SERVLET_PATH, data=data, files=files)


@pytest.fixture(scope='module')
def resp():
    return resp_analyse_by_key()


def test_status_ok(resp):
    assert resp.status_code == r.codes.ok


def test_cors(resp):
    assert resp.headers.get('Access-Control-Allow-Origin') == '*'


def test_speed():
    resp2 = resp_analyse_by_key()
    total_seconds = resp2.elapsed.total_seconds()
    print(total_seconds)
    assert total_seconds < 0.02


def test_harm(resp):
    assert '<harm' in resp.text


def test_headers(resp):
    print(resp.headers)


def test_options():
    resp = r.options(SERVLET_PATH)
    assert resp.headers.get('Access-Control-Allow-Origin') == '*'
    assert resp.headers.get('Access-Control-Allow-Methods') == 'POST'


def test_work():
    resp = resp_work()
    assert resp.status_code == r.codes.ok
