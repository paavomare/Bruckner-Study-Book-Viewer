import {
  ENDPOINT_LIST,
  ENDPOINT_FACS,
  ENDPOINT_FILE,
  ENDPOINT_XSLT,
} from './constants';

export const urls = {
  [ENDPOINT_XSLT]: 'http://localhost:8080/XSLTServlet/',
  [ENDPOINT_LIST]: 'ls',
  [ENDPOINT_FACS]: 'facs',
  [ENDPOINT_FILE]: 'file',
};
