const repoTypeSearchQueryMap = {
  rpm: '(name ~ rpms) and (name !~ source rpm) and (name !~ debug rpm)',
  sourceRpm: 'name ~ source rpm',
  debugRpm: 'name ~ debug rpm',
  kickstarter: 'name ~ kickstart',
  ostree: 'name ~ ostree',
  beta: 'name ~ beta',
};

const recommendedRepositorySetLables = [
  'rhel-7-server-rpms',
  'rhel-6-server-rpms',
  'rhel-6-server-satellite-tools-6.3-rpms',
  'rhel-server-rhscl-7-rpms',
  'rhel-7-server-satellite-capsule-6.3-rpms',
  'rhel-7-server-satellite-capsule-6.4-rpms',
  'rhel-7-server-satellite-tools-6.3-rpms',
  'rhel-6-server-satellite-tools-6.3-rpms',
  'rhel-7-server-ansible-2.5-rpms',
  'rhel-7-server-optional-rpms',
  'rhel-7-server-extras-rpms',
  'rhel-5-server-els-rpms',
  'rhel-7-server-eus-rpms',
];

const createLablesQuery = lables =>
  lables.map(label => `label = ${label}`).join(' or ');

const isRecommendedRepositorySet = ({ label }) => recommendedRepositorySetLables.includes(label);

export const normalizeRepositorySets = (data) => {
  data.results.forEach((repositorySet) => {
    /* eslint no-param-reassign: ["error", { "ignorePropertyModificationsFor": ["id"] }] */
    repositorySet.id = parseInt(repositorySet.id, 10);
    repositorySet.recommended = isRecommendedRepositorySet(repositorySet);
  });

  return data;
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

export const recommendedRepositorySetsQuery = createLablesQuery(recommendedRepositorySetLables);

export default normalizeRepositorySets;
