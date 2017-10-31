import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';

import { ListViewItem } from 'patternfly-react';

const RedHatRepository = ({ redHatRepository }) => {
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

  const getArchAndTypeText = () => (
    <div>
      <strong>
        {redHatRepository.arch}
      </strong>
      <p className="pull-right">
        {redHatRepository.type}
      </p>
    </div>
    );

  const itemAction = () => (
    <a role="link" onClick="">
      <i className={cx('fa-2x', redHatRepository.enabled ? 'fa fa-minus-circle'
           : 'pficon-add-circle-o')}
      />
    </a>
    );

  return (
    <ListViewItem
      additionalListClass="list-view-pf-stacked"
      key={redHatRepository.id}
      heading={redHatRepository.name}
      itemText={getArchAndTypeText()}
      actions={itemAction()}
      iconClass={getTypeIcon(redHatRepository.type)}
    />
  );
};

RedHatRepository.propTypes = {
  redHatRepository: PropTypes.object
};

RedHatRepository.defaultProps = {
  redHatRepository: {}
};


export default RedHatRepository;
