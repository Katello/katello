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
import TreeSelectAllCheckbox from './TreeSelectAllCheckbox';

const SyncStatusToolbar = ({
  selectedRepoIds,
  onSyncNow,
  showActiveOnly,
  onToggleActiveOnly,
  isSyncDisabled,
  selectAllCheckboxProps,
}) => (
  <Toolbar isSticky ouiaId="sync-status-toolbar">
    <ToolbarContent alignItems={{ default: 'alignItemsCenter' }} style={{ minHeight: '41px' }}>
      <ToolbarItem>
        <TreeSelectAllCheckbox {...selectAllCheckboxProps} />
      </ToolbarItem>
      <ToolbarItem alignSelf="center">
        <Switch
          id="show-syncing-only-switch"
          label={__('Show syncing only')}
          isChecked={showActiveOnly}
          onChange={onToggleActiveOnly}
          ouiaId="show-syncing-only-switch"
        />
      </ToolbarItem>
      <ToolbarItem>
        <Button
          variant="primary"
          onClick={onSyncNow}
          isDisabled={isSyncDisabled || selectedRepoIds.length === 0}
          ouiaId="sync-button"
        >
          {__('Synchronize')}
        </Button>
      </ToolbarItem>
    </ToolbarContent>
  </Toolbar>
);

SyncStatusToolbar.propTypes = {
  selectedRepoIds: PropTypes.arrayOf(PropTypes.number).isRequired,
  onSyncNow: PropTypes.func.isRequired,
  showActiveOnly: PropTypes.bool.isRequired,
  onToggleActiveOnly: PropTypes.func.isRequired,
  isSyncDisabled: PropTypes.bool,
  selectAllCheckboxProps: PropTypes.shape({
    selectNone: PropTypes.func.isRequired,
    selectAll: PropTypes.func.isRequired,
    selectedCount: PropTypes.number.isRequired,
    totalCount: PropTypes.number.isRequired,
    areAllRowsSelected: PropTypes.bool.isRequired,
  }).isRequired,
};

SyncStatusToolbar.defaultProps = {
  isSyncDisabled: false,
};

export default SyncStatusToolbar;
