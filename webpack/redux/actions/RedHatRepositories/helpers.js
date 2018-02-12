export function normalizeRepositorySets(data) {
  data.results.forEach((repositorySet) => {
    /* eslint no-param-reassign: ["error", { "ignorePropertyModificationsFor": ["id"] }] */
    repositorySet.id = parseInt(repositorySet.id, 10);
  });
  return data;
}

export default normalizeRepositorySets;
