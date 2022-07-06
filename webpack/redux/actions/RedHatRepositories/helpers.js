import { first, intersection } from 'lodash';

const repoTypeSearchQueryMap = {
  rpm: '(name !~ source rpm) and (name !~ debug rpm) and (content_type = yum) and (label !~ beta) and (label !~ htb) and (name !~ beta) and (product_name !~ beta)',
  sourceRpm: '(name ~ source rpm) and (content_type = yum)',
  debugRpm: '(name ~ debug rpm) and (content_type = yum)',
  kickstart: 'content_type = kickstart',
  ostree: 'content_type = ostree',
  beta: '(name ~ beta) or (label ~ beta) or (label ~ htb)',
};

const recommendedRepositoriesRHEL = [
  'rhel-9-for-x86_64-baseos-rpms',
  'rhel-9-for-x86_64-appstream-rpms',
  'rhel-8-for-x86_64-baseos-rpms',
  'rhel-8-for-x86_64-baseos-kickstart',
  'rhel-8-for-x86_64-appstream-rpms',
  'rhel-8-for-x86_64-appstream-kickstart',
  'rhel-8-for-x86_64-baseos-eus-rpms',
  'rhel-8-for-x86_64-appstream-eus-rpms',
  'rhel-7-server-rpms',
  'rhel-7-server-optional-rpms',
  'rhel-7-server-extras-rpms',
  'rhel-7-server-kickstart',
];

const recommendedRepositoriesSatTools = [
  'satellite-client-6-for-rhel-9-x86_64-rpms',
  'satellite-client-6-for-rhel-8-x86_64-rpms',
  'rhel-7-server-satellite-client-6-rpms',
  'rhel-6-server-els-satellite-client-6-rpms',
];

const recommendedRepositoriesMisc = [
  'rhel-server-rhscl-7-rpms',
  'rhel-7-server-satellite-capsule-6.11-rpms',
  'satellite-capsule-6.11-for-rhel-8-x86_64-rpms',
  'rhel-7-server-ansible-2.9-rpms',
  'ansible-2-for-rhel-8-x86_64-rpms',
  'rhel-7-server-satellite-maintenance-6.11-rpms',
  'rhel-7-server-satellite-utils-6.11-rpms',
  'satellite-maintenance-6.11-for-rhel-8-x86_64-rpms',
  'satellite-utils-6.11-for-rhel-8-x86_64-rpms',
];

const recommendedRepositorySetLables = recommendedRepositoriesRHEL
  .concat(recommendedRepositoriesSatTools)
  .concat(recommendedRepositoriesMisc);

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

export const productsIdsToSearchQuery = productIds => productIds
  .map(id => `(product_id = "${id}")`)
  .join(' or ');

export const joinSearchQueries = parts => parts
  .filter(v => (v && v !== ''))
  .map(v => `(${v})`)
  .join(' and ');

export const recommendedRepositorySetsQuery = createLablesQuery(recommendedRepositorySetLables);

export const getArchFromPath = (path) => {
  const architectures = ['x86_64', 's390x', 'ppc64le', 'aarch64', 'multiarch', 'ppc64'];
  const splitPath = path.split('/').map(h => h.toLowerCase());
  const arches = intersection(splitPath, architectures);
  return first(arches);
};

export default normalizeRepositorySets;
