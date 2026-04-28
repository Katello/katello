import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { Table, Thead, Tbody, Tr, Th, Td, TableVariant } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectContentDetails, selectContentDetailsStatus } from '../../../Content/ContentSelectors';
import { getContentDetails } from '../../../Content/ContentActions';
import Loading from '../../../../components/Loading';
import ProfileRpmsCellFormatter from './ProfileRpmsCellFormatter';

const ModuleStreamDetailProfiles = ({ contentType, id }) => {
  const dispatch = useDispatch();
  const detailsResponse = useSelector(selectContentDetails);
  const detailsStatus = useSelector(selectContentDetailsStatus);

  useEffect(() => {
    if (!detailsResponse) {
      dispatch(getContentDetails(contentType, id));
    }
  });

  if (detailsStatus === STATUS.PENDING) {
    return <Loading />;
  }

  const { profiles } = detailsResponse || {};

  if (!profiles || profiles.length === 0) {
    return <div className="margin-0-24">{__('No profiles to show')}</div>;
  }

  return (
    <div className="margin-0-24">
      <Table variant={TableVariant.compact} ouiaId="module-stream-profiles-table">
        <Thead>
          <Tr ouiaId="profiles-header-row">
            <Th>{__('Name')}</Th>
            <Th>{__('RPMs')}</Th>
          </Tr>
        </Thead>
        <Tbody>
          {profiles.map(profile => (
            <Tr key={profile.id} ouiaId={`profile-row-${profile.id}`}>
              <Td>{profile.name}</Td>
              <Td><ProfileRpmsCellFormatter rpms={profile.rpms} profileId={profile.id} /></Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    </div>
  );
};

ModuleStreamDetailProfiles.propTypes = {
  contentType: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
};

export default ModuleStreamDetailProfiles;
