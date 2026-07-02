import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Toolbar,
  ToolbarContent,
  ToolbarItem,
  Button,
  ToolbarGroup,
  Dropdown,
  DropdownList,
  DropdownItem,
  Divider,
  MenuToggle,
  Tooltip,
} from '@patternfly/react-core';
import { EllipsisVIcon, ExternalLinkAltIcon, ExportIcon } from '@patternfly/react-icons';
import { LinkContainer } from 'react-router-bootstrap';
import { noop } from 'foremanReact/common/helpers';
import SearchBar from 'foremanReact/components/SearchBar';
import { getControllerSearchProps } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import ColumnSelector from 'foremanReact/components/ColumnSelector';
import TooltipButton from '../../../../components/TooltipButton';
import { SUBSCRIPTIONS_SERVICE_URL } from '../../SubscriptionConstants';

const SubscriptionsToolbar = ({
  canManageSubscriptionAllocations,
  disableManifestActions,
  disableManifestReason,
  disableDeleteButton,
  disableDeleteReason,
  disableAddButton,
  autocompleteQueryParams,
  updateSearchQuery,
  onDeleteButtonClick,
  onSearch,
  onManageManifestButtonClick,
  onExportCsvButtonClick,
  tableColumns,
  isManifestImported,
  currentUserId,
  hasPreference,
}) => {
  const [isKebabOpen, setIsKebabOpen] = useState(false);

  const onKebabToggle = () => setIsKebabOpen(!isKebabOpen);
  const onKebabSelect = () => setIsKebabOpen(false);

  // Transform tableColumns to ColumnSelector format
  const columnSelectorData = {
    url: currentUserId ? `/api/v2/users/${currentUserId}/table_preferences` : null,
    controller: 'subscriptions',
    categories: [
      {
        name: __('General'),
        key: 'general',
        defaultExpanded: true,
        checkProps: {
          checked: false,
        },
        children: tableColumns.map(col => ({
          name: col.label,
          key: col.key,
          checkProps: {
            checked: col.value,
            disabled: col.key === 'id' ? true : null,
          },
        })),
      },
    ],
    hasPreference,
  };

  return (
    <Toolbar id="subscriptions-toolbar" ouiaId="subscriptions-toolbar">
      <ToolbarContent>
        <ToolbarGroup variant="filter-group" className="subscriptions-filter-group">
          <ToolbarItem variant="search-filter">
            <SearchBar
              data={{
                ...getControllerSearchProps('/katello/api/v2/subscriptions', 'searchBar-katello_subscriptions', true, autocompleteQueryParams),
                controller: 'katello_subscriptions',
              }}
              onSearch={onSearch}
              onSearchChange={updateSearchQuery}
            />
          </ToolbarItem>
        </ToolbarGroup>
        <ToolbarGroup>
          {canManageSubscriptionAllocations &&
            <ToolbarItem>
              <LinkContainer
                to="/subscriptions/add"
                disabled={disableManifestActions || disableAddButton}
              >
                <TooltipButton
                  tooltipId="add-subscriptions-button-tooltip"
                  tooltipText={disableManifestReason}
                  tooltipPlacement="top"
                  title={__('Add subscriptions')}
                  disabled={disableManifestActions}
                  variant="primary"
                />
              </LinkContainer>
            </ToolbarItem>
          }

          <ToolbarItem>
            <Button ouiaId="export-csv-button" onClick={onExportCsvButtonClick} variant="secondary" icon={<ExportIcon />}>
              {__('Export CSV')}
            </Button>
          </ToolbarItem>

          <ToolbarItem className="subscriptions-column-selector">
            <ColumnSelector data={columnSelectorData} />
          </ToolbarItem>

          {/* Kebab menu for overflow actions */}
          <ToolbarItem>
            <Dropdown
              ouiaId="subscriptions-kebab-dropdown"
              onSelect={onKebabSelect}
              toggle={toggleRef => (
                <MenuToggle
                  ref={toggleRef}
                  aria-label={__('Actions')}
                  variant="plain"
                  onClick={onKebabToggle}
                  isExpanded={isKebabOpen}
                >
                  <EllipsisVIcon size="md" />
                </MenuToggle>
              )}
              isOpen={isKebabOpen}
              onOpenChange={isOpen => setIsKebabOpen(isOpen)}
            >
              <DropdownList>
                <DropdownItem
                  ouiaId="manage-manifest-dropdown-item"
                  key="manage-manifest"
                  onClick={() => {
                    onManageManifestButtonClick();
                    onKebabSelect();
                  }}
                >
                  {__('Manage manifest')}
                </DropdownItem>
                {isManifestImported && (
                  <DropdownItem
                    ouiaId="view-usage-dropdown-item"
                    key="view-usage"
                    onClick={() => window.open(SUBSCRIPTIONS_SERVICE_URL, '_blank', 'noopener,noreferrer')}
                  >
                    {__('View subscription usage')} <ExternalLinkAltIcon />
                  </DropdownItem>
                )}
                {canManageSubscriptionAllocations && (
                  <>
                    <Divider key="divider" />
                    {disableDeleteButton ? (
                      <Tooltip content={disableDeleteReason} key="delete">
                        <DropdownItem
                          ouiaId="delete-dropdown-item"
                          onClick={e => e.preventDefault()}
                          isAriaDisabled
                        >
                          {__('Delete')}
                        </DropdownItem>
                      </Tooltip>
                    ) : (
                      <DropdownItem
                        ouiaId="delete-dropdown-item"
                        key="delete"
                        onClick={() => {
                          onDeleteButtonClick();
                          onKebabSelect();
                        }}
                      >
                        {__('Delete')}
                      </DropdownItem>
                    )}
                  </>
                )}
              </DropdownList>
            </Dropdown>
          </ToolbarItem>
        </ToolbarGroup>
      </ToolbarContent>
    </Toolbar>
  );
};

SubscriptionsToolbar.propTypes = {
  tableColumns: PropTypes.arrayOf(PropTypes.shape({
    key: PropTypes.string,
    label: PropTypes.string,
    value: PropTypes.bool,
  })),
  canManageSubscriptionAllocations: PropTypes.bool,
  disableManifestActions: PropTypes.bool,
  disableManifestReason: PropTypes.string,
  disableDeleteButton: PropTypes.bool,
  disableDeleteReason: PropTypes.string,
  disableAddButton: PropTypes.bool,
  autocompleteQueryParams: PropTypes.shape({}),
  updateSearchQuery: PropTypes.func,
  onSearch: PropTypes.func,
  onDeleteButtonClick: PropTypes.func,
  onManageManifestButtonClick: PropTypes.func,
  onExportCsvButtonClick: PropTypes.func,
  isManifestImported: PropTypes.bool,
  currentUserId: PropTypes.number,
  hasPreference: PropTypes.bool,
};

SubscriptionsToolbar.defaultProps = {
  tableColumns: [],
  canManageSubscriptionAllocations: false,
  disableManifestActions: false,
  disableManifestReason: '',
  disableDeleteButton: false,
  disableDeleteReason: '',
  disableAddButton: false,
  autocompleteQueryParams: undefined,
  updateSearchQuery: noop,
  onSearch: noop,
  onDeleteButtonClick: noop,
  onManageManifestButtonClick: noop,
  onExportCsvButtonClick: noop,
  isManifestImported: false,
  currentUserId: undefined,
  hasPreference: false,
};

export default SubscriptionsToolbar;
