import qs from 'query-string';

/*
 For when you have a hash with your params in the URL
 pass in the the 'hash' object from react-router's useLocation();
 e.g. "mysite.com/foo#bar?baz=bop"
 will return { hash: 'bar', params: { baz: "bop" }}
*/
const paramsFromHash = (hash) => {
  const [baseHash, queryParams = {}] = hash.split('?');
  const params = qs.parse(queryParams);
  const trimmedHash = baseHash.replace('#', '');
  return { hash: trimmedHash, params };
};

export default paramsFromHash;
