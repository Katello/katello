import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import { Tabs, Tab, TabTitleText, Split, SplitItem, Button, Dropdown, DropdownItem, KebabToggle } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { ArtifactsWithNoErrataRenderer } from './ArtifactsWithNoErrata';
import onSelect from '../../../../components/Table/helpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  selectCVFilterDetails,
  selectCVFilterRules,
  selectCVFilterRulesStatus,
} from '../ContentViewDetailSelectors';
import { deleteContentViewFilterRules, getCVFilterRules, removeCVFilterRule } from '../ContentViewDetailActions';
import CVRpmMatchContentModal from './MatchContentModal/CVRpmMatchContentModal';
import AddEditPackageRuleModal from './Rules/Package/AddEditPackageRuleModal';
import AffectedRepositoryTable from './AffectedRepositories/AffectedRepositoryTable';
import { hasPermission } from '../../helpers';

const CVRpmFilterContent = ({
  cvId, filterId, inclusion, showAffectedRepos, setShowAffectedRepos, details,
}) => {
  const response = useSelector(state => selectCVFilterRules(state, filterId), shallowEqual);
  const { results, ...metadata } = response;
  const status = useSelector(state => selectCVFilterRulesStatus(state, filterId), shallowEqual);
  const loading = status === STATUS.PENDING;
  const filterDetails = useSelector(state =>
    selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const { repositories = [] } = filterDetails;
  const dispatch = useDispatch();

  const [rows, setRows] = useState([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const [filterRuleId, setFilterRuleId] = useState(undefined);
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const toggleBulkAction = () => setBulkActionOpen(prevState => !prevState);
  const hasSelected = rows.some(({ selected }) => selected);
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedFilterRuleData, setSelectedFilterRuleData] = useState(undefined);
  const [showMatchContent, setShowMatchContent] = useState(false);
  const { permissions } = details;

  const onClose = () => {
    setModalOpen(false);
    setShowMatchContent(false);
    setSelectedFilterRuleData(undefined);
  };

  const columnHeaders = [
    __('RPM name'),
    __('Architecture'),
    __('Versions'),
  ];

  const versionText = (rule) => {
    const { version, min_version: minVersion, max_version: maxVersion } = rule;

    if (rule.version) return `Version ${version}`;
    if (rule.min_version && !rule.max_version) return `Greater than version ${minVersion}`;
    if (!rule.min_version && rule.max_version) return `Less than version ${maxVersion}`;
    if (rule.min_version && rule.max_version) {
      return `Between versions ${rule.min_version} and ${rule.max_version}`;
    }
    return 'All versions';
  };

  const buildRows = useCallback(() => {
    const newRows = [];
    results.forEach((rule) => {
      const {
        name, architecture, id, ...rest
      } = rule;

      const cells = [
        { title: name },
        { title: architecture || 'All architectures' },
        { title: versionText(rule) },
      ];

      newRows.push({
        cells, id, name, arch: architecture, ...rest,
      });
    });

    return newRows;
  }, [results]);

  useDeepCompareEffect(() => {
    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, results, loading, buildRows]);

  useEffect(() => {
    if (!repositories.length && showAffectedRepos) {
      setActiveTabKey(1);
    } else {
      setActiveTabKey(0);
    }
  }, [showAffectedRepos, repositories.length]);

  const emptyContentTitle = __('No rules have been added to this filter.');
  const emptyContentBody = __("Add to this filter using the 'Add RPM rule' button.");
  const emptySearchTitle = __('No matching rules found.');
  const emptySearchBody = __('Try changing your search settings.');
  const tabTitle = (inclusion ? __('Included') : __('Excluded')) + __(' RPMs');


  const actionResolver = () => [
    {
      title: __('Remove'),
      onClick: (_event, _rowId, { id }) => {
        dispatch(removeCVFilterRule(filterId, id, () =>
          dispatch(getCVFilterRules(filterId))));
      },
    },
    {
      title: __('Edit'),
      onClick: (_event, _rowId, ruleDetails) => {
        setSelectedFilterRuleData(ruleDetails);
        setModalOpen(true);
      },
    },
    {
      title: __('View matching content'),
      onClick: (_event, _rowId, { id }) => {
        setFilterRuleId(id);
        setShowMatchContent(true);
      },
    },
  ];

  const bulkRemove = () => {
    setBulkActionOpen(false);
    const rpmFilterIds =
      rows.filter(row => row.selected).map(selected => selected.id);
    dispatch(deleteContentViewFilterRules(filterId, rpmFilterIds, () =>
      dispatch(getCVFilterRules(filterId))));
    deselectAll();
  };

  return (
    <Tabs className="margin-0-24" activeKey={activeTabKey} onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}>
      <Tab eventKey={0} title={<TabTitleText>{tabTitle}</TabTitleText>}>
        <div className="margin-24-0">
          <TableWrapper
            {...{
              rows,
              metadata,
              emptyContentTitle,
              emptyContentBody,
              emptySearchTitle,
              emptySearchBody,
              searchQuery,
              updateSearchQuery,
              status,
            }}
            actionResolver={hasPermission(permissions, 'edit_content_views') ? actionResolver : null}
            onSelect={hasPermission(permissions, 'edit_content_views') ? onSelect(rows, setRows) : null}
            cells={columnHeaders}
            variant={TableVariant.compact}
            autocompleteEndpoint={`/content_view_filters/${filterId}/rules/auto_complete_search`}
            fetchItems={useCallback(params => getCVFilterRules(filterId, params), [filterId])}
            actionButtons={
              <>
                {showMatchContent &&
                  <CVRpmMatchContentModal
                    key={`${filterId}-${filterRuleId}`}
                    filterRuleId={filterRuleId}
                    filterId={filterId}
                    onClose={onClose}
                  />}
                {hasPermission(permissions, 'edit_content_views') &&
                  <Split hasGutter>
                    <SplitItem>
                      <Button onClick={() => setModalOpen(true)} variant="primary" aria-label="add_rpm_rule">
                        {__('Add RPM rule')}
                      </Button>
                    </SplitItem>
                    <SplitItem>
                      <Dropdown
                        toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                        isOpen={bulkActionOpen}
                        isPlain
                        dropdownItems={[
                          <DropdownItem aria-label="bulk_remove" key="bulk_remove" isDisabled={!hasSelected} component="button" onClick={bulkRemove}>
                            {__('Remove')}
                          </DropdownItem>]
                        }
                      />
                    </SplitItem>
                    <SplitItem>
                      <ArtifactsWithNoErrataRenderer
                        filterDetails={filterDetails}
                      />
                    </SplitItem>
                  </Split>
                }
                {modalOpen &&
                  <AddEditPackageRuleModal
                    filterId={filterId}
                    onClose={onClose}
                    selectedFilterRuleData={selectedFilterRuleData}
                  />}
              </>}
          />
        </div>
      </Tab>
      {(repositories.length || showAffectedRepos) &&
        <Tab eventKey={1} title={<TabTitleText>{__('Affected repositories')}</TabTitleText>}>
          <div className="margin-24-0">
            <AffectedRepositoryTable cvId={cvId} filterId={filterId} repoType="yum" setShowAffectedRepos={setShowAffectedRepos} details={details} />
          </div>
        </Tab>}
    </Tabs>
  );
};

CVRpmFilterContent.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  inclusion: PropTypes.bool,
  showAffectedRepos: PropTypes.bool.isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

CVRpmFilterContent.defaultProps = {
  cvId: '',
  filterId: '',
  inclusion: false,
};
export default CVRpmFilterContent;
