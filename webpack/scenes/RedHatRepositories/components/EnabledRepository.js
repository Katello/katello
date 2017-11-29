import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { ListView } from 'patternfly-react';
import { getTypeIcon } from '../../../services/index';

const EnabledRepository = ({
  arch, name, id, type, releasever,
}) => (
  <ListView.Item
    key={id}
    actions={
      // eslint-disable-next-line
      <a
        onClick={() => {
          // https://github.com/Katello/katello/blob/c0d72eb79981c215a664021bf90ef79eb2a286d2/app/controllers/katello/api/v2/repository_sets_controller.rb#L64
        }}
      >
        <i className={cx('fa-2x', 'fa fa-minus-circle')} />
      </a>
    }
    leftContent={<ListView.Icon name={getTypeIcon(type)} />}
    additionalInfo={[
      <ListView.InfoItem key="1">
        <strong>{type.toUpperCase()}</strong>
      </ListView.InfoItem>,
    ]}
    heading={__(name)}
    description={`${arch} ${releasever}`}
    stacked
  />
);

EnabledRepository.propTypes = {
  id: PropTypes.number.isRequired, // 638
  name: PropTypes.string.isRequired, // 'Red Hat Enterprise Linux 6 Server Kickstart x86_64 6.8'
  releasever: PropTypes.string.isRequired, // '6.8'
  arch: PropTypes.string.isRequired, // 'x86_64'
  type: PropTypes.string.isRequired, // 'rpm'
};

export default EnabledRepository;
