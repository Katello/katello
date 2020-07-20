import React from 'react';
import { compoundExpand, fitContent } from '@patternfly/react-table';
import {
  ScreenIcon,
  ContainerNodeIcon,
} from '@patternfly/react-icons';
import { Link } from 'react-router-dom';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';

import IconWithCount from '../components/IconWithCount';
import DetailsExpansion from '../expansions/DetailsExpansion';
import EnvironmentsExpansion from '../expansions/EnvironmentsExpansion';
import VersionsExpansion from '../expansions/VersionsExpansion';
import ContentViewIcon from '../components/ContentViewIcon';
import DetailsContainer from '../Details/DetailsContainer';

export const buildColumns = () => [
  { title: __('Type'), transforms: [fitContent] },
  __('Name'), __('Last published'), __('Details'),
  { title: __('Environments'), cellTransforms: [compoundExpand] },
  { title: __('Versions'), cellTransforms: [compoundExpand] },
];

const buildRow = (contentView, openColumn) => {
  const {
    id, composite, name, environments, versions, last_published: lastPublished,
  } = contentView;
  const row = [
    { title: <ContentViewIcon composite={composite ? true : undefined} /> },
    { title: <Link to={urlBuilder('labs/content_views', '', id)}>{name}</Link> },
    lastPublished || 'Not yet published',
    { title: __('Details'), props: { isOpen: false, ariaControls: `cv-details-expansion-${id}` } },
    {
      title: <IconWithCount Icon={ScreenIcon} count={environments.length} title={`environments-icon-${id}`} />,
      props: { isOpen: false, ariaControls: `cv-environments-expansion-${id}` },
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
  const offsetColumn = 3; // index of first expandable column

  let detailDropdowns = [
    {
      compoundParent: offsetColumn,
      cells: [
        {
          title: (
            <DetailsContainer {...containerProps(offsetColumn + 1)}>
              <DetailsExpansion {...expansionProps} />
            </DetailsContainer>),
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: offsetColumn + 1,
      cells: [
        {
          title: (
            <DetailsContainer {...containerProps(offsetColumn + 2)}>
              <EnvironmentsExpansion {...expansionProps} />
            </DetailsContainer>),
          props: { colSpan: 6 },
        },
      ],
    },
    {
      compoundParent: offsetColumn + 2,
      cells: [
        {
          title: (
            <DetailsContainer {...containerProps(offsetColumn + 3)}>
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
