import React, { useMemo } from 'react';
import { Alert } from '@patternfly/react-core';
import { Link } from 'react-router-dom';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import {
  TableComposable, Thead, Tbody, Tr, Th,
  Td,
} from '@patternfly/react-table';
import { EnterpriseIcon, RegistryIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import ContentViewIcon from '../components/ContentViewIcon';
import InactiveText from '../components/InactiveText';
import ComponentEnvironments from '../Details/ComponentContentViews/ComponentEnvironments';
import { selectEnvironmentPaths, selectEnvironmentPathsStatus } from '../components/EnvironmentPaths/EnvironmentPathSelectors';
import WizardHeader from '../components/WizardHeader';
import { selectCVFilters, selectCVFiltersStatus } from '../Details/ContentViewDetailSelectors';

const CVPublishReview = ({
  details: {
    id, name, composite, next_version: nextVersion,
  },
  userCheckedItems,
}) => {
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const environmentPathStatus = useSelector(selectEnvironmentPathsStatus);
  const cvFiltersResponse = useSelector(state => selectCVFilters(state, id));
  const cvFiltersStatus = useSelector(state => selectCVFiltersStatus(state, id));
  const environmentPathLoading = environmentPathStatus === STATUS.PENDING;
  const cvFiltersLoading = cvFiltersStatus === STATUS.PENDING;

  const promotedToEnvironments = useMemo(() => {
    if (!environmentPathLoading) {
      const { results } = environmentPathResponse || {};
      const library = results[0].environments[0];
      return [library].concat(userCheckedItems);
    }
    return [];
  }, [environmentPathResponse, environmentPathLoading, userCheckedItems]);

  const filtered = useMemo(() => {
    if (!cvFiltersLoading) {
      const { results } = cvFiltersResponse || {};
      return results.length > 0;
    }
    return [];
  }, [cvFiltersResponse, cvFiltersLoading]);

  return (
    <>
      <WizardHeader
        title={__('Review details')}
        description={
          <>
            {__('Review your currently selected changes for ')}<b>{composite ? <RegistryIcon /> : <EnterpriseIcon />} {name}.</b>
            {filtered && (
            <Alert
              ouiaId="filters-applied-alert"
              variant="warning"
              isInline
              isPlain
              title={__('Filters will be applied to this content view version.')}
              style={{ marginTop: '24px' }}
            />)}
          </>
          }
      />
      <TableComposable ouiaId="cv-publish-review-table" aria-label="Review Table">
        <Thead>
          <Tr ouiaId="cv-publish-review-table-headers">
            <Th>{__('Content view name')}</Th>
            <Th>{__('Version')}</Th>
            <Th>{__('Environments')}</Th>
            <Th>{__('Filters')}</Th>
          </Tr>
        </Thead>
        <Tbody>
          <Tr ouiaId="cv-publish-review-table-row">
            <Td>
              <><ContentViewIcon composite={composite} description={name} /><InactiveText text={__('Newly published')} /></>
            </Td>
            <Td>
              {__('Version')} {nextVersion}
            </Td>
            <Td>
              <ComponentEnvironments environments={promotedToEnvironments} />
            </Td>
            {filtered
              ? <Td><Link to={`/content_views/${id}#/filters`} target="_blank" rel="noopener noreferrer">{__('View Filters')} </Link> </Td>
              : <Td>-</Td>
            }
          </Tr>
        </Tbody>
      </TableComposable>
    </>
  );
};

CVPublishReview.propTypes = {
  userCheckedItems: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  details: PropTypes.shape({
    id: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]).isRequired,
    name: PropTypes.string.isRequired,
    composite: PropTypes.bool.isRequired,
    next_version: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]).isRequired,
  }).isRequired,
};

export default CVPublishReview;
