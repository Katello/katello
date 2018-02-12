import React from 'react';
import PropTypes from 'prop-types';
import { ListView } from 'patternfly-react';

import RepositoryTypeIcon from './RepositoryTypeIcon';
import RepositorySetRepositories from './RepositorySetRepositories';

const RepositorySet = ({
  type, id, name, label, product,
}) => (
  <ListView.Item
    id={id}
    className="listViewItem--listItemVariants"
    description={__(label)}
    heading={__(name)}
    leftContent={<RepositoryTypeIcon id={id} type={type} />}
    stacked
    hideCloseIcon
  >
    <RepositorySetRepositories contentId={id} productId={product.id} />
  </ListView.Item>
);

RepositorySet.propTypes = {
  id: PropTypes.number.isRequired,
  type: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  product: PropTypes.shape({
    name: PropTypes.string.isRequired,
    id: PropTypes.number.isRequired,
  }).isRequired,
};

export default RepositorySet;
