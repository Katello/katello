import React, { useState, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { shallowEqual, useSelector } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import { Tabs, Tab, TabTitleText, Split, SplitItem, Button } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import onSelect from '../../../../components/Table/helpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  selectCVFilterRules,
  selectCVFilterRulesStatus,
} from '../ContentViewDetailSelectors';
import { getCVFilterRules } from '../ContentViewDetailActions';
import CVRpmMatchContentModal from './MatchContentModal/CVRpmMatchContentModal';
import AddPackageRuleModal from './Rules/Package/AddPackageRuleModal';

const CVRpmFilterContent = ({ filterId, inclusion }) => {
  const response = useSelector(state => selectCVFilterRules(state, filterId), shallowEqual);
  const status = useSelector(state => selectCVFilterRulesStatus(state, filterId), shallowEqual);
  const loading = status === STATUS.PENDING;

  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const [filterRuleId, setFilterRuleId] = useState(undefined);

  const [showMatchContent, setShowMatchContent] = useState(false);
  const onClose = () => setShowMatchContent(false);
  const [addRpmRuleModalOpen, setAddRpmRuleModalOpen] = useState(false);
  const openAddRpmRuleModal = () => setAddRpmRuleModalOpen(true);

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

  const buildRows = useCallback((results) => {
    const newRows = [];
    results.forEach((rule) => {
      const { name, architecture, id } = rule;
      const cells = [
        { title: name },
        { title: architecture || 'All architectures' },
        { title: versionText(rule) },
      ];

      newRows.push({ cells, id });
    });

    return newRows;
  }, []);

  useDeepCompareEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, loading, buildRows]);

  const emptyContentTitle = __('No rules have been added to this filter.');
  const emptyContentBody = __("Add to this filter using the 'Add RPM rule' button.");
  const emptySearchTitle = __('No matching rules found.');
  const emptySearchBody = __('Try changing your search settings.');
  const tabTitle = (inclusion ? __('Included') : __('Excluded')) + __(' RPMs');


  const actionResolver = () => [
    {
      title: __('View matching content'),
      onClick: (_event, _rowId, { id }) => {
        setFilterRuleId(id);
        setShowMatchContent(true);
      },
    },
  ];

  return (
    <Tabs activeKey={activeTabKey} onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}>
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
              actionResolver,
            }}
            status={status}
            onSelect={onSelect(rows, setRows)}
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
                <Split hasGutter>
                  <SplitItem>
                    <Button onClick={openAddRpmRuleModal} variant="secondary" aria-label="create_rpm_rule">
                      {__('Add RPM rule')}
                    </Button>
                  </SplitItem>
                </Split>
                {addRpmRuleModalOpen &&
                  <AddPackageRuleModal
                    filterId={filterId}
                    setIsOpen={setAddRpmRuleModalOpen}
                    aria-label="add_package_filter_rule_modal"
                  />}
              </>
            }
          />
        </div>
      </Tab>
    </Tabs>
  );
};

CVRpmFilterContent.propTypes = {
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  inclusion: PropTypes.bool,
};

CVRpmFilterContent.defaultProps = {
  filterId: '',
  inclusion: false,
};
export default CVRpmFilterContent;
