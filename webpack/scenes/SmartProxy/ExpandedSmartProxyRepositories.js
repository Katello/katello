/* eslint-disable react/no-array-index-key */
import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { DataList, DataListItem, DataListItemRow, DataListItemCells, DataListCell } from '@patternfly/react-core';
import AdditionalCapsuleContent from './AdditionalCapsuleContent';

const ExpandedSmartProxyRepositories = ({ contentCounts, repositories }) => {
  const getRepositoryNameById = id => (repositories.find(repo =>
    Number(repo.id) === Number(id)) || {}).name;

  const dataListCellLists = (repo) => {
    const cellList = [];
    /* eslint-disable max-len */
    cellList.push(<DataListCell key={`${repo.id}-name`}><span>{getRepositoryNameById(repo)}</span></DataListCell>);
    cellList.push(<DataListCell key={`${repo.id}-rpm`}><span>{contentCounts[repo].rpm ? `${contentCounts[repo].rpm} Packages` : 'N/A'}</span></DataListCell>);
    cellList.push(<DataListCell key={`${repo.id}-count`}><AdditionalCapsuleContent counts={contentCounts[repo]} /></DataListCell>);
    /* eslint-enable max-len */
    return cellList;
  };
  return (
    <DataList aria-label="Expanded repository details" isCompact>
      <DataListItem key="headers" >
        <DataListItemRow>
          <DataListItemCells dataListCells={[
            <DataListCell key="primary content">
              <b>{__('Repositories')}</b>
            </DataListCell>,
            <DataListCell key="Packages"><b>{__('Packages')}</b></DataListCell>,
            <DataListCell key="Additional Content"><b>{__('Additional Content')}</b></DataListCell>,
          ]}
          />
        </DataListItemRow>
      </DataListItem>
      {Object.keys(contentCounts).map((repo, index) => (
        <DataListItem key={`${repo.id}-${index}`}>
          <DataListItemRow>
            <DataListItemCells dataListCells={dataListCellLists(repo)} />
          </DataListItemRow>
        </DataListItem>
      ))}
    </DataList>
  );
};

ExpandedSmartProxyRepositories.propTypes = {
  contentCounts: PropTypes.shape({}),
  repositories: PropTypes.arrayOf(PropTypes.shape({})),
};

ExpandedSmartProxyRepositories.defaultProps = {
  contentCounts: {},
  repositories: [{}],
};

export default ExpandedSmartProxyRepositories;
