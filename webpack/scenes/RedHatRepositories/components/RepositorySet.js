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
  >
    <RepositorySetRepositories contentId={id} productId={product.id} />
  </ListView.Item>
);

RepositorySet.propTypes = {
  id: PropTypes.string.isRequired, // '1952'
  type: PropTypes.string.isRequired, // 'kickstart'
  name: PropTypes.string.isRequired, // 'Red Hat Enterprise Linux 6 Server (Kickstart)'
  label: PropTypes.string.isRequired, // 'rhel-6-server-kickstart'
  product: PropTypes.shape({
    name: PropTypes.string.isRequired, // 'Red hat Enterprise Linux Server 7'
    id: PropTypes.instanceOf.isRequired, // 5
  }).isRequired,
  // vendor: PropTypes.string.isRequired, // 'Red Hat'
  // gpgUrl: PropTypes.string.isRequired, // 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release'
  // contentUrl: PropTypes.string.isRequired, // '/content/dist/rhel/server/6///kickstart'
};

export default RepositorySet;
