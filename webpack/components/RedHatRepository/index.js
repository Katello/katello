import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { ListViewItem } from 'patternfly-react';
import { getTypeIcon } from '../../services';

const RedHatRepository = ({ redHatRepository }) => {
  const getArchAndTypeText = () => (
    <div>
      <strong>{redHatRepository.arch}</strong>
      <p className="pull-right">{redHatRepository.type}</p>
    </div>
  );

  const itemAction = () => (
    // eslint-disable-next-line
    <a onClick="">
      <i
        className={cx(
          'fa-2x',
          redHatRepository.enabled ? 'fa fa-minus-circle' : 'pficon-add-circle-o',
        )}
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
  redHatRepository: PropTypes.shape({
    test: PropTypes.string.isRequired,
  }),
};

RedHatRepository.defaultProps = {
  redHatRepository: {},
};

export default RedHatRepository;
