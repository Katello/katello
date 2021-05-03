import React from 'react';
import { fitContent, expandable } from '@patternfly/react-table';
import { Link } from 'react-router-dom';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import ContentViewIcon from '../components/ContentViewIcon';
import DetailsExpansion from '../expansions/DetailsExpansion';
import ContentViewVersionCell from './ContentViewVersionCell';
import InactiveText from '../components/InactiveText';
import LastSync from '../Details/Repositories/LastSync';

export const buildColumns = () => [
  { title: __('Type'), cellFormatters: [expandable], transforms: [fitContent] },
  __('Name'), __('Last published'), __('Last task'), __('Latest version'),
];

const buildRow = (contentView) => {
  /* eslint-disable max-len */
  const {
    id, composite, name, last_published: lastPublished, latest_version: latestVersion, latest_version_id: latestVersionId,
    latest_version_environments: latestVersionEnvironments, last_task: lastTask,
  } = contentView;
  /* eslint-enable max-len */
  const { last_sync_words: lastSyncWords } = lastTask || {};
  const row = [
    { title: <ContentViewIcon composite={composite ? true : undefined} /> },
    { title: <Link to={urlBuilder('labs/content_views', '', id)}>{name}</Link> },
    { title: lastPublished ? <LongDateTime date={lastPublished} showRelativeTimeTooltip /> : <InactiveText text={__('Not yet published')} /> },
    { title: <LastSync lastSync={lastTask} lastSyncWords={lastSyncWords} emptyMessage="N/A" /> },
    {
      title: latestVersion ? <ContentViewVersionCell {...{
 id, latestVersion, latestVersionId, latestVersionEnvironments,
}}
      /> : <InactiveText style={{ marginTop: '0.5em', marginBottom: '0.5em' }} text={__('Not yet published')} />,
    },
  ];
  return row;
};

const buildExpandableRows = (contentViews) => {
  const rows = [];
  let cvCount = 0;

  contentViews.forEach((contentView) => {
    const {
      id, name, description, activation_keys: activationKeys, hosts,
    } = contentView;
    const cells = buildRow(contentView);
    const cellParent = {
      cvId: id, cvName: name, isOpen: false, cells,
    };
    rows.push(cellParent);
    const cellChild = {
      parent: cvCount,
      cells: [
        {
          title: <DetailsExpansion cvId={id} {...{ activationKeys, hosts }} />,
          props: {
            colSpan: 2,
          },
        },
        {
          title: description || <InactiveText text={__('No description')} />,
          props: {
            colSpan: 4,
          },
        },
      ],
    };
    rows.push(cellChild);
    cvCount = rows.length;
  });
  return { rows };
};

const tableDataGenerator = (results) => {
  const contentViews = results || [];
  const columns = buildColumns();
  const newRowMappingIds = [];
  const { rows } = buildExpandableRows(contentViews);
  rows.forEach(row => row.cvId && newRowMappingIds.push(row.cvId));
  return { newRowMappingIds, rows, columns };
};

export default tableDataGenerator;
