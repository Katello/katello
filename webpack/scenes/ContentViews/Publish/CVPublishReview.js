import React, { useMemo } from 'react';
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

const CVPublishReview = ({
  details: {
    name, composite, next_version: nextVersion,
  },
  userCheckedItems,
}) => {
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const environmentPathStatus = useSelector(selectEnvironmentPathsStatus);
  const environmentPathLoading = environmentPathStatus === STATUS.PENDING;

  const promotedToEnvironments = useMemo(() => {
    if (!environmentPathLoading) {
      const { results } = environmentPathResponse || {};
      const library = results[0].environments[0];
      return [library].concat(userCheckedItems);
    }
    return [];
  }, [environmentPathResponse, environmentPathLoading, userCheckedItems]);

  return (
    <>
      <WizardHeader
        title={__('Review details')}
        description={
          <>
            {__('Review your currently selected changes for ')}<b>{composite ? <RegistryIcon /> : <EnterpriseIcon />} {name}.</b>
          </>}
      />
      <TableComposable aria-label="Review Table">
        <Thead>
          <Tr>
            <Th>{__('Content view name')}</Th>
            <Th>{__('Version')}</Th>
            <Th>{__('Environments')}</Th>
          </Tr>
        </Thead>
        <Tbody>
          <Tr>
            <Td>
              <><ContentViewIcon composite={composite} description={name} /><InactiveText text={__('Newly published')} /></>
            </Td>
            <Td>
              {__('Version')} {nextVersion}
            </Td>
            <Td>
              <ComponentEnvironments environments={promotedToEnvironments} />
            </Td>
          </Tr>
        </Tbody>
      </TableComposable>
    </>
  );
};

CVPublishReview.propTypes = {
  userCheckedItems: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  details: PropTypes.shape({
    name: PropTypes.string.isRequired,
    composite: PropTypes.bool.isRequired,
    next_version: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]).isRequired,
  }).isRequired,
};

export default CVPublishReview;
