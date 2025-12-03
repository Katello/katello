import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import {
  Table,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  TreeRowWrapper,
  ActionsColumn,
} from '@patternfly/react-table';
import { Checkbox } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import SyncProgressCell from './SyncProgressCell';
import SyncResultCell from './SyncResultCell';

const SyncStatusTable = ({
  products,
  repoStatuses,
  onSelectRepo,
  onSelectProduct,
  onSyncRepo,
  onCancelSync,
  expandedNodeIds,
  setExpandedNodeIds,
  showActiveOnly,
  isSelected,
  onExpandAll,
  onCollapseAll,
}) => {
  // Helper to get all child repos of a product/node
  const getChildRepos = (node) => {
    const repos = [];
    const traverse = (n) => {
      if (n.type === 'repo') {
        repos.push(n);
      }
      if (n.children) n.children.forEach(traverse);
      if (n.repos) n.repos.forEach(traverse);
    };
    traverse(node);
    return repos;
  };

  // Calculate node checkbox state (works for product, minor, arch)
  const getNodeCheckboxState = (node) => {
    const childRepos = getChildRepos(node);
    if (childRepos.length === 0) {
      return { isChecked: false, isIndeterminate: false };
    }

    const selectedCount = childRepos.filter(repo => isSelected(repo.id)).length;

    if (selectedCount === 0) {
      return { isChecked: false, isIndeterminate: false };
    }
    if (selectedCount === childRepos.length) {
      return { isChecked: true, isIndeterminate: false };
    }
    return { isChecked: false, isIndeterminate: true };
  };

  // Calculate total expandable nodes
  const totalExpandableNodes = useMemo(() => {
    let count = 0;
    const traverse = (nodes) => {
      nodes.forEach((node) => {
        if ((node.children && node.children.length > 0) ||
            (node.repos && node.repos.length > 0)) {
          count += 1;
        }
        if (node.children) traverse(node.children);
      });
    };
    traverse(products);
    return count;
  }, [products]);

  const allNodesExpanded = expandedNodeIds.length === totalExpandableNodes &&
    totalExpandableNodes > 0;
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

    return buildTreeRows.filter((row) => {
      if (row.type !== 'repo') return true;
      const status = repoStatuses[row.id];
      return status?.is_running;
    });
  }, [buildTreeRows, showActiveOnly, repoStatuses]);

  const toggleExpand = (nodeId) => {
    setExpandedNodeIds((prev) => {
      if (prev.includes(nodeId)) {
        return prev.filter(id => id !== nodeId);
      }
      return [...prev, nodeId];
    });
  };

  const renderRow = (row) => {
    const isRepo = row.type === 'repo';
    const isProduct = row.type === 'product';
    const isMinor = row.type === 'minor';
    const isArch = row.type === 'arch';
    const isSelectableNode = isProduct || isMinor || isArch;
    const status = isRepo ? repoStatuses[row.id] : null;
    const isRepoSelected = isRepo && isSelected(row.id);

    // Get checkbox state for selectable nodes
    const nodeCheckboxState = isSelectableNode ? getNodeCheckboxState(row) : null;

    const treeRow = {
      onCollapse: row.hasChildren ? () => toggleExpand(row.nodeId) : () => {},
      props: {
        'aria-level': row.level,
        'aria-posinset': row.posinset,
        'aria-setsize': row.hasChildren ? (row.children?.length || 0) + (row.repos?.length || 0) : 0,
        isExpanded: row.isExpanded,
        isHidden: row.isHidden,
      },
    };

    return (
      <TreeRowWrapper
        key={row.nodeId}
        row={treeRow}
      >
        <Td dataLabel={__('Name')} treeRow={treeRow}>
          {isRepo && (
            <Checkbox
              id={`checkbox-${row.id}`}
              isChecked={status?.is_running ? false : isRepoSelected}
              isDisabled={status?.is_running}
              onChange={() => onSelectRepo(row.id, row)}
              aria-label={__('Select repository')}
              ouiaId={`checkbox-${row.id}`}
            />
          )}
          {isSelectableNode && (
            <Checkbox
              id={`checkbox-${row.type}-${row.id}`}
              isChecked={
                nodeCheckboxState?.isIndeterminate
                  ? null
                  : (nodeCheckboxState?.isChecked || false)
              }
              onChange={() => onSelectProduct(row)}
              aria-label={__('Select node')}
              ouiaId={`checkbox-${row.type}-${row.id}`}
            />
          )}
          {' '}
          {row.name}
          {row.organization && ` (${row.organization})`}
        </Td>
        <Td dataLabel={__('Started at')}>
          {isRepo && status?.start_time && (
            <>
              {status.start_time}
              {!status.is_running && status.duration && ` - (${status.duration})`}
            </>
          )}
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
        {isRepo ? (
          <Td isActionCell>
            <ActionsColumn
              items={[
                {
                  title: __('Synchronize'),
                  onClick: () => onSyncRepo(row.id),
                  isDisabled: status?.is_running,
                },
              ]}
            />
          </Td>
        ) : (
          <Td />
        )}
      </TreeRowWrapper>
    );
  };

  return (
    <div style={{ paddingTop: '8px' }}>
      <Table
        aria-label={__('Sync Status')}
        variant="compact"
        isTreeTable
        isStickyHeader
        ouiaId="sync-status-table"
      >
      <Thead>
        <Tr ouiaId="sync-status-table-header">
          <Th
            width={40}
            expand={{
              areAllExpanded: !allNodesExpanded,
              collapseAllAriaLabel: __('Collapse all'),
              onToggle: () => {
                if (allNodesExpanded) {
                  onCollapseAll();
                } else {
                  onExpandAll();
                }
              },
            }}
          >
            {__('Product | Repository')}
          </Th>
          <Th>{__('Started at')}</Th>
          <Th>{__('Details')}</Th>
          <Th>{__('Progress / Result')}</Th>
          <Th aria-label={__('Actions')} />
        </Tr>
      </Thead>
      <Tbody>
        {visibleRows.map(row => renderRow(row))}
      </Tbody>
    </Table>
    </div>
  );
};

SyncStatusTable.propTypes = {
  products: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  repoStatuses: PropTypes.objectOf(PropTypes.shape({})).isRequired,
  onSelectRepo: PropTypes.func.isRequired,
  onSelectProduct: PropTypes.func.isRequired,
  onSyncRepo: PropTypes.func.isRequired,
  onCancelSync: PropTypes.func.isRequired,
  expandedNodeIds: PropTypes.arrayOf(PropTypes.string).isRequired,
  setExpandedNodeIds: PropTypes.func.isRequired,
  showActiveOnly: PropTypes.bool.isRequired,
  isSelected: PropTypes.func.isRequired,
  onExpandAll: PropTypes.func.isRequired,
  onCollapseAll: PropTypes.func.isRequired,
};

export default SyncStatusTable;
