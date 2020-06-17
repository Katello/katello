import React from 'react';
import { compoundExpand } from '@patternfly/react-table';
import { ScreenIcon, RepositoryIcon, ContainerNodeIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

import IconWithCount from '../components/IconWithCount';
import DetailsExpansion from '../expansions/DetailsExpansion';
import RepositoriesExpansion from '../expansions/RepositoriesExpansion';
import EnvironmentsExpansion from '../expansions/EnvironmentsExpansion';
import VersionsExpansion from '../expansions/VersionsExpansion';
import ContentViewName from '../components/ContentViewName';
import DetailsContainer from '../Details/DetailsContainer';

export const buildColumns = () => [
  __('Name'), __('Last published'), __('Details'),
  { title: __('Environments'), cellTransforms: [compoundExpand] },
  { title: __('Repositories'), cellTransforms: [compoundExpand] },
  { title: __('Versions'), cellTransforms: [compoundExpand] },
];

const buildRow = (contentView, openColumn) => {
  const {
    id, composite, name, environments, repositories, versions, last_published: lastPublished,
  } = contentView;
  const row = [
    { title: <ContentViewName composite={composite ? true : undefined} name={name} cvId={id} /> },
    lastPublished || 'Not yet published',
    { title: __('Details'), props: { isOpen: false, ariaControls: `cv-details-expansion-${id}` } },
    {
      title: <IconWithCount Icon={ScreenIcon} count={environments.length} title={`environments-icon-${id}`} />,
      props: { isOpen: false, ariaControls: `cv-environments-expansion-${id}` },
    },
    {
      title: <IconWithCount Icon={RepositoryIcon} count={repositories.length} title={`repositories-icon-${id}`} />,
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

const buildDetailDropdowns = (id, rowIndex, openColumn) => {
  const cvId = { cvId: id };
  const expansionProps = { ...cvId, className: 'pf-m-no-padding' };
  const containerProps = column => ({ ...cvId, isOpen: openColumn === column });

  let detailDropdowns = [
    {
      compoundParent: 2,
      cells: [
        {
          title: (
            <DetailsContainer {...containerProps(3)}>
              <DetailsExpansion {...expansionProps} />
            </DetailsContainer>),
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: 3,
      cells: [
        {
          title: (
            <DetailsContainer {...containerProps(4)}>
              <EnvironmentsExpansion {...expansionProps} />
            </DetailsContainer>),
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: 4,
      cells: [
        {
          title: (
            <DetailsContainer {...containerProps(5)}>
              <RepositoriesExpansion {...expansionProps} />
            </DetailsContainer>),
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: 5,
      cells: [
        {
          title: (
            <DetailsContainer {...containerProps(6)}>
              <VersionsExpansion {...expansionProps} />
            </DetailsContainer>),
          props: { colSpan: 6 },
        },
      ],
    },
  ];

  detailDropdowns = detailDropdowns.map(detail => ({ ...detail, parent: rowIndex }));

  return detailDropdowns;
};

const buildRowsAndMapping = (contentViews, newRowMapping) => {
  const updatedRowMap = { ...newRowMapping };
  const rows = [];

  contentViews.forEach((contentView) => {
    const { id } = contentView;
    const rowIndex = rows.length;
    const needsUpdate = !Object.keys(updatedRowMap).find(i => updatedRowMap[i].id === id) ||
                        !Object.keys(updatedRowMap[rowIndex] || {}).includes('expandedColumn');
    if (needsUpdate) updatedRowMap[rowIndex] = { expandedColumn: null, id };
    const openColumn = updatedRowMap[rowIndex].expandedColumn;
    const cells = buildRow(contentView, openColumn);
    const isOpen = !!openColumn;

    rows.push({ isOpen, cells });
    rows.push(...buildDetailDropdowns(id, rowIndex, openColumn));
  });

  return { rows, updatedRowMap };
};

const tableDataGenerator = (results, rowMapping) => {
  // If a search was performed or perPage has changed, we can clear mapping
  const prevRowMapping = (results.length === Object.keys(rowMapping).length) ? rowMapping : {};
  const newRowMapping = {};
  const contentViews = results || [];
  const columns = buildColumns();
  const contentViewIds = contentViews.map(cv => cv.id);

  // Only keep the relevant rows to keep the table status check accurate
  Object.entries(prevRowMapping).forEach(([rowId, value]) => {
    if (contentViewIds.includes(value.id)) newRowMapping[rowId] = value;
  });
  const { updatedRowMap, rows } = buildRowsAndMapping(contentViews, newRowMapping);

  return { updatedRowMap, rows, columns };
};

export default tableDataGenerator;
