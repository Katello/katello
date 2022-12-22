import React, { useState, useEffect } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { useSelector, useDispatch } from 'react-redux';
import { wrappable } from '@patternfly/react-table';
import { CheckCircleIcon, TimesCircleIcon } from '@patternfly/react-icons';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import MainTable from '../../components/Table/MainTable';
import getSmartProxyContent from './SmartProxyContentActions';
import ContentViewIcon from '../../scenes/ContentViews/components/ContentViewIcon';
import {
  selectSmartProxyContent,
  selectSmartProxyContentStatus,
  selectSmartProxyContentError,
} from './SmartProxyContentSelectors';

const SmartProxyContentTable = ({ smartProxyId }) => {
  const dispatch = useDispatch();
  const [rows, setRows] = useState([]);
  const response = useSelector(state => selectSmartProxyContent(state));
  const status = useSelector(state => selectSmartProxyContentStatus(state));
  const error = useSelector(state => selectSmartProxyContentError(state));
  const columnHeaders = [
    {
      title: __('Environment'),
      transforms: [wrappable],
    },
    {
      title: __('Content view'),
      transforms: [wrappable],
    },
    {
      title: __('Type'),
      transforms: [wrappable],
    },
    {
      title: __('Last published'),
      transforms: [wrappable],
    },
    {
      title: __('Repositories'),
      transforms: [wrappable],
    },
    {
      title: __('Synced to smart proxy'),
      transforms: [wrappable],
    },
  ];

  const buildrows = (results) => {
    const newRows = [];
    let envCount = 0;
    results.forEach((env) => {
      const { name, content_views: contentViews } = env;
      const cellEnv = {
        isOpen: false,
        cells: [name, null, null, null, null, null],
      };
      newRows.push(cellEnv);
      contentViews.forEach((cv) => {
        const {
          id, name: cvName, composite, last_published: lastPublished, up_to_date: upToDate, counts,
        } = cv;
        const { repositories } = counts;
        const cvType = <ContentViewIcon composite={composite} />;
        const upToDateVal = upToDate ? <CheckCircleIcon /> : <TimesCircleIcon />;
        const cellCv =
          {
            parent: envCount,
            cells: [
              {
                title: null,
                props: {
                  colSpan: 1,
                },
              },
              {
                title: <a href={cv.default ? urlBuilder('products', '') : urlBuilder('content_views', '', id)}>{cvName}</a>,
                props: {
                  colSpan: 1,
                },
              },
              {
                title: cvType,
                props: {
                  colSpan: 1,
                },
              },
              {
                title: <LongDateTime date={lastPublished} showRelativeTimeTooltip />,
                props: {
                  colSpan: 1,
                },
              },
              {
                title: repositories,
                props: {
                  colSpan: 1,
                },
              },
              {
                title: upToDateVal,
                props: {
                  colSpan: 1,
                },
              },
            ],
          };
        newRows.push(cellCv);
      });
      envCount = newRows.length;
    });
    return newRows;
  };

  const onCollapse = (row, setRow) => (event, rowKey, isOpen) => {
    const newRows = [...row];
    newRows[rowKey].isOpen = isOpen;
    setRow(newRows);
  };

  useEffect(
    () => {
      dispatch(getSmartProxyContent({ smartProxyId }));
    }
    , [dispatch, smartProxyId],
  );

  useDeepCompareEffect(() => {
    if (status !== STATUS.PENDING && response) {
      const { lifecycle_environments: env } = response;
      setRows(buildrows(env));
    }
  }, [response, status, error]);


  return (
    <MainTable
      onCollapse={onCollapse(rows, setRows)}
      ouiaId="smart-proxy-content-table"
      status={status}
      cells={columnHeaders}
      rows={rows}
      error={error}
      emptyContentTitle="No content synced"
      emptyContentBody="No content synced to smart proxy"
      emptySearchTitle="Empty"
      emptySearchBody="Empty"
    />
  );
};

SmartProxyContentTable.propTypes = {
  smartProxyId: PropTypes.number,
};

SmartProxyContentTable.defaultProps = {
  smartProxyId: null,
};

export default SmartProxyContentTable;
