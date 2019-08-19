import equal from 'deep-equal';
import { zip } from 'lodash/array';

// equal determines object equality by value
export const arraysOfObjectsAreEqual = (arr1, arr2) => {
  if (
    (arr1 === undefined && arr2 !== undefined) ||
    (arr2 === undefined && arr1 !== undefined)
  ) {
    return false;
  } else if (arr1 === undefined && arr2 === undefined) {
    return true;
  } else {
    return (
      arr1.length === arr2.length &&
      zip(arr1, arr2).every(([o1, o2]) => equal(o1, o2), { strict: true })
    );
  }
};

export const deepEquals = equal;

export const rangeArray = n => Array.from(Array(n).keys());
