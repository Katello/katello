import { snakeCase, camelCase } from 'lodash';

export const stringIsPositiveNumber = (value) => {
  const reg = new RegExp('^[0-9]+$');
  return reg.test(value);
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

export const propsToCamelCase = ob =>
  propsToCase(camelCase, 'propsToSnakeCase only takes objects', ob);
