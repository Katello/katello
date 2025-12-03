import React, { useState, useEffect, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  PageSection,
  PageSectionVariants,
  Title,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import Loading from 'foremanReact/components/Loading';
import { useSelectionSet } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import {
  getSyncStatus,
  pollSyncStatus,
  syncRepositories,
  cancelSync,
} from './SyncStatusActions';
import {
  selectSyncStatus,
  selectSyncStatusStatus,
  selectSyncStatusPoll,
} from './SyncStatusSelectors';
import SyncStatusToolbar from './components/SyncStatusToolbar';
import SyncStatusTable from './components/SyncStatusTable';
import './SyncStatus.scss';

const POLL_INTERVAL = 5000; // Poll every 5 seconds

const SyncStatusPage = () => {
  const dispatch = useDispatch();
  const syncStatusData = useSelector(selectSyncStatus);
  const syncStatusStatus = useSelector(selectSyncStatusStatus);
  const pollData = useSelector(selectSyncStatusPoll);

  const [expandedNodeIds, setExpandedNodeIds] = useState([]);
  const [showActiveOnly, setShowActiveOnly] = useState(false);
  const [repoStatuses, setRepoStatuses] = useState({});
  const [isSyncing, setIsSyncing] = useState(false);

  // Flatten tree to get all repos for selection
  const allRepos = useMemo(() => {
    const repos = [];
    const traverse = (nodes) => {
      nodes.forEach((node) => {
        if (node.type === 'repo') {
          repos.push(node);
        }
        if (node.children) traverse(node.children);
        if (node.repos) traverse(node.repos);
      });
    };
    if (syncStatusData?.products) {
      traverse(syncStatusData.products);
    }
    return repos;
  }, [syncStatusData]);

  // Use selection hook from Foreman
  const {
    selectOne,
    selectPage,
    selectNone,
    selectedCount,
    areAllRowsSelected,
    isSelected,
    selectionSet,
  } = useSelectionSet({
    results: allRepos,
    metadata: { selectable: allRepos.length },
    isSelectable: () => true,
  });

  // Get selected repo IDs from selectionSet
  const selectedRepoIds = Array.from(selectionSet);

  // Use refs for mutable values that don't need to trigger re-renders
  const repoStatusesRef = React.useRef(repoStatuses);
  const pollTimerRef = React.useRef(null);
  const hasAutoExpandedRef = React.useRef(false);

  // Update ref whenever repo statuses change
  useEffect(() => {
    repoStatusesRef.current = repoStatuses;
  }, [repoStatuses]);

  // Load initial data
  useEffect(() => {
    dispatch(getSyncStatus());
  }, [dispatch]);

  // Update repo statuses when initial data loads
  useEffect(() => {
    if (syncStatusData?.repo_statuses) {
      setRepoStatuses(syncStatusData.repo_statuses);
    }
  }, [syncStatusData]);

  // Update repo statuses from poll data
  useEffect(() => {
    if (pollData && Array.isArray(pollData)) {
      setRepoStatuses((prev) => {
        const updated = { ...prev };
        pollData.forEach((status) => {
          if (status.id) {
            updated[status.id] = status;
          }
        });
        return updated;
      });
    }
  }, [pollData]);

  // Auto-expand tree to show syncing repos on initial load (only once)
  useEffect(() => {
    // Only run once, and only if we haven't auto-expanded yet
    if (hasAutoExpandedRef.current) {
      return;
    }

    if (!syncStatusData?.products || !repoStatuses || Object.keys(repoStatuses).length === 0) {
      return;
    }

    // Mark that we've attempted auto-expand (even if no syncing repos found)
    hasAutoExpandedRef.current = true;

    // Find all syncing repo IDs
    const syncingRepoIds = Object.entries(repoStatuses)
      .filter(([_, status]) => status?.is_running === true)
      .map(([id]) => parseInt(id, 10));

    if (syncingRepoIds.length === 0) {
      return;
    }

    // Traverse tree and collect ancestor node IDs for syncing repos
    const ancestorNodeIds = new Set();

    const findAncestors = (nodes, ancestors = []) => {
      nodes.forEach((node) => {
        const currentAncestors = [...ancestors];
        const nodeId = `${node.type}-${node.id}`;

        // If this is a syncing repo, add all ancestors
        if (node.type === 'repo' && syncingRepoIds.includes(node.id)) {
          currentAncestors.forEach(ancestorId => ancestorNodeIds.add(ancestorId));
        }

        // Add current node to ancestors if it has children
        if (node.children || node.repos) {
          currentAncestors.push(nodeId);
        }

        // Recursively check children
        if (node.children) {
          findAncestors(node.children, currentAncestors);
        }
        if (node.repos) {
          findAncestors(node.repos, currentAncestors);
        }
      });
    };

    findAncestors(syncStatusData.products);

    // Only update if we found ancestors to expand
    if (ancestorNodeIds.size > 0) {
      setExpandedNodeIds(Array.from(ancestorNodeIds));
    }
  }, [syncStatusData, repoStatuses]);


  // Start/stop polling based on whether there are active syncs
  useEffect(() => {
    const syncingIds = Object.entries(repoStatuses)
      .filter(([_, status]) => status?.is_running === true)
      .map(([id]) => parseInt(id, 10));

    if (syncingIds.length > 0 && !pollTimerRef.current) {
      // Start polling
      pollTimerRef.current = setInterval(() => {
        // Use ref to get current repo statuses instead of stale closure value
        const currentSyncingIds = Object.entries(repoStatusesRef.current)
          .filter(([_, status]) => status?.is_running === true)
          .map(([id]) => parseInt(id, 10));
        if (currentSyncingIds.length > 0) {
          dispatch(pollSyncStatus(currentSyncingIds));
        } else {
          // No more syncing repos, clear the timer
          clearInterval(pollTimerRef.current);
          pollTimerRef.current = null;
        }
      }, POLL_INTERVAL);
    } else if (syncingIds.length === 0 && pollTimerRef.current) {
      // Stop polling
      clearInterval(pollTimerRef.current);
      pollTimerRef.current = null;
    }

    // Cleanup on unmount
    return () => {
      if (pollTimerRef.current) {
        clearInterval(pollTimerRef.current);
        pollTimerRef.current = null;
      }
    };
  }, [repoStatuses, dispatch]);

  const handleSelectRepo = (repoId, repoData) => {
    const isCurrentlySelected = isSelected(repoId);
    selectOne(!isCurrentlySelected, repoId, repoData);
  };

  // Product selection handler - selects/deselects all child repos
  const handleSelectProduct = (product) => {
    // Get all child repo IDs and all descendant node IDs
    const childRepos = [];
    const descendantNodeIds = [];
    const getChildRepos = (node) => {
      const nodeId = `${node.type}-${node.id}`;
      // Track all nodes with children (products, minors, archs)
      if (node.children || node.repos) {
        descendantNodeIds.push(nodeId);
      }
      if (node.type === 'repo') {
        childRepos.push(node);
      }
      if (node.children) {
        node.children.forEach(getChildRepos);
      }
      if (node.repos) {
        node.repos.forEach(getChildRepos);
      }
    };
    getChildRepos(product);

    // Check if all children are selected
    const allChildrenSelected = childRepos.length > 0 &&
      childRepos.every(repo => isSelected(repo.id));

    if (allChildrenSelected) {
      // Deselect all children
      childRepos.forEach(repo => selectOne(false, repo.id, repo));
    } else {
      // Select all children and expand all descendant nodes to show selected children
      childRepos.forEach(repo => selectOne(true, repo.id, repo));
      // Auto-expand all descendant nodes
      setExpandedNodeIds((prev) => {
        const newExpanded = [...prev];
        descendantNodeIds.forEach((nodeId) => {
          if (!newExpanded.includes(nodeId)) {
            newExpanded.push(nodeId);
          }
        });
        return newExpanded;
      });
    }
  };

  const handleExpandAll = () => {
    const allNodeIds = [];
    const traverse = (nodes) => {
      nodes.forEach((node) => {
        if (node.children || node.repos) {
          allNodeIds.push(`${node.type}-${node.id}`);
        }
        if (node.children) traverse(node.children);
      });
    };
    if (syncStatusData?.products) {
      traverse(syncStatusData.products);
    }
    setExpandedNodeIds(allNodeIds);
  };

  const handleCollapseAll = () => {
    setExpandedNodeIds([]);
  };

  const handleSyncNow = () => {
    if (selectedRepoIds.length > 0) {
      setIsSyncing(true);
      dispatch(syncRepositories(
        selectedRepoIds,
        (response) => {
          setIsSyncing(false);
          // Update repo statuses immediately from sync response
          if (response?.data && Array.isArray(response.data)) {
            setRepoStatuses((prev) => {
              const updated = { ...prev };
              response.data.forEach((status) => {
                if (status.id) {
                  updated[status.id] = status;
                }
              });
              return updated;
            });
          }
          // Also poll immediately to get latest status
          dispatch(pollSyncStatus(selectedRepoIds));
        },
        () => {
          // Error handler - reset syncing state
          setIsSyncing(false);
        },
      ));
    }
  };

  const handleCancelSync = (repoId) => {
    dispatch(cancelSync(repoId, () => {
      // Refresh status after cancel
      dispatch(pollSyncStatus([repoId]));
    }));
  };

  const handleToggleActiveOnly = () => {
    setShowActiveOnly(prev => !prev);
  };

  // Single repository sync handler
  const handleSyncRepo = (repoId) => {
    setIsSyncing(true);
    dispatch(syncRepositories(
      [repoId],
      (response) => {
        setIsSyncing(false);
        // Update repo statuses immediately from sync response
        if (response?.data && Array.isArray(response.data)) {
          setRepoStatuses((prev) => {
            const updated = { ...prev };
            response.data.forEach((status) => {
              if (status.id) {
                updated[status.id] = status;
              }
            });
            return updated;
          });
        }
        // Also poll immediately to get latest status
        dispatch(pollSyncStatus([repoId]));
      },
      () => {
        // Error handler - reset syncing state
        setIsSyncing(false);
      },
    ));
  };

  if (syncStatusStatus === STATUS.PENDING) {
    return <Loading />;
  }

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <Title headingLevel="h1" ouiaId="sync-status-title">{__('Sync Status')}</Title>
      </PageSection>
      <PageSection variant={PageSectionVariants.default} padding={{ default: 'noPadding' }}>
        <SyncStatusToolbar
          selectedRepoIds={selectedRepoIds}
          onSyncNow={handleSyncNow}
          showActiveOnly={showActiveOnly}
          onToggleActiveOnly={handleToggleActiveOnly}
          isSyncDisabled={isSyncing}
          selectAllCheckboxProps={{
            selectNone,
            selectAll: selectPage, // No pagination, so selectAll = selectPage
            selectedCount,
            totalCount: allRepos.length,
            areAllRowsSelected: areAllRowsSelected(),
          }}
        />
        <SyncStatusTable
          products={syncStatusData?.products || []}
          repoStatuses={repoStatuses}
          selectedRepoIds={selectedRepoIds}
          onSelectRepo={handleSelectRepo}
          onSelectProduct={handleSelectProduct}
          onSyncRepo={handleSyncRepo}
          onCancelSync={handleCancelSync}
          expandedNodeIds={expandedNodeIds}
          setExpandedNodeIds={setExpandedNodeIds}
          showActiveOnly={showActiveOnly}
          isSelected={isSelected}
          onExpandAll={handleExpandAll}
          onCollapseAll={handleCollapseAll}
        />
      </PageSection>
    </>
  );
};

export default SyncStatusPage;
