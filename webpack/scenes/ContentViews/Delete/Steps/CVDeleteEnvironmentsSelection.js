import React, { useContext, useState, useEffect } from 'react';
import { ExpandableSection, Flex, FlexItem } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { TableVariant, Table /* data-codemods */, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import CVDeleteContext from '../CVDeleteContext';
import { pluralize } from '../../../../utils/helpers';
import Loading from '../../../../components/Loading';
import './CVEnvironmentSelectionForm.scss';
import InactiveText from '../../components/InactiveText';
import WizardHeader from '../../components/WizardHeader';

const CVDeleteEnvironmentSelection = () => {
  const {
    cvVersionResponse, cvDetailsResponse, cvVersionStatus, cvDetailsStatus,
  } = useContext(CVDeleteContext);
  const [versionExpanded, setVersionExpanded] = useState([]);
  const { results } = cvVersionResponse ?? {};
  const { version_count: versionCount } = cvDetailsResponse ?? {};
  const resolved = (cvVersionStatus === STATUS.RESOLVED && cvDetailsStatus === STATUS.RESOLVED);
  useEffect(() => {
    if (cvVersionResponse && results) {
      setVersionExpanded(new Array(results?.length).fill(false));
    }
  }, [cvVersionResponse, results]);
  const columnHeaders = [
    __('Environment'),
    __('Hosts'),
    __('Activation keys'),
  ];

  const setExpanded = (index, expanded) => {
    setVersionExpanded(versionExpanded.map((val, i) => (i === index ? expanded : val)));
  };

  return (
    <>
      <WizardHeader
        title={__('Remove versions from environments')}
        description={resolved &&
          <Flex>
            <FlexItem style={{ marginRight: '8px' }}><ExclamationTriangleIcon /></FlexItem>
            {versionCount ?
              <FlexItem>
                {__(`${pluralize(versionCount, 'content view version')} in the environments below will be removed when content view is deleted`)}
              </FlexItem>
              :
              <FlexItem>
                {__('This content view does not have any versions associated.')}
              </FlexItem>
            }
          </Flex>}
      />
      {!resolved ?
        <Loading loadingText={__('Loading versions')} /> :
        <>

          {results?.map((version, index) => (
            <ExpandableSection
              key={version.id}
              toggleText={__(`Version ${version.version}`)}
              onToggle={(_event, expanded) => setExpanded(index, expanded)}
              isExpanded={versionExpanded[index]}
            >
              {(version?.environments.length !== 0) ?
                <Table ouiaId="cv-delete-env-select-table" variant={TableVariant.compact}>
                  <Thead>
                    <Tr ouiaId="cv-delete-env-select-table-header">
                      <Th aria-label="select header" />
                      {columnHeaders.map(col =>
                        <Th key={col}>{col}</Th>)}
                    </Tr>
                  </Thead>
                  <Tbody>
                    {version?.environments?.map((env, rowIndex) => {
                      const {
                        id, name, activation_key_count: akCount, host_count: hostCount,
                      } = env;
                      return (
                        <Tr ouiaId={`${name}_${id}`} key={`${name}_${id}`}>
                          <Td
                            key={`${name}__${id}_select`}
                            select={{
                              rowIndex,
                              isSelected: true,
                              isDisabled: true,
                            }}
                          />
                          <Td>
                            {name}
                          </Td>
                          <Td>{hostCount}</Td>
                          <Td>{akCount}</Td>
                        </Tr>
                      );
                    })}
                  </Tbody>
                </Table> :
                <InactiveText text={__('This version is not promoted to any environments.')} />
              }
            </ExpandableSection>
          ))}
        </>
      }
    </>
  );
};

export default CVDeleteEnvironmentSelection;
