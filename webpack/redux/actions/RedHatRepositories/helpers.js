export function normalizeRepositorySets(data) {
  data.results.forEach((repositorySet) => {
    /* eslint no-param-reassign: ["error", { "ignorePropertyModificationsFor": ["id"] }] */
    repositorySet.id = parseInt(repositorySet.id, 10);
  });
  return data;
}

const repoTypeSearchQueryMap = {
  rpm: '(name ~ rpms) and (name !~ source rpm) and (name !~ debug rpm)',
  sourceRpm: 'name ~ source rpm',
  debugRpm: 'name ~ debug rpm',
  kickstarter: 'name ~ kickstart',
  ostree: 'name ~ ostree',
  beta: 'name ~ beta',
};

const maptToSearchQuery = (filter) => {
  if (filter === 'other') {
    const joined = Object.keys(repoTypeSearchQueryMap)
      .map(k => repoTypeSearchQueryMap[k])
      .map(q => `(${q})`)
      .join(' or ');
    return `not (${joined})`;
  }
  return repoTypeSearchQueryMap[filter];
};

export const repoTypeFilterToSearchQuery = filters => filters
  .map(f => `(${maptToSearchQuery(f)})`)
  .join(' or ');

export const joinSearchQueries = parts => parts
  .filter(v => (v && v !== ''))
  .map(v => `(${v})`)
  .join(' and ');

export default normalizeRepositorySets;
