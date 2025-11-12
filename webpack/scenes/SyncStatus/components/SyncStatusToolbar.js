import React from 'react';
import PropTypes from 'prop-types';
import {
  Toolbar,
  ToolbarContent,
  ToolbarItem,
  Button,
  Switch,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const SyncStatusToolbar = ({
  selectedRepoIds,
  onSyncNow,
  onExpandAll,
  onCollapseAll,
  onSelectAll,
  onSelectNone,
  showActiveOnly,
  onToggleActiveOnly,
  isSyncDisabled,
}) => (
  <Toolbar isSticky>
    <ToolbarContent>
      <ToolbarItem>
        <Button
          variant="secondary"
          onClick={onExpandAll}
        >
          {__('Expand All')}
        </Button>
      </ToolbarItem>
      <ToolbarItem>
        <Button
          variant="secondary"
          onClick={onCollapseAll}
        >
          {__('Collapse All')}
        </Button>
      </ToolbarItem>
      <ToolbarItem>
        <Button
          variant="secondary"
          onClick={onSelectAll}
        >
          {__('Select All')}
        </Button>
      </ToolbarItem>
      <ToolbarItem>
        <Button
          variant="secondary"
          onClick={onSelectNone}
        >
          {__('Select None')}
        </Button>
      </ToolbarItem>
      <ToolbarItem>
        <Switch
          id="active-only-switch"
          label={__('Active Only')}
          isChecked={showActiveOnly}
          onChange={onToggleActiveOnly}
        />
      </ToolbarItem>
      <ToolbarItem align={{ default: 'alignRight' }}>
        <Button
          variant="primary"
          onClick={onSyncNow}
          isDisabled={isSyncDisabled || selectedRepoIds.length === 0}
        >
          {__('Synchronize Now')}
        </Button>
      </ToolbarItem>
    </ToolbarContent>
  </Toolbar>
);

SyncStatusToolbar.propTypes = {
  selectedRepoIds: PropTypes.arrayOf(PropTypes.number).isRequired,
  onSyncNow: PropTypes.func.isRequired,
  onExpandAll: PropTypes.func.isRequired,
  onCollapseAll: PropTypes.func.isRequired,
  onSelectAll: PropTypes.func.isRequired,
  onSelectNone: PropTypes.func.isRequired,
  showActiveOnly: PropTypes.bool.isRequired,
  onToggleActiveOnly: PropTypes.func.isRequired,
  isSyncDisabled: PropTypes.bool,
};

SyncStatusToolbar.defaultProps = {
  isSyncDisabled: false,
};

export default SyncStatusToolbar;
