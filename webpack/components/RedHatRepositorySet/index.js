import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';

import { ListViewExpandableItem, ListViewItem } from 'patternfly-react';

const RedHatRepositorySet = ({ redHatRepositorySet }) => {
  const renderRepositoryList = () => (
    redHatRepositorySet.repositories.map(redHatRepository =>
      <ListViewItem key={redHatRepository.id} heading={redHatRepository.arch} />
    )
  );

  // TODO: combine this and the one in RedHatRepository
  const getTypeIcon = (type) => {
    let className = '';

    switch (type) {
      case 'rpm':
        className = 'pficon-bundle';
        break;
      case 'source_rpm':
        className = 'fa fa-code';
        break;
      case 'debug':
        className = 'fa fa-bug';
        break;
      case 'iso':
        className = 'fa fa-file-image-o';
        break;
      case 'beta':
        className = 'fa fa-bold';
        break;
      case 'kickstart':
        className = 'fa fa-futbol-o';
        break;
      default:
        className = 'fa fa-question';
        break;
    }
    return cx('fa-2x', className);
  };

  return (
    <ListViewExpandableItem
      additionalListClass="list-view-pf-stacked"
      key={redHatRepositorySet.id}
      heading={redHatRepositorySet.name}
      itemText={redHatRepositorySet.label}
      expansion={renderRepositoryList()}
      actions={redHatRepositorySet.type}
      iconClass={getTypeIcon(redHatRepositorySet.type)}
    />);
};

RedHatRepositorySet.propTypes = {
  redHatRepositorySet: PropTypes.object
};

RedHatRepositorySet.defaultProps = {
  redHatRepositorySet: ''
};

export default RedHatRepositorySet;
