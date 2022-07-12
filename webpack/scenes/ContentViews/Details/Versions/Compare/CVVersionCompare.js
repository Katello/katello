import React, { useCallback, useState } from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid } from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { TimesIcon, CheckIcon } from '@patternfly/react-icons';
import CVVersionCompareHeader from './CVVersionCompareHeader';
import { selectPackagesComparison, selectPackagesComparisonError, selectPackagesComparisonStatus, selectCVDetails } from '../../ContentViewDetailSelectors';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { getRPMPackagesCompare } from '../../ContentViewDetailActions';

const CVVersionCompare = ({
  cvId,
  versionIds,
}) => {
  const emptyContentTitle = __("You currently don't have any packages for this content view.");
  const emptyContentBody = __('Packages will appear here when the content view is published or promoted.');
  const emptySearchTitle = __('No matching history record found');
  const emptySearchBody = __('Try changing your search settings.');
  const [searchQuery, updateSearchQuery] = useState('');
  const { versionOneId: initialVersionOneId, versionTwoId: initialVersionTwoId } = versionIds;
  const { versions: cvDetails } = useSelector(state => selectCVDetails(state, cvId));
  const [versionOne, setVersionOne] = useState(String(cvDetails?.find(version =>
    Number(version.id) === Number(initialVersionOneId)).version));
  const [versionTwo, setVersionTwo] = useState(String(cvDetails?.find(version =>
    Number(version.id) === Number(initialVersionTwoId)).version));
  const getIdFromVersion = useCallback(version =>
    String(cvDetails?.find(result => Number(result.version) === Number(version)).id), [cvDetails]);

  const response = useSelector(state =>
    selectPackagesComparison(state, getIdFromVersion(versionOne), getIdFromVersion(versionTwo)));
  const status = useSelector(state =>
    selectPackagesComparisonStatus(
      state,
      getIdFromVersion(versionOne),
      getIdFromVersion(versionTwo),
    ));
  const error = useSelector(state =>
    selectPackagesComparisonError(
      state,
      getIdFromVersion(versionOne),
      getIdFromVersion(versionTwo),
    ));

  const { results, ...metadata } = response;
  const columnHeaders = [
    __('Name'),
    __(`Version ${versionOne}`),
    __(`Version ${versionTwo}`),
  ];
  return (
    <Grid>
      <CVVersionCompareHeader
        versionOne={versionOne}
        versionTwo={versionTwo}
        cvId={cvId}
        setVersionOne={setVersionOne}
        setVersionTwo={setVersionTwo}
      />
      <TableWrapper
        {...{
          metadata,
          emptyContentTitle,
          emptyContentBody,
          emptySearchTitle,
          emptySearchBody,
          error,
          status,
          searchQuery,
          updateSearchQuery,
        }}
        ouiaId="content-view-history-table"
        variant={TableVariant.compact}
        autocompleteEndpoint="/packages/auto_complete_search"
        additionalListeners={[versionOne, versionTwo]}
        fetchItems={useCallback(
          params =>
            getRPMPackagesCompare(
              getIdFromVersion(versionOne),
              getIdFromVersion(versionTwo),
              params,
            ),
          [versionOne, versionTwo, getIdFromVersion],
        )}
      >
        <Thead>
          <Tr>
            {columnHeaders.map(col =>
              <Th key={col}>{col}</Th>)}
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((data) => {
            const {
              id,
              nvrea,
              comparison,
            } = data;
            if (comparison?.length === 2) {
              return (
                <Tr key={id}>
                  <Td>{nvrea}</Td>
                  <Th isStickyColumn hasRightBorder modifier="truncate">
                    <CheckIcon />
                  </Th>
                  <Th isStickyColumn modifier="truncate">
                    <CheckIcon />
                  </Th>
                </Tr>
              );
            } else if (Number(comparison?.[0]) === Number(versionOne)) {
              return (
                <Tr key={id}>
                  <Td>{nvrea}</Td>
                  <Th isStickyColumn hasRightBorder modifier="truncate">
                    <CheckIcon />
                  </Th>
                  <Th isStickyColumn hasRightBorder modifier="truncate">
                    <TimesIcon />
                  </Th>
                </Tr>
              );
            }
            return (
              <Tr key={id}>
                <Td>{nvrea}</Td>
                { }
                <Th isStickyColumn hasRightBorder modifier="truncate">
                  <TimesIcon />
                </Th>
                <Th isStickyColumn hasRightBorder modifier="truncate">
                  <CheckIcon />
                </Th>
              </Tr>
            );
          })
          }
        </Tbody>

      </TableWrapper>
    </Grid >
  );
};
CVVersionCompare.propTypes = {
  cvId: PropTypes.number.isRequired,
  versions: PropTypes.shape({
    versionOne: PropTypes.string,
    versionTwo: PropTypes.string,
  }),
  versionIds: PropTypes.shape({
    versionOneId: PropTypes.string,
    versionTwoId: PropTypes.string,
  }),
  selectedVersionListeners: PropTypes.shape({
    setVersionOneId: PropTypes.func,
    setVersionTwoId: PropTypes.func,
  }),
};

CVVersionCompare.defaultProps = {
  versions: {},
  versionIds: {},
  selectedVersionListeners: {},
};

export default CVVersionCompare;
