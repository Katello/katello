import React, { useState, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { Bullseye, Split, SplitItem, Button } from '@patternfly/react-core';
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
import { ADDED, ALL_STATUSES, NOT_ADDED } from '../../ContentViewsConstants';
import SelectableDropdown from '../../../../components/SelectableDropdown/SelectableDropdown';
import '../../../../components/EditableTextInput/editableTextInput.scss';
import ComponentContentViewAddModal from './ComponentContentViewAddModal';

const ContentViewComponents = ({ cvId, details }) => {
  const response = useSelector(state => selectCVComponents(state, cvId));
  const status = useSelector(state => selectCVComponentsStatus(state, cvId));
  const error = useSelector(state => selectCVComponentsError(state, cvId));
  const componentAddedStatus = useSelector(state => selectCVComponentAddStatus(state, cvId));
  const componentRemovedStatus = useSelector(state => selectCVComponentRemoveStatus(state, cvId));
  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [statusSelected, setStatusSelected] = useState(ALL_STATUSES);
  const [versionEditing, setVersionEditing] = useState(false);
  const [compositeCvEditing, setCompositeCvEditing] = useState(null);
  const [componentCvEditing, setComponentCvEditing] = useState(null);
  const [componentLatest, setComponentLatest] = useState(false);
  const [componentId, setComponentId] = useState(null);
  const dispatch = useDispatch();

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

  const { label } = details || {};

  const bulkRemoveEnabled = () => rows.some(row => row.selected && row.added);

  const onAdd = useCallback(({
    componentCvId, published, added, latest,
  }) => {
    if (published) {
      dispatch(getContentViewDetails(componentCvId));
      setVersionEditing(true);
      setCompositeCvEditing(cvId);
      setComponentCvEditing(componentCvId);
      setComponentLatest(latest);
      setComponentId(added);
    } else {
      dispatch(addComponent({
        compositeContentViewId: cvId,
        components: [{ latest: true, content_view_id: componentCvId }],
      }));
    }
  }, [cvId, dispatch]);

  const removeBulk = () => {
    const componentIds = [];
    rows.forEach(row => row.selected && componentIds.push(row.added));
    dispatch(removeComponent({
      compositeContentViewId: cvId,
      component_ids: componentIds,
    }));
  };

  const onRemove = (componentIdToRemove) => {
    dispatch(removeComponent({
      compositeContentViewId: cvId,
      component_ids: [componentIdToRemove],
    }));
  };

  const buildRows = useCallback((results) => {
    const newRows = [];
    results.forEach((componentCV) => {
      const {
        id: componentCvId, content_view: cv, content_view_version: cvVersion, latest,
      } = componentCV;
      const { environments, repositories } = cvVersion || {};
      const {
        id,
        name,
        description,
      } = cv;

      const cells = [
        { title: <Bullseye><ContentViewIcon composite={false} /></Bullseye> },
        { title: <Link to={urlBuilder('labs/content_views', '', id)}>{name}</Link> },
        {
          title:
  <Split>
    <SplitItem>
      <ComponentVersion {...{ componentCV }} />
    </SplitItem>
    {componentCvId && cvVersion &&
    <SplitItem>
      <Button
        className="foreman-edit-icon"
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
  </Split>,
        },
        { title: environments ? <ComponentEnvironments {...{ environments }} /> : __('Not yet published') },
        { title: <Link to={urlBuilder(`labs/content_views/${id}#repositories`, '')}>{ repositories ? repositories.length : 0 }</Link> },
        {
          title: <AddedStatusLabel added={!!componentCvId} />,
        },
        { title: <TableText wrapModifier="truncate">{description || __('No description')}</TableText> },
      ];
      newRows.push({
        componentCvId: id, added: componentCvId, published: cvVersion, latest, cells,
      });
    });
    return newRows;
  }, [onAdd]);

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

  const emptyContentTitle = __(`No content views belong to ${label}`);
  const emptyContentBody = __('Please add some content views.');
  const emptySearchTitle = __('No matching content views found');
  const emptySearchBody = __('Try changing your search settings.');
  const activeFilters = statusSelected && statusSelected !== ALL_STATUSES;

  useDeepCompareEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, buildRows, loading]);

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
        actionResolver,
      }}
      onSelect={onSelect(rows, setRows)}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/content_views/auto_complete_search"
      fetchItems={useCallback(params =>
        getContentViewComponents(cvId, params, statusSelected), [cvId, statusSelected])}
      additionalListeners={[statusSelected, addComponentsResolved, removeComponentsResolved]}
      actionButtons={
        <>
          <Split hasGutter>
            <SplitItem>
              <SelectableDropdown
                items={[ADDED, NOT_ADDED, ALL_STATUSES]}
                title={__('Status')}
                selected={statusSelected}
                setSelected={setStatusSelected}
                placeholderText={__('Status')}
              />
            </SplitItem>
            <SplitItem>
              <Button onClick={removeBulk} isDisabled={!(bulkRemoveEnabled())} variant="secondary" aria-label="remove_components">
                {__('Remove content views')}
              </Button>
            </SplitItem>
          </Split>
          {versionEditing &&
          <ComponentContentViewAddModal
            cvId={compositeCvEditing}
            componentCvId={componentCvEditing}
            componentId={componentId}
            latest={componentLatest}
            show={versionEditing}
            setIsOpen={setVersionEditing}
            aria-label="copy_content_view_modal"
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
  }),
};

ContentViewComponents.defaultProps = {
  details: {
    label: '',
  },
};

export default ContentViewComponents;
