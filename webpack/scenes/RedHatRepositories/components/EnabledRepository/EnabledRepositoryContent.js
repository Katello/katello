import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { Spinner, OverlayTrigger, Tooltip } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';

const EnabledRepositoryContent = ({ loading, disableTooltipId, disableRepository }) => (
  <Spinner loading={loading} inline>
    <OverlayTrigger
      overlay={<Tooltip id={disableTooltipId}>{__('Disable')}</Tooltip>}
      placement="bottom"
      trigger={['hover', 'focus']}
      rootClose={false}
    >
      <button
        onClick={disableRepository}
        style={{
          backgroundColor: 'initial',
          border: 'none',
          color: '#0388ce',
        }}
      >
        <i className={cx('fa-2x', 'fa fa-minus-circle')} />
      </button>
    </OverlayTrigger>
  </Spinner>
);

EnabledRepositoryContent.propTypes = {
  loading: PropTypes.bool.isRequired,
  disableTooltipId: PropTypes.string.isRequired,
  disableRepository: PropTypes.func.isRequired,
};

export default EnabledRepositoryContent;
