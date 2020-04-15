import React from 'react';
import { compoundExpand } from '@patternfly/react-table';
import { ScreenIcon, FolderOpenIcon, ContainerNodeIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

import IconWithCount from '../components/IconWithCount';
import DetailsExpansion from '../expansions/DetailsExpansion';
import RepositoriesExpansion from '../expansions/RepositoriesExpansion';
import EnvironmentsExpansion from '../expansions/EnvironmentsExpansion';
import VersionsExpansion from '../expansions/VersionsExpansion';
import ContentViewName from '../components/ContentViewName';

export const buildColumns = () => [
  __('Name'), __('Last Published'), __('Details'),
  { title: __('Environments'), cellTransforms: [compoundExpand] },
  { title: __('Repositories'), cellTransforms: [compoundExpand] },
  { title: __('Versions'), cellTransforms: [compoundExpand] },
];

const buildRow = (contentView, openColumn) => {
  const {
    id, composite, name, environments, repositories, versions, last_published: lastPublished,
  } = contentView;
  const row = [
    { title: <ContentViewName composite={composite ? 1 : undefined} name={name} cvId={id} /> },
    lastPublished || 'Not yet published',
    { title: __('Details'), props: { isOpen: false, ariaControls: `cv-details-expansion-${id}`, contentviewid: id } },
    {
      title: <IconWithCount Icon={ScreenIcon} count={environments.length} title={`environments-icon-${id}`} />,
      props: { isOpen: false, ariaControls: `cv-environments-expansion-${id}` },
    },
    {
      title: <IconWithCount Icon={FolderOpenIcon} count={repositories.length} title={`repositories-icon-${id}`} />,
      props: { isOpen: false, ariaControls: `cv-repositories-expansion-${id}` },
    },
    {
      title: <IconWithCount Icon={ContainerNodeIcon} count={versions.length} title={`versions-icon-${id}`} />,
      props: { isOpen: false, ariaControls: `cv-versions-expansion-${id}` },
    },
  ];
  if (openColumn) row[openColumn].props.isOpen = true;

  return row;
};

const buildDetailDropdowns = (id, rowIndex, contentViewDetails) => {
  const {
    loading, repositories, environments, versions, ...details
  } = contentViewDetails;
  const commonProps = { cvId: id, className: 'pf-m-no-padding' };

  let detailDropdowns = [
    {
      compoundParent: 2,
      cells: [
        {
          title: <DetailsExpansion details={details} {...commonProps} />,
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: 3,
      cells: [
        {
          title: <EnvironmentsExpansion environments={environments} {...commonProps} />,
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: 4,
      cells: [
        {
          title: <RepositoriesExpansion repositories={repositories} {...commonProps} />,
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: 5,
      cells: [
        {
          title: <VersionsExpansion versions={versions} {...commonProps} />,
          props: { colSpan: 6 },
        },
      ],
    },
  ];

  // The rows are indexed along with the hidden dropdown rows, so we need to offset the parent row
  const rowOffset = detailDropdowns.length + 1;
  detailDropdowns = detailDropdowns.map(detail => ({ ...detail, parent: rowIndex * rowOffset }));

  return detailDropdowns;
};

const tableDataGenerator = (results, detailsMap, expandedColumnMap) => {
  const contentViews = results || [];
  const columns = buildColumns();
  const rows = [];

  contentViews.forEach((contentView, rowIndex) => {
    const { id } = contentView;
    const openColumn = expandedColumnMap[id];
    const contentViewDetails = detailsMap[id] || {};
    const cells = buildRow(contentView, openColumn);

    rows.push({ isOpen: !!openColumn, cells });
    rows.push(...buildDetailDropdowns(id, rowIndex, contentViewDetails));
  });

  return { rows, columns };
};

export default tableDataGenerator;
