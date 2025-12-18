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

    // Helper to check if a node will be visible (for setsize calculation)
    const isNodeVisible = (node) => {
      if (!showActiveOnly) return true;
      if (node.type === 'repo') {
        const status = repoStatuses[node.id];
        return status?.is_running;
      }
      // For non-repo nodes, they're visible if shown
      return true;
    };

    const addRow = (node, level, parent, posinset, ariaSetSize, isHidden) => {
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
        ariaSetSize,
        isHidden,
        hasChildren,
        isExpanded,
      });

      if (hasChildren && !isHidden) {
        const childrenToRender = node.children || [];
        const reposToRender = node.repos || [];
        const allChildren = [...childrenToRender, ...reposToRender];

        // Calculate visible siblings for aria-setsize
        const visibleChildren = allChildren.filter(isNodeVisible);
        const visibleCount = visibleChildren.length;

        allChildren.forEach((child, idx) => {
          // Use position among all children for posinset, but visible count for setsize
          addRow(child, level + 1, nodeId, idx + 1, visibleCount, !isExpanded || isHidden);
        });
      }
    };

    // For root products, calculate visible products
    const visibleProducts = products.filter(isNodeVisible);
    products.forEach((product, idx) => {
      addRow(product, 1, null, idx + 1, visibleProducts.length, false);
    });

    return rows;
  }, [products, expandedNodeIds, showActiveOnly, repoStatuses]);

  // Filter rows based on active only setting
  const visibleRows = useMemo(() => {
    if (!showActiveOnly) return buildTreeRows;

    // Build parent->children map
    const parentToChildren = {};
    buildTreeRows.forEach((row) => {
      if (row.parent) {
        if (!parentToChildren[row.parent]) parentToChildren[row.parent] = [];
        parentToChildren[row.parent].push(row);
      }
    });

    // Recursive helper functions for visibility checking
    // hasVisibleChildren must be defined before isRowVisible due to ESLint rules
    function hasVisibleChildren(row) {
      const children = parentToChildren[row.nodeId] || [];
      // eslint-disable-next-line no-use-before-define
      return children.some(child => isRowVisible(child));
    }

    // Check if a row should be visible
    function isRowVisible(row) {
      if (row.type === 'repo') {
        const status = repoStatuses[row.id];
        return status?.is_running;
      }
      // For non-repo nodes (product, minor, arch), visible if has visible children
      return hasVisibleChildren(row);
    }

    return buildTreeRows.filter(row => isRowVisible(row));
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

    // Helper to get controlled checkbox value (never undefined, supports null for indeterminate)
    const getRepoCheckboxValue = () => {
      if (status?.is_running) return false;
      // Repo checkboxes only need true/false (no indeterminate), so use Boolean()
      return Boolean(isRepoSelected);
    };

    const getNodeCheckboxValue = () => {
      if (!nodeCheckboxState) return false;
      if (nodeCheckboxState.isIndeterminate) return null;
      const { isChecked } = nodeCheckboxState;
      // Explicitly convert to boolean, except preserve null for indeterminate
      return isChecked === true;
    };

    // Build treeRow props - minimal for leaf nodes, full for expandable nodes
    const treeRow = row.hasChildren ? {
      onCollapse: () => toggleExpand(row.nodeId),
      props: {
        'aria-level': row.level,
        'aria-posinset': row.posinset,
        'aria-setsize': row.ariaSetSize || 0,
        isExpanded: row.isExpanded,
        isHidden: row.isHidden,
      },
    } : {
      props: {
        'aria-level': row.level,
        'aria-posinset': row.posinset,
        'aria-setsize': 0, // MUST be 0 for leaf nodes to hide expand button
        isHidden: row.isHidden,
      },
    };

    return (
      <TreeRowWrapper
        key={row.nodeId}
        row={row.hasChildren ? treeRow : { props: treeRow.props }}
      >
        <Td dataLabel={__('Name')} treeRow={treeRow}>
          {isRepo && (
            <Checkbox
              id={`checkbox-${row.id}`}
              isChecked={getRepoCheckboxValue()}
              isDisabled={status?.is_running}
              onChange={() => onSelectRepo(row.id, row)}
              aria-label={__('Select repository')}
              ouiaId={`checkbox-${row.id}`}
            />
          )}
          {isSelectableNode && (
            <Checkbox
              id={`checkbox-${row.type}-${row.id}`}
              isChecked={getNodeCheckboxValue()}
              onChange={() => onSelectProduct(row)}
              aria-label={__('Select node')}
              ouiaId={`checkbox-${row.type}-${row.id}`}
            />
          )}
          <span
            role="button"
            tabIndex={0}
            onClick={() => {
              if (isRepo && !status?.is_running) {
                onSelectRepo(row.id, row);
              } else if (isSelectableNode) {
                onSelectProduct(row);
              }
            }}
            onKeyPress={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                if (isRepo && !status?.is_running) {
                  onSelectRepo(row.id, row);
                } else if (isSelectableNode) {
                  onSelectProduct(row);
                }
              }
            }}
            style={{
              cursor: (isRepo && status?.is_running) ? 'default' : 'pointer',
              marginLeft: (isRepo || isSelectableNode) ? '0.5rem' : '0',
            }}
          >
            {row.name}
          </span>
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
