import React, { useState, useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import {
  Table,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  TreeRowWrapper,
} from '@patternfly/react-table';
import { Checkbox } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import SyncProgressCell from './SyncProgressCell';
import SyncResultCell from './SyncResultCell';

const SyncStatusTable = ({
  products,
  repoStatuses,
  selectedRepoIds,
  onSelectRepo,
  onCancelSync,
  expandedNodeIds,
  setExpandedNodeIds,
  showActiveOnly,
}) => {
  // Build flat list of all tree nodes with their hierarchy info
  const buildTreeRows = useMemo(() => {
    const rows = [];

    const addRow = (node, level, parent, posinset, isHidden) => {
      const nodeId = `${node.type}-${node.id}`;
      const hasChildren = (node.children && node.children.length > 0) ||
                          (node.repos && node.repos.length > 0);
      const isExpanded = expandedNodeIds.includes(nodeId);

      rows.push({
        ...node,
        nodeId,
        level,
        parent,
        posinset,
        isHidden,
        hasChildren,
        isExpanded,
      });

      if (hasChildren && !isHidden) {
        const childrenToRender = node.children || [];
        const reposToRender = node.repos || [];
        const allChildren = [...childrenToRender, ...reposToRender];

        allChildren.forEach((child, idx) => {
          addRow(child, level + 1, nodeId, idx + 1, !isExpanded || isHidden);
        });
      }
    };

    products.forEach((product, idx) => {
      addRow(product, 1, null, idx + 1, false);
    });

    return rows;
  }, [products, expandedNodeIds]);

  // Filter rows based on active only setting
  const visibleRows = useMemo(() => {
    if (!showActiveOnly) return buildTreeRows;

    return buildTreeRows.filter(row => {
      if (row.type !== 'repo') return true;
      const status = repoStatuses[row.id];
      return status?.is_running;
    });
  }, [buildTreeRows, showActiveOnly, repoStatuses]);

  const toggleExpand = (nodeId) => {
    setExpandedNodeIds(prev => {
      if (prev.includes(nodeId)) {
        return prev.filter(id => id !== nodeId);
      }
      return [...prev, nodeId];
    });
  };

  const renderRow = (row) => {
    const isRepo = row.type === 'repo';
    const status = isRepo ? repoStatuses[row.id] : null;
    const isSelected = isRepo && selectedRepoIds.includes(row.id);

    const treeRow = {
      props: {
        isExpanded: row.isExpanded,
        isHidden: row.isHidden,
        'aria-level': row.level,
        'aria-posinset': row.posinset,
        'aria-setsize': row.hasChildren ? (row.children?.length || 0) + (row.repos?.length || 0) : 0,
      },
    };

    // Only add onCollapse for nodes with children
    if (row.hasChildren) {
      treeRow.onCollapse = () => toggleExpand(row.nodeId);
    }

    return (
      <TreeRowWrapper
        key={row.nodeId}
        row={{ props: treeRow.props }}
      >
        <Td
          treeRow={treeRow}
          dataLabel={__('Name')}
        >
          {isRepo && (
            <Checkbox
              id={`checkbox-${row.id}`}
              isChecked={isSelected}
              onChange={() => onSelectRepo(row.id)}
              aria-label={__('Select repository')}
            />
          )}
          {' '}
          {row.name}
          {row.organization && ` (${row.organization})`}
        </Td>
        <Td dataLabel={__('Start Time')}>
          {isRepo && status?.start_time}
        </Td>
        <Td dataLabel={__('Duration')}>
          {isRepo && !status?.is_running && status?.duration}
        </Td>
        <Td dataLabel={__('Details')}>
          {isRepo && status?.display_size}
        </Td>
        <Td dataLabel={__('Progress / Result')}>
          {isRepo && status && (
            <>
              {status.is_running && (
                <SyncProgressCell repo={status} onCancelSync={onCancelSync} />
              )}
              {!status.is_running && (
                <SyncResultCell repo={status} />
              )}
            </>
          )}
        </Td>
      </TreeRowWrapper>
    );
  };

  return (
    <Table
      aria-label={__('Sync Status')}
      variant="compact"
      isTreeTable
    >
      <Thead>
        <Tr>
          <Th>{__('Product / Repository')}</Th>
          <Th>{__('Start Time')}</Th>
          <Th>{__('Duration')}</Th>
          <Th>{__('Details')}</Th>
          <Th>{__('Progress / Result')}</Th>
        </Tr>
      </Thead>
      <Tbody>
        {visibleRows.map(row => renderRow(row))}
      </Tbody>
    </Table>
  );
};

SyncStatusTable.propTypes = {
  products: PropTypes.arrayOf(PropTypes.object).isRequired,
  repoStatuses: PropTypes.objectOf(PropTypes.object).isRequired,
  selectedRepoIds: PropTypes.arrayOf(PropTypes.number).isRequired,
  onSelectRepo: PropTypes.func.isRequired,
  onCancelSync: PropTypes.func.isRequired,
  expandedNodeIds: PropTypes.arrayOf(PropTypes.string).isRequired,
  setExpandedNodeIds: PropTypes.func.isRequired,
  showActiveOnly: PropTypes.bool.isRequired,
};

export default SyncStatusTable;
