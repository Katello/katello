const buildContentView = id => ({
  id,
  composite: 'false',
  name: `contentView${id}`,
  environments: [],
  repositories: [],
  versions: [],
  last_published: 'Not Yet Published',
});

const createBasicCVs = (amount) => {
  const response = {
    total: 100,
    subtotal: 100,
    page: 1,
    per_page: 20,
    error: null,
    search: null,
    sort: {
      by: 'name',
      order: 'asc',
    },
    results: [],
  };

  [...Array(amount).keys()].map((_, i) => response.results.push(buildContentView(i)));

  return response;
};

export default createBasicCVs;
