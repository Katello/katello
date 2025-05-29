import React, { useEffect, useContext } from 'react';
import PropTypes from 'prop-types';
import {
  Alert,
  ToolbarItem,
  Text,
  TextContent,
  TextVariants,
} from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { translate as __ } from 'foremanReact/common/I18n';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { getControllerSearchProps } from 'foremanReact/constants';
import { noop } from 'foremanReact/common/helpers';
import { RowSelectTd } from 'foremanReact/components/HostsIndex/RowSelectTd';
import { getPageStats } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import { BulkPackagesWizardContext, getPackagesUrl } from './BulkPackagesWizard';
import katelloApi from '../../../../../services/api';
import BULK_ACTIONS_OSFAMILY from '../BulkActionsConstants';

export const BulkPackagesUpgradeTable = props => <BulkPackagesTable {...props} tableType="upgrade" />;
export const BulkPackagesInstallTable = props => <BulkPackagesTable {...props} tableType="install" />;
export const BulkPackagesRemoveTable = props => <BulkPackagesTable {...props} tableType="remove" />;

const BulkPackagesTable = ({
  tableType,
  warningBanner,
  OSFamilyMismatch,
  OSFamily,
}) => {
  const {
    setShouldValidateStep2,
    packagesBulkSelect,
    packagesResults: results,
    packagesMetadata: {
      total, per_page: perPage, page, subtotal,
    },
    packagesResponse: response,
  } = useContext(BulkPackagesWizardContext);
  const PACKAGES_URL = getPackagesUrl(tableType);
  const apiOptions = { key: 'BULK_HOST_PACKAGES' };
  const packageActionsNames = { install: __('Install packages'), remove: __('Remove packages'), upgrade: __('Upgrade packages') };
  const packageActionsDescriptions = {
    install: __('Select packages to install on the selected hosts. Some packages may already be installed on some hosts.'),
    remove: __('Select packages to remove on the selected hosts.'),
    upgrade: __('Select packages to upgrade to the latest version. Packages may have different versions on different hosts.'),
  };

  const origSearchProps = getControllerSearchProps(OSFamily, 'searchBar-packages');
  const customSearchProps = {
    ...origSearchProps,
    autocomplete: {
      ...origSearchProps.autocomplete,
      url: katelloApi.getApiUrl(`/${OSFamily}/auto_complete_search`),
    },
  };

  const {
    selectPage,
    selectNone,
    selectOne,
    isSelected,
    selectedCount,
    areAllRowsSelected,
    areAllRowsOnPageSelected,
    updateSearchQuery,
    hasInteracted,
  } = packagesBulkSelect;

  useEffect(() => {
    if (results?.length && hasInteracted) {
      setShouldValidateStep2(true);
    }
  }, [setShouldValidateStep2, results, hasInteracted]);

  const pageStats = getPageStats({ total: subtotal, page, perPage });
  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectNone,
          selectPage,
          selectedCount,
          pageRowCount: pageStats.pageRowCount,
          areAllRowsSelected,
          areAllRowsOnPageSelected,
        }}
        selectAll={noop}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const columns = {
    name: {
      title: __('Package'),
      wrapper: ({ name, id }) => (
        <a target="_blank" href={tableType === 'remove' ? `/${OSFamily}?search=${name}` : `/${OSFamily}/${id}`} rel="noreferrer">{name}</a>
      ),
      isSorted: true,
      weight: 50,
    },
  };

  return (
    <>
      <TextContent>
        <Text ouiaId="mpw-step-3-header" component={TextVariants.h3}>
          {packageActionsNames[tableType]}
        </Text>
        <Text ouiaId="mpw-step-3-content" component={TextVariants.p}>
          {packageActionsDescriptions[tableType]}
        </Text>
      </TextContent>
      {(warningBanner)}
      {selectedCount === 0 && hasInteracted && (
        <Alert
          ouiaId="no-packages-alert"
          variant="info"
          isInline
          title={__('Select at least one package.')}
          style={{ marginBottom: '1rem' }}
        />
      )}
      {tableType === 'upgrade' && !results?.length && !OSFamilyMismatch && (
        <Alert
          ouiaId="no-packages-found-alert"
          variant="info"
          isInline
          title={__('No upgradable packages found.')}
          style={{ marginBottom: '1rem' }}
        />
      )}
      {!OSFamilyMismatch && (<TableIndexPage
        columns={columns}
        showCheckboxes
        apiUrl={PACKAGES_URL}
        apiOptions={apiOptions}
        controller="packages"
        customSearchProps={customSearchProps}
        creatable={false}
        replacementResponse={response}
        selectionToolbar={selectionToolbar}
        updateSearchQuery={updateSearchQuery}
        rowSelectTd={RowSelectTd}
        selectOne={selectOne}
        isSelected={isSelected}
        idColumn="name"
        updateParamsByUrl={false}
        bookmarksPosition="right"
      />)}
    </>
  );
};

BulkPackagesTable.propTypes = {
  tableType: PropTypes.string.isRequired,
  OSFamilyMismatch: PropTypes.bool.isRequired,
  OSFamily: PropTypes.string,
  warningBanner: PropTypes.element,
};

BulkPackagesTable.defaultProps = {
  OSFamily: BULK_ACTIONS_OSFAMILY.REDHAT,
  warningBanner: <></>,
};
