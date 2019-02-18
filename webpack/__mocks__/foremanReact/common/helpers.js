import { snakeCase } from 'lodash';

export default {
  urlBuilder(...parts) {
    return parts.join('/');
  },
};

const propsToCase = (casingFn, errorMsg, ob) => {
  if (typeof ob !== 'object') throw Error(errorMsg);

  return Object.keys(ob).reduce((memo, key) => {
    // eslint-disable-next-line no-param-reassign
    memo[casingFn(key)] = ob[key];
    return memo;
  }, {});
};

export const propsToSnakeCase = ob =>
  propsToCase(snakeCase, 'propsToSnakeCase only takes objects', ob);

