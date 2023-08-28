import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableComposable, Thead, Tr, Th, Tbody, Td, TableVariant } from '@patternfly/react-table';
import { CheckCircleIcon, TimesCircleIcon } from '@patternfly/react-icons';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import ContentViewIcon from '../ContentViews/components/ContentViewIcon';

const ExpandableCvDetails = ({ contentViews }) => {
  const columnHeaders = [
    __('Content view'),
    __('Last published'),
    __('Repositories'),
    __('Synced to smart proxy'),
  ];

  return (
    <TableComposable
      variant={TableVariant.compact}
      aria-label="expandable-content-views"
      ouiaId="expandable-content-views"
    >
      <Thead>
        <Tr ouiaId="column-headers">
          {columnHeaders.map(col => (
            <Th
              modifier="fitContent"
              key={col}
            >
              {col}
            </Th>
          ))}
        </Tr>
      </Thead>
      <Tbody>
        {contentViews.map((cv) => {
          const {
            id, name: cvName, composite, up_to_date: upToDate, counts,
          } = cv;
          const { repositories } = counts;
          const upToDateVal = upToDate ? <CheckCircleIcon /> : <TimesCircleIcon />;
          return (
            <Tr key={cv.name} ouiaId={cv.name}>
              <Td>
                <ContentViewIcon
                  composite={composite}
                  description={<a href={cv.default ? urlBuilder('products', '') : urlBuilder('content_views', '', id)}>{cvName}</a>}
                />
              </Td>
              <Td><LongDateTime date={cv.last_published} showRelativeTimeTooltip /></Td>
              <Td>{repositories}</Td>
              <Td>{upToDateVal}</Td>
            </Tr>
          );
        })}
      </Tbody>
    </TableComposable>

  );
};

ExpandableCvDetails.propTypes = {
  contentViews: PropTypes.arrayOf(PropTypes.shape({})),
};

ExpandableCvDetails.defaultProps = {
  contentViews: [],
};

export default ExpandableCvDetails;
