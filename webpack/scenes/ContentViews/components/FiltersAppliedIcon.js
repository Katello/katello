import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Tooltip, Icon } from '@patternfly/react-core';
import { FilterIcon } from '@patternfly/react-icons';

const FiltersAppliedIcon = () => (
  <Tooltip
    position="auto"
    enableFlip
    entryDelay={400}
    content={__('Filters were applied to this version.')}
  >
    <Icon size="sm">
      <FilterIcon style={{ color: '#0081db', margin: '0 9px' }} />
    </Icon>
  </Tooltip>
);

export default FiltersAppliedIcon;
