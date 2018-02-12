import classnames from 'classnames';
import { reduce, snakeCase } from 'lodash';

// eslint-disable-next-line import/prefer-default-export
export function getTypeIcon(type) {
  let className = '';

  switch (type) {
    case 'yum':
      className = 'pficon-bundle';
      break;
    case 'source_rpm':
      className = 'fa fa-code';
      break;
    case 'file':
      className = 'fa fa-file';
      break;
    case 'debug':
      className = 'fa fa-bug';
      break;
    case 'iso':
      className = 'fa fa-file-image-o';
      break;
    case 'beta':
      className = 'fa fa-bold';
      break;
    case 'kickstart':
      className = 'fa fa-futbol-o';
      break;
    default:
      className = 'fa fa-question';
      break;
  }
  return classnames('fa-2x', className);
}

export const propsToSnakeCase = ob =>
  reduce(
    ob,
    (snakeOb, val, key) => {
      // eslint-disable-next-line no-param-reassign
      snakeOb[snakeCase(key)] = val;
      return snakeOb;
    },
    {},
  );
