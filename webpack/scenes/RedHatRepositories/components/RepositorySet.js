import React from 'react';
import PropTypes from 'prop-types';
import { ListView } from 'patternfly-react';

import { getTypeIcon } from '../../../services/index';
import RepositorySetRepositories from './RepositorySetRepositories';

const RepositorySet = ({
  type, id, name, label, product,
}) => (
  <ListView.Item
    id={id}
    className="listViewItem--listItemVariants"
    description={__(label)}
    heading={__(name)}
    leftContent={<ListView.Icon name={getTypeIcon(type)} />}
    additionalInfo={[
      <ListView.InfoItem key="1">
        <strong>{type.toUpperCase()}</strong>
      </ListView.InfoItem>,
    ]}
    stacked
    hideCloseIcon
  >
    <RepositorySetRepositories contentId={id} productId={product.id} />
  </ListView.Item>
);

RepositorySet.propTypes = {
  id: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  product: PropTypes.shape({
    name: PropTypes.string.isRequired,
    id: PropTypes.instanceOf.isRequired,
  }).isRequired,
};

export default RepositorySet;
