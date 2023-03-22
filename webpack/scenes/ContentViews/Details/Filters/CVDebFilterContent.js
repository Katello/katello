import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import { Tabs, Tab, TabTitleText, Split, SplitItem, Button, Dropdown, DropdownItem, KebabToggle } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import onSelect from '../../../../components/Table/helpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  selectCVFilterDetails,
  selectCVFilterRules,
  selectCVFilterRulesStatus,
} from '../ContentViewDetailSelectors';
import { deleteContentViewFilterRules, getCVFilterRules, removeCVFilterRule } from '../ContentViewDetailActions';
import CVDebMatchContentModal from './MatchContentModal/CVDebMatchContentModal';
import AddEditDebPackageRuleModal from './Rules/DebPackage/AddEditDebPackageRuleModal';
import AffectedRepositoryTable from './AffectedRepositories/AffectedRepositoryTable';
import { hasPermission } from '../../helpers';
import { emptyContentTitle,
  emptyContentBody,
  emptySearchTitle,
  emptySearchBody } from './FilterRuleConstants';

const CVDebFilterContent = ({
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
  const { permissions } = details;

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

  const onClose = () => {
    setModalOpen(false);
    setShowMatchContent(false);
    setSelectedFilterRuleData(undefined);
  };

  const columnHeaders = [
    __('Deb name'),
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

  const tabTitle = (inclusion ? __('Included') : __('Excluded')) + __(' DEBs');


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
    const debFilterIds =
      rows.filter(row => row.selected).map(selected => selected.id);
    dispatch(deleteContentViewFilterRules(filterId, debFilterIds, () =>
      dispatch(getCVFilterRules(filterId))));
    deselectAll();
  };

  return (
    <Tabs
      ouiaId="cv-deb-filter-content-tabs"
      activeKey={activeTabKey}
      onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}
    >
      <Tab eventKey={0} title={<TabTitleText>{tabTitle}</TabTitleText>}>
        <div className="tab-body-with-spacing">
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
            ouiaId="content-view-deb-filter-table"
            actionResolver={hasPermission(permissions, 'edit_content_views') ? actionResolver : null}
            status={status}
            onSelect={hasPermission(permissions, 'edit_content_views') ? onSelect(rows, setRows) : null}
            cells={columnHeaders}
            variant={TableVariant.compact}
            autocompleteEndpoint={`/katello/api/v2/content_view_filters/${filterId}/rules`}
            bookmarkController="katello_content_view_deb_filter_rules"
            fetchItems={useCallback(params => getCVFilterRules(filterId, params), [filterId])}
            actionButtons={
              <>
                {showMatchContent &&
                  <CVDebMatchContentModal
                    key={`${filterId}-${filterRuleId}`}
                    filterRuleId={filterRuleId}
                    filterId={filterId}
                    onClose={onClose}
                  />}
                <Split hasGutter>
                  <SplitItem>
                    <Button onClick={() => setModalOpen(true)} variant="secondary" aria-label="create_deb_rule">
                      {__('Add DEB rule')}
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
                </Split>
                {modalOpen &&
                  <AddEditDebPackageRuleModal
                    filterId={filterId}
                    onClose={onClose}
                    selectedFilterRuleData={selectedFilterRuleData}
                  />}
              </>}
          />
        </div>
      </Tab>
      {(repositories.length || showAffectedRepos) &&
        <Tab eventKey={1} title={<TabTitleText>{__('Affected Repositories')}</TabTitleText>}>
          <div className="tab-body-with-spacing">
            <AffectedRepositoryTable cvId={cvId} filterId={filterId} repoType="deb" setShowAffectedRepos={setShowAffectedRepos} details={details} />
          </div>
        </Tab>}
    </Tabs>
  );
};

CVDebFilterContent.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  inclusion: PropTypes.bool,
  showAffectedRepos: PropTypes.bool.isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
    repository_ids: PropTypes.arrayOf(PropTypes.number),
  }).isRequired,
};

CVDebFilterContent.defaultProps = {
  cvId: '',
  filterId: '',
  inclusion: false,
};
export default CVDebFilterContent;
