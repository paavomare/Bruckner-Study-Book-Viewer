import { arraysOfObjectsAreEqual, deepEquals, rangeArray } from '../util';

describe('arraysOfObjectsAreEqual', () => {
  const a1 = { a: 0, b: 1 };
  const a2 = { b: 1, a: 0 };
  const b = { a: 1, b: 1 };
  const c = { a: 0 };

  it('should return true when the arrays are equal', () =>
    expect(arraysOfObjectsAreEqual([a1, b, c], [a2, b, c])).to.be.true);
  it('should return false when the arrays are not equal', () =>
    expect(arraysOfObjectsAreEqual([a1, b, c], [a1, a2, b])).to.be.false);
  it('should return false when the arrays are of different length', () =>
    expect(arraysOfObjectsAreEqual([a1, b, c], [a1, c])).to.be.false);
  it('should work when empty arrays are involved', () =>
    expect(arraysOfObjectsAreEqual([], [])).to.be.true);
  it('should work when empty objects are involved', () =>
    expect(arraysOfObjectsAreEqual([{}, {}, {}], [{}, {}, {}])).to.be.true);
  it('should work when undefined is involved', () => {
    expect(arraysOfObjectsAreEqual(undefined, [{}, {}, {}])).to.be.false;
    expect(arraysOfObjectsAreEqual([{}, {}, {}], undefined)).to.be.false;
    expect(arraysOfObjectsAreEqual(undefined, undefined)).to.be.true;
  });
  it('should work when functions are involved', () => {
    const func = () => 'hello';
    expect(arraysOfObjectsAreEqual([{ f: func }], [{ f: func }])).to.be.true;
  });
});

describe('deepEquals', () => {
  it('should return true when two objects are equal', () => {
    expect(deepEquals({ a: 0, b: 1 }, { b: 1, a: 0 })).to.be.true;
  });
  it('should return false when two objects are not equal', () => {
    expect(deepEquals({ a: 0, b: 1 }, { b: 0, a: 0 })).to.be.false;
  });
  it('should work with empty objects', () => {
    expect(deepEquals({}, {})).to.be.true;
  });
});

describe('rangeArray', () => {
  it('should return an array containing numbers from 0 to n - 1', () => {
    expect(rangeArray(5)).to.deep.equal([0, 1, 2, 3, 4]);
  });
  it('should work with different arguments', () => {
    expect(rangeArray(2)).to.deep.equal([0, 1]);
  });
  it('should work with argument 0', () => {
    expect(rangeArray(0)).to.deep.equal([]);
  });
});
