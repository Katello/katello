import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import cx from '@theforeman/vendor/classnames';
import { Spinner, OverlayTrigger, Tooltip } from '@theforeman/vendor/patternfly-react';

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
