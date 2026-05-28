import React from 'react';
import PropTypes from 'prop-types';
import { Spinner, Tooltip, Button } from '@patternfly/react-core';
import { MinusCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

const EnabledRepositoryContent = ({
  loading, disableRepository, canDisable,
}) => {
  if (loading) {
    return <Spinner size="md" />;
  }

  const tooltipContent = canDisable
    ? __('Disable')
    : __('Cannot be disabled because it is part of a content view');

  return (
    <Tooltip content={tooltipContent} position="bottom">
      <Button
        variant="plain"
        onClick={canDisable ? disableRepository : undefined}
        isAriaDisabled={!canDisable}
        aria-label={canDisable ? __('Disable') : __('Cannot be disabled')}
        ouiaId="disable-repository-button"
        className="disable-repository-button"
      >
        <MinusCircleIcon />
      </Button>
    </Tooltip>
  );
};

EnabledRepositoryContent.propTypes = {
  loading: PropTypes.bool.isRequired,
  disableRepository: PropTypes.func.isRequired,
  canDisable: PropTypes.bool.isRequired,
};

export default EnabledRepositoryContent;
