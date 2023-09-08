import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { Spinner, OverlayTrigger, Tooltip } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';

const EnabledRepositoryContent = ({
  loading, disableTooltipId, disableRepository, canDisable,
}) => (
  <Spinner loading={loading} inline>
    <OverlayTrigger
      overlay={<Tooltip id={disableTooltipId}>{canDisable ? __('Disable') : __('Cannot be disabled because it is part of a published content view')}</Tooltip>}
      placement="bottom"
      trigger={['hover', 'focus']}
      rootClose={false}
    >
      <button
        onClick={disableRepository}
        style={canDisable ? {
          backgroundColor: 'initial',
          border: 'none',
          color: '#0388ce',
        } : {
          backgroundColor: 'initial',
          border: 'none',
          color: '#d2d2d2',
        }
      }
        disabled={!canDisable}
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
  canDisable: PropTypes.bool.isRequired,
};

export default EnabledRepositoryContent;
