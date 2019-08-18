export const PROFILES = [
  'krumhansl',
  'aarden',
  'simple',
  'bellman',
  'temperley',
  'mix',
];

const BAR_OPACITY = 0.5;

const KEYS_COLORS = {
  C: '#000000',
  Db: '#804000',
  D: '#fe0000',
  Eb: '#fe6a00',
  E: '#ffd800',
  F: '#00ff01',
  'F#': '#a8a8a8',
  G: '#01ffff',
  Ab: '#0094fe',
  A: '#0026ff',
  Bb: '#b100fe',
  B: '#ff006e',
  Cm: '#545454',
  'C#m': '#401f00',
  Dm: '#800001',
  Ebm: '#803400',
  Em: '#806b00',
  Fm: '#017f01',
  'F#m': '#ffffff',
  Gm: '#017f7e',
  'G#m': '#00497e',
  Am: '#001280',
  Bbm: '#590080',
  Bm: '#7f0037',
};

function moveToBack(node) {
  const firstChild = node.parentNode.firstChild;
  if (firstChild) {
    node.parentNode.insertBefore(node, firstChild);
  }
}

export function drawBars(viewerDiv) {
  const arena = viewerDiv.querySelector('svg.definition-scale g.page-margin');
  const measures = Array.from(arena.querySelectorAll('g.measure'));
  measures.forEach(measure => {
    if (measure.querySelector('g.harm.mfunc') === null) {
      return;
    }
    const topStaffLine = measure.querySelector('g.staff path');
    if (topStaffLine === null) {
      // invisible / hidden measure
      return;
    }
    const topStaffLineBBox = topStaffLine.getBBox();
    const keys = new Set(
      Array.from(measure.querySelectorAll('g.harm.mfunc'))
        .map(element =>
          element
            .getAttribute('class')
            .split(' ')
            .filter(c => KEYS_COLORS.hasOwnProperty(c)),
        )
        .reduce((arr1, arr2) => [...arr1, ...arr2], []),
    );
    keys.forEach(keyName => {
      const harm = measure.querySelector(
        'g.harm.' + keyName.replace('#', '\\#'),
      );
      if (harm === null) {
        return;
      }
      const harmBBox = harm.getBBox();
      const color = KEYS_COLORS[keyName];
      const rect = document.createElementNS(
        'http://www.w3.org/2000/svg',
        'rect',
      );
      rect.setAttribute('height', harmBBox.height);
      rect.setAttribute('width', topStaffLineBBox.width);
      rect.setAttribute('x', topStaffLineBBox.x);
      rect.setAttribute('y', harmBBox.y);
      rect.setAttribute('opacity', BAR_OPACITY);
      rect.setAttribute('style', `fill: ${color};`);
      const title = document.createElementNS(
        'http://www.w3.org/2000/svg',
        'title',
      );
      title.innerHTML = keyName;
      const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
      g.appendChild(title);
      g.appendChild(rect);
      arena.appendChild(g);
      moveToBack(g);
    });
  });
}

const SPECIAL_TONES = [
  [/43sus/, '4-3 Suspension'],
  [/65sus/, '6-5 Suspension'],
  [/98sus/, '9-8 Suspension'],
  [/23ret/, '2-3 Retardation'],
  [/78ret/, '7-8 Retardation'],
  [/(\d)upt/, '$1 passing tone'],
  [/(\d)un/, '$1 upper neighbor'],
  [/(\d)ln/, '$1 lower neighbor'],
];

export function addTitlesToSpecialTones(viewerDiv) {
  const arena = viewerDiv.querySelector('svg.definition-scale g.page-margin');
  arena.querySelectorAll('g.note.mod').forEach(note => {
    const toneCode = note
      .getAttribute('class')
      .split(' ')
      .filter(c => SPECIAL_TONES.some(([p, _]) => c.match(p)))
      .join(' ');
    const [pat, rep] = SPECIAL_TONES.find(([p, _]) => toneCode.match(p));
    const result = toneCode.replace(pat, rep);

    const title = document.createElementNS(
      'http://www.w3.org/2000/svg',
      'title',
    );
    title.innerHTML = result;
    const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    const cloned = note.cloneNode(true);
    g.appendChild(title);
    g.appendChild(cloned);
    note.replaceWith(g);
  });
}
