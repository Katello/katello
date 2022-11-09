const buildContentView = id => ({
  id,
  composite: false,
  name: `contentView${id}`,
  environments: [],
  repositories: [],
  versions: [],
  last_published: 'Not Yet Published',
  activation_keys: [],
  hosts: [],
});

const createBasicCVs = (amount) => {
  const response = {
    total: amount,
    subtotal: amount,
    page: 1,
    can_create: true,
    can_view: true,
    per_page: 20,
    error: null,
    search: null,
    sort: {
      by: 'name',
      order: 'asc',
    },
    results: [],
  };

  [...Array(amount).keys()].forEach((_, i) => response.results.push(buildContentView(i + 1)));

  return response;
};

export default createBasicCVs;
