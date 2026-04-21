import React from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { Table, TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { selectCVDetails } from '../../ContentViewDetailSelectors';

const AffectedHostgroups = ({ cvId, selectedEnvSet }) => {
  const cvDetailsResponse = useSelector(state => selectCVDetails(state, cvId), shallowEqual);
  const { hostgroups = [], environments = [] } = cvDetailsResponse || {};

  // Filter hostgroups by selected environments if provided
  let filteredHostgroups = hostgroups;
  if (selectedEnvSet && selectedEnvSet.size > 0) {
    // Get hostgroup IDs from selected environments
    const hostgroupIdsInSelectedEnvs = new Set();
    environments.forEach((env) => {
      if (selectedEnvSet.has(env.id)) {
        (env.hostgroups || []).forEach((hgId) => {
          hostgroupIdsInSelectedEnvs.add(hgId);
        });
      }
    });
    // Filter to only hostgroups in selected environments
    filteredHostgroups = hostgroups.filter(hg => hostgroupIdsInSelectedEnvs.has(hg.id));
  }

  if (filteredHostgroups.length === 0) {
    return <div>{__('No host groups found.')}</div>;
  }

  return (
    <Table variant={TableVariant.compact} ouiaId="affected-hostgroups-table">
      <Thead>
        <Tr ouiaId="affected-hostgroups-header">
          <Th>{__('Name')}</Th>
        </Tr>
      </Thead>
      <Tbody>
        {filteredHostgroups.map(({ name, id }) => (
          <Tr key={id} ouiaId={`hostgroup-${id}`}>
            <Td>
              <a rel="noreferrer" target="_blank" href={urlBuilder(`hostgroups/${id}/edit`, '')}>{name}</a>
            </Td>
          </Tr>
        ))}
      </Tbody>
    </Table>
  );
};

AffectedHostgroups.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  selectedEnvSet: PropTypes.instanceOf(Set),
};

AffectedHostgroups.defaultProps = {
  selectedEnvSet: null,
};

export default AffectedHostgroups;
