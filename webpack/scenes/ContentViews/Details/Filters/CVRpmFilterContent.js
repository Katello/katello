import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { shallowEqual, useSelector } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';

import onSelect from '../../../../components/Table/helpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  selectCVFilterRules,
  selectCVFilterRulesStatus,
} from '../ContentViewDetailSelectors';
import { getCVFilterRules } from '../ContentViewDetailActions';

const CVRpmFilterContent = ({ filterId, inclusion }) => {
  const response = useSelector(state => selectCVFilterRules(state, filterId), shallowEqual);
  const status = useSelector(state => selectCVFilterRulesStatus(state, filterId), shallowEqual);

  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const loading = status === STATUS.PENDING;

  const columnHeaders = [
    __('RPM name'),
    __('Architecture'),
    __('Versions'),
  ];

  const versionText = (rule) => {
    const { version, min_version: minVersion, max_version: maxVersion } = rule;

    if (rule.version) return `Version ${version}`;
    if (rule['min_version'] && !rule['max_version']) return `Greater than version ${minVersion}`;
    if (!rule['min_version'] && rule['max_version']) return `Less than version ${maxVersion}`;
    if (rule['min_version'] && rule['max_version']) {
       return `Between versions ${rule.min_version} and ${rule.max_version }`;
    } else {
      return 'All versions';
    }
  }

  const buildRows = (results) => {
    const newRows = [];
    results.forEach(rule => {
      const { name, architecture } = rule
      const cells = [
        { title: name },
        { title: architecture || "All architectures" }, // Should we say "All Architectures"?
        { title: versionText(rule) },
      ];

      newRows.push({ cells });
    });

    return newRows;
  }

  useEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [JSON.stringify(response)]);

  const emptyContentTitle = __('No rules have been added to this filter.');
  const emptyContentBody = __("Add to this filter using the 'Add RPM' button.");
  const emptySearchTitle = __('No matching rules found.');
  const emptySearchBody = __('Try changing your search settings.');
  const tabTitle = (inclusion ? __('Included') : __('Excluded')) + __(" RPMs");

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
            }}
            status={status}
            onSelect={onSelect(rows, setRows)}
            cells={columnHeaders}
            variant={TableVariant.compact}
            autocompleteEndpoint={`/content_view_filter_rules/${filterId}/rules/auto_complete_search`}
            fetchItems={params => getCVFilterRules(filterId, params)}
          />
        </div>
      </Tab>
    </Tabs>
  );
}

export default CVRpmFilterContent;