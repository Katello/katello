import React, { useState, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import {
  Bullseye, Split, SplitItem, Button, ActionList,
  ActionListItem, Dropdown, DropdownItem, KebabToggle,
} from '@patternfly/react-core';
import { Link } from 'react-router-dom';
import { TableVariant, fitContent, TableText } from '@patternfly/react-table';
import { PencilAltIcon } from '@patternfly/react-icons';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import onSelect from '../../../../components/Table/helpers';
import {
  selectCVComponents,
  selectCVComponentsStatus,
  selectCVComponentsError,
  selectCVComponentAddStatus,
  selectCVComponentRemoveStatus,
} from '../ContentViewDetailSelectors';
import getContentViewDetails, {
  addComponent, getContentViewComponents,
  removeComponent,
} from '../ContentViewDetailActions';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import ComponentVersion from './ComponentVersion';
import ComponentEnvironments from './ComponentEnvironments';
import ContentViewIcon from '../../components/ContentViewIcon';
import { ADDED, ALL_STATUSES, CONTENT_VIEW_NEEDS_PUBLISH, NOT_ADDED } from '../../ContentViewsConstants';
import SelectableDropdown from '../../../../components/SelectableDropdown/SelectableDropdown';
import '../../../../components/EditableTextInput/editableTextInput.scss';
import ComponentContentViewAddModal from './ComponentContentViewAddModal';
import ComponentContentViewBulkAddModal from './ComponentContentViewBulkAddModal';
import { hasPermission } from '../../helpers';
import InactiveText from '../../components/InactiveText';


const ContentViewComponents = ({ cvId, details }) => {
  const response = useSelector(state => selectCVComponents(state, cvId));
  const status = useSelector(state => selectCVComponentsStatus(state, cvId));
  const error = useSelector(state => selectCVComponentsError(state, cvId));
  const { results, ...metadata } = response;
  const componentAddedStatus = useSelector(state => selectCVComponentAddStatus(state, cvId));
  const componentRemovedStatus = useSelector(state => selectCVComponentRemoveStatus(state, cvId));
  const [rows, setRows] = useState([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const [statusSelected, setStatusSelected] = useState(ALL_STATUSES);
  const [versionEditing, setVersionEditing] = useState(false);
  const [compositeCvEditing, setCompositeCvEditing] = useState(null);
  const [componentCvEditing, setComponentCvEditing] = useState(null);
  const [componentLatest, setComponentLatest] = useState(false);
  const [componentId, setComponentId] = useState(null);
  const [componentVersionId, setComponentVersionId] = useState(null);
  const [selectedComponentsToAdd, setSelectedComponentsToAdd] = useState(null);
  const [bulkAdding, setBulkAdding] = useState(false);
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const dispatch = useDispatch();
  const resetFilters = () => setStatusSelected(ALL_STATUSES);

  const columnHeaders = [
    { title: __('Type'), transforms: [fitContent] },
    { title: __('Name') },
    { title: __('Version') },
    { title: __('Environments') },
    { title: __('Repositories') },
    { title: __('Status') },
    { title: __('Description') },
  ];
  const loading = status === STATUS.PENDING;
  const addComponentsResolved = componentAddedStatus === STATUS.RESOLVED;
  const removeComponentsResolved = componentRemovedStatus === STATUS.RESOLVED;

  const { permissions } = details || {};

  const bulkRemoveEnabled = () => rows.some(row => row.selected && row.added);
  const bulkAddEnabled = () => rows.some(row => row.selected && !row.added);

  const onAdd = useCallback(({
    componentCvId, published, added, latest,
  }) => {
    if (published) { // If 1 or more versions present, open a modal to let user select version
      dispatch(getContentViewDetails(componentCvId, 'bulk_add'));
      setVersionEditing(true);
      setCompositeCvEditing(cvId);
      setComponentCvEditing(componentCvId);
      if (added) {
        setComponentVersionId(published?.id);
      } else {
        setComponentVersionId(null);
      }
      setComponentLatest(latest);
      setComponentId(added);
    } else { // if no versions are present, default to always latest and add cv without modal
      dispatch(addComponent({
        compositeContentViewId: cvId,
        components: [{ latest: true, content_view_id: componentCvId }],
      }, () => dispatch({ type: CONTENT_VIEW_NEEDS_PUBLISH })));
    }
  }, [cvId, dispatch]);

  const removeBulk = () => {
    const componentIds = [];
    rows.forEach(row => row.selected && componentIds.push(row.added));
    dispatch(removeComponent({
      compositeContentViewId: cvId,
      component_ids: componentIds,
    }, () => dispatch({ type: CONTENT_VIEW_NEEDS_PUBLISH })));
  };

  const addBulk = () => {
    const rowsToAdd = rows.filter(row => row.selected && !row.added);
    setSelectedComponentsToAdd(rowsToAdd);
    setCompositeCvEditing(cvId);
    setBulkAdding(true);
  };

  const onRemove = (componentIdToRemove) => {
    dispatch(removeComponent({
      compositeContentViewId: cvId,
      component_ids: [componentIdToRemove],
    }, () => dispatch({ type: CONTENT_VIEW_NEEDS_PUBLISH })));
  };

  const toggleBulkAction = () => {
    setBulkActionOpen(!bulkActionOpen);
  };

  const buildRows = useCallback(() => {
    const newRows = [];
    results.forEach((componentCV) => {
      const {
        id: componentCvId, content_view: cv, content_view_version: cvVersion,
        latest, component_content_view_versions: componentCvVersions,
      } = componentCV;
      const { environments, repositories } = cvVersion || {};
      const {
        id,
        name,
        description,
      } = cv;

      const cells = [
        { title: <Bullseye><ContentViewIcon composite={false} /></Bullseye> },
        { title: <a href={urlBuilder('content_views', '') + id}>{name}</a> },
        {
          title: (
            <Split>
              <SplitItem>
                <ComponentVersion {...{ componentCV }} />
              </SplitItem>
              {hasPermission(permissions, 'edit_content_views') && componentCvId && cvVersion &&
                <SplitItem>
                  <Button
                    ouiaId={`edit-component-version-${componentCvId}`}
                    className="katello-edit-icon foreman-edit-icon"
                    aria-label="edit_version"
                    variant="plain"
                    onClick={() => {
                      onAdd({
                        componentCvId: id, published: cvVersion, added: componentCvId, latest,
                      });
                    }}
                  >
                    <PencilAltIcon />
                  </Button>
                </SplitItem>}
            </Split>),
        },
        { title: environments ? <ComponentEnvironments {...{ environments }} /> : <InactiveText text={__('Not yet published')} /> },
        { title: <Link to={urlBuilder(`content_views/${id}#repositories`, '')}>{repositories ? repositories.length : 0}</Link> },
        {
          title: <AddedStatusLabel added={!!componentCvId} />,
        },
        {
          title: description ?
            <TableText wrapModifier="truncate">{description}</TableText> :
            <InactiveText text={__('No description')} />,
        },
      ];
      newRows.push({
        componentCvId: id,
        componentCvName: name,
        added: componentCvId,
        componentCvVersions,
        published: cvVersion,
        latest,
        cells,
      });
    });
    return newRows;
  }, [onAdd, results, permissions]);

  const actionResolver = (rowData, { _rowIndex }) => [
    {
      title: __('Add'),
      isDisabled: rowData.added,
      onClick: (_event, rowId, rowInfo) => {
        onAdd({
          componentCvId: rowInfo.componentCvId,
          published: rowInfo.published,
          added: rowInfo.added,
          latest: rowInfo.latest,
        });
      },
    },
    {
      title: __('Remove'),
      isDisabled: !rowData.added,
      onClick: (_event, rowId, rowInfo) => {
        onRemove(rowInfo.added);
      },
    },
  ];

  const dropdownItems = [
    <DropdownItem ouiaId="bulk-remove" aria-label="bulk_remove" key="bulk_remove" isDisabled={!(bulkRemoveEnabled())} component="button" onClick={removeBulk}>
      {__('Remove')}
    </DropdownItem>,
  ];

  const emptyContentTitle = __('No content views to add yet');
  const emptyContentBody = __('Please create some content views.');
  const emptySearchTitle = __('No matching content views found');
  const emptySearchBody = __('Try changing your search settings.');
  const activeFilters = [statusSelected];
  const defaultFilters = [ALL_STATUSES];

  useDeepCompareEffect(() => {
    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [results, response, buildRows, loading]);

  return (
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
        error,
        status,
        activeFilters,
        defaultFilters,
        resetFilters,
      }}
      ouiaId="content-view-components-table"
      actionResolver={hasPermission(permissions, 'edit_content_views') ? actionResolver : null}
      onSelect={onSelect(rows, setRows)}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/katello/api/v2/content_views"
      bookmarkController="katello_content_views"
      fetchItems={useCallback(params =>
        getContentViewComponents(cvId, params, statusSelected), [cvId, statusSelected])}
      additionalListeners={[statusSelected, addComponentsResolved, removeComponentsResolved]}
      actionButtons={hasPermission(permissions, 'edit_content_views') &&
          status === STATUS.RESOLVED && rows.length !== 0 &&
          <>
            <Split hasGutter>
              <SplitItem>
                <SelectableDropdown
                  items={[ALL_STATUSES, ADDED, NOT_ADDED]}
                  title={__('Status')}
                  selected={statusSelected}
                  setSelected={setStatusSelected}
                  placeholderText={__('Status')}
                />
              </SplitItem>
              {hasPermission(permissions, 'edit_content_views') &&
              <SplitItem>
                <ActionList>
                  <ActionListItem>
                    <Button ouiaId="add-content-views" onClick={addBulk} isDisabled={!(bulkAddEnabled())} variant="primary" aria-label="bulk_add_components">
                      {__('Add content views')}
                    </Button>
                  </ActionListItem>
                  <ActionListItem>
                    <Dropdown
                      toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                      isOpen={bulkActionOpen}
                      isPlain
                      ouiaId="cv-components-bulk-actions"
                      dropdownItems={dropdownItems}
                    />
                  </ActionListItem>
                </ActionList>
              </SplitItem>
            }
            </Split>
            {versionEditing &&
            <ComponentContentViewAddModal
              cvId={compositeCvEditing}
              componentCvId={componentCvEditing}
              componentId={componentId}
              latest={componentLatest}
              componentVersionId={componentVersionId}
              show={versionEditing}
              setIsOpen={setVersionEditing}
              aria-label="edit_component_modal"
            />}
            {bulkAdding &&
            <ComponentContentViewBulkAddModal
              cvId={compositeCvEditing}
              rowsToAdd={selectedComponentsToAdd}
              onClose={() => setBulkAdding(false)}
              aria-label="bulk_add_components_modal"
            />}
          </>
      }
    />
  );
};

ContentViewComponents.propTypes = {
  cvId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    label: PropTypes.string,
    permissions: PropTypes.shape({}),
  }),
};

ContentViewComponents.defaultProps = {
  details: {
    label: '',
    permissions: {},
  },
};

export default ContentViewComponents;
