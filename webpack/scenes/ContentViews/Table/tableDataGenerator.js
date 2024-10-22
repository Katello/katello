import React from 'react';
import { fitContent, expandable, sortable } from '@patternfly/react-table';
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
  {
    title: __('Name'),
    transforms: [sortable],
  },
  __('Last published'),
  __('Last task'),
  __('Latest version'),
];

const buildRow = (contentView) => {
  /* eslint-disable max-len */
  const {
    id, composite, name, last_published: lastPublished, latest_version: latestVersion, latest_version_id: latestVersionId,
    latest_version_environments: latestVersionEnvironments, last_task: lastTask,
  } = contentView;
  /* eslint-enable max-len */
  const { last_sync_words: lastSyncWords, started_at: startedAt } = lastTask || {};
  const row = [
    { title: <ContentViewIcon composite={composite ? true : undefined} /> },
    { title: <Link to={`${urlBuilder('content_views', '')}${id}`}>{name}</Link> },
    { title: lastPublished ? <LongDateTime date={lastPublished} showRelativeTimeTooltip /> : <InactiveText text={__('Not yet published')} /> },
    { title: <LastSync startedAt={startedAt} lastSync={lastTask} lastSyncWords={lastSyncWords} emptyMessage="N/A" /> },
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
      id,
      name,
      composite,
      rolling,
      next_version: nextVersion,
      version_count: versionCount,
      description,
      activation_keys: activationKeys,
      hosts,
      latest_version_environments: latestVersionEnvironments,
      latest_version_id: latestVersionId,
      latest_version: latestVersionName,
      environments,
      versions,
      permissions,
      generated_for: generatedFor,
      related_cv_count: relatedCVCount,
      related_composite_cvs: relatedCompositeCVs,
    } = contentView;
    const cells = buildRow(contentView);
    const cellParent = {
      cvId: id,
      cvName: name,
      cvVersionCount: versionCount,
      cvComposite: composite,
      cvRolling: rolling,
      cvNextVersion: nextVersion,
      latestVersionEnvironments,
      latestVersionId,
      latestVersionName,
      environments,
      versions,
      permissions,
      generatedFor,
      isOpen: false,
      cells,
    };
    rows.push(cellParent);
    const cellChild = {
      parent: cvCount,
      cells: [
        {
          title: <DetailsExpansion
            cvId={id}
            cvName={name}
            cvComposite={composite}
            cvRolling={rolling}
            {...{
              activationKeys, hosts, relatedCVCount, relatedCompositeCVs,
            }}
          />,
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
