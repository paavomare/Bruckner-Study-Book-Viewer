export const getElementsForXPath = (doc, xpath, nsmap = {}) => {
  const xpathResultIterator = doc.evaluate(
    xpath, // xpath expression (string)
    doc, // document (as returned by DOMParser)
    prefix => nsmap[prefix] || null,
    XPathResult.UNORDERED_NODE_ITERATOR_TYPE,
    null,
  );
  const resultElements = [];
  let thisNode = xpathResultIterator.iterateNext();
  while (thisNode) {
    resultElements.push(thisNode);
    thisNode = xpathResultIterator.iterateNext();
  }
  return resultElements;
};

export const getElementsBySelector = (parentNode, selector) =>
  Array.from(parentNode.querySelectorAll(selector));

export const getElementsWithIdsIfPresent = (parentNode, arrayOfIds) =>
  arrayOfIds
    .map(id => parentNode.querySelector(`#${id}`))
    .filter(element => element !== null);

export const addStyleToElements = (arrayOfElements, className) =>
  arrayOfElements.forEach(element => element.classList.add(className));
