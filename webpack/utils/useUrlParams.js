import qs from 'query-string';
import { useLocation } from 'react-router-dom';

// Allows hash and params e.g. "/foo#bar?query=baz"
// returns { hash: "bar", params: { query: "baz" } }
const useUrlParamsWithHash = () => {
  const { hash: fullParams } = useLocation();
  const [hash, queryParams = {}] = fullParams.split('?');
  const params = qs.parse(queryParams);
  const trimmedhash = hash.replace('#', '');
  return { hash: trimmedhash, params };
};

export default useUrlParamsWithHash;
