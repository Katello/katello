import React from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { Table /* data-codemods */, Thead, Tr, Th, Tbody, Td } from '@patternfly/react-table';
import { CheckCircleIcon, TimesCircleIcon } from '@patternfly/react-icons';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { useSet } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import ContentViewIcon from '../ContentViews/components/ContentViewIcon';
import ExpandedSmartProxyRepositories from './ExpandedSmartProxyRepositories';
import { updateSmartProxyContentCounts, repairSmartProxyContent } from './SmartProxyContentActions';

const ExpandableCvDetails = ({
  smartProxyId, contentViews, contentCounts, envId,
}) => {
  const columnHeaders = [
    __('Content view'),
    __('Version'),
    __('Last published'),
    __('Synced'),
  ];
  const dispatch = useDispatch();
  const expandedTableRows = useSet([]);
  const tableRowIsExpanded = id => expandedTableRows.has(id);
  const refreshCountAction = cvId => ({
    title: __('Refresh counts'),
    onClick: () => {
      dispatch(updateSmartProxyContentCounts(smartProxyId, {
        environment_id: envId, content_view_id: cvId,
      }));
    },
  });
  const repairContentAction = cvId => ({
    title: __('Verify Content Checksum'),
    onClick: () => {
      dispatch(repairSmartProxyContent(smartProxyId, {
        environment_id: envId, content_view_id: cvId,
      }));
    },
  });

  const anyRepoInEnv = (repositories) => {
    if (repositories && Object.values(repositories)) {
      return Object.values(repositories).some(repo => repo.metadata.env_id === envId);
    }
    return false;
  };

  const getSyncedToCapsuleStatus = (upToDate, versionId) => {
    if (upToDate) return upToDate;
    if (anyRepoInEnv(contentCounts?.content_view_versions?.[versionId]?.repositories)) return 'partial';
    return false;
  };

  return (
    <Table
      aria-label="expandable-content-views"
      ouiaId="expandable-content-views"
    >
      <Thead>
        <Tr ouiaId="column-headers">
          <Th aria-label="select header" />
          {columnHeaders.map(col => (
            <Th
              key={col}
            >
              {col}
            </Th>
          ))}
        </Tr>
      </Thead>
      {contentViews.map((cv, rowIndex) => {
        const {
          id, name: cvName, composite, rolling, up_to_date: upToDate,
          cvv_id: versionId, cvv_version: version, repositories,
        } = cv;
        let upToDateVal;
        if (upToDate === true) {
          upToDateVal = <CheckCircleIcon style={{ color: 'green' }} />;
        } else {
          upToDateVal = <TimesCircleIcon style={{ color: 'red' }} />;
        }

        const isExpanded = tableRowIsExpanded(versionId);
        return (
          <Tbody key={`${id} + ${versionId}`}isExpanded={isExpanded}>
            <Tr key={versionId} ouiaId={cv.name}>
              <Td
                aria-label={`expand-cv-${id}`}
                style={{ paddingTop: 0 }}
                expand={{
                  rowIndex,
                  isExpanded,
                  onToggle: (_event, _rInx, isOpen) =>
                    expandedTableRows.onToggle(isOpen, versionId),
                }}
              />
              <Td>
                <ContentViewIcon
                  composite={composite}
                  rolling={rolling}
                  description={<a href={cv.default ? urlBuilder('products', '') : urlBuilder('content_views', '', id)}>{cvName}</a>}
                />
              </Td>
              <Td>
                <a href={`/content_views/${id}#/versions/${versionId}/`}>{__('Version ')}{version}</a>
              </Td>
              <Td><LongDateTime date={cv.last_published} showRelativeTimeTooltip /></Td>
              <Td>{upToDateVal}</Td>
              <Td
                key={`rowActions-${id}`}
                actions={{
                  items: [refreshCountAction(id), repairContentAction(id)],
                }}
              />
            </Tr>
            <Tr key="child_row" ouiaId={`ContentViewTableRowChild-${id}`} isExpanded={isExpanded}>
              <Td colSpan={12}>
                <ExpandedSmartProxyRepositories
                  contentCounts={contentCounts?.content_view_versions?.[versionId]?.repositories}
                  repositories={repositories}
                  syncedToCapsule={getSyncedToCapsuleStatus(upToDate, versionId)}
                  envId={envId}
                />
              </Td>
            </Tr>
          </Tbody>
        );
      })}

    </Table>

  );
};

ExpandableCvDetails.propTypes = {
  smartProxyId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]).isRequired,
  contentViews: PropTypes.arrayOf(PropTypes.shape({})),
  contentCounts: PropTypes.shape({
    content_view_versions: PropTypes.shape({}),
  }),
  envId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string, // The API can sometimes return strings
  ]).isRequired,
};

ExpandableCvDetails.defaultProps = {
  contentViews: [],
  contentCounts: {},
};

export default ExpandableCvDetails;
