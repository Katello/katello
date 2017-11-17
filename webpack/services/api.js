import { getApiRequest } from './mock';

// eslint-disable-next-line import/prefer-default-export
export const get = ({ name }) =>
  new Promise((resolve, reject) => {
    const request = getApiRequest(name);

    if (request) {
      return resolve(request.response);
    }

    return reject(new Error('No api request found with that name.'));
  });
