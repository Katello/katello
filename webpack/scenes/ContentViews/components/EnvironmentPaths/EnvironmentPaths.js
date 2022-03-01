import React from 'react';
import { useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { FormGroup, Checkbox, TextContent } from '@patternfly/react-core';
import { selectEnvironmentPaths, selectEnvironmentPathsStatus } from './EnvironmentPathSelectors';
import EnvironmentLabels from '../EnvironmentLabels';
import './EnvironmentPaths.scss';
import Loading from '../../../../components/Loading';

const EnvironmentPaths = ({
  userCheckedItems, setUserCheckedItems, promotedEnvironments, publishing, headerText, multiSelect,
}) => {
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const environmentPathStatus = useSelector(selectEnvironmentPathsStatus);
  const environmentPathLoading = environmentPathStatus === STATUS.PENDING;

  const oncheckedChange = (checked, env) => {
    if (checked) {
      if (multiSelect) {
        setUserCheckedItems([...userCheckedItems, env]);
      } else {
        setUserCheckedItems([env]);
      }
    } else {
      setUserCheckedItems(userCheckedItems.filter(item => item.id !== env.id));
    }
  };
  if (environmentPathLoading) {
    return <Loading />;
  }
  const { results } = environmentPathResponse || {};

  const envCheckedInList = (env, envList) => envList.filter(item => item.id === env.id).length;
  /* eslint-disable react/no-array-index-key */
  return (
    <>
      <TextContent>{headerText}</TextContent>
      <div>
        {results.map((path, index) => {
          const {
            environments,
          } = path || {};
          return (
            <div className="env-path" key={index}>
              {index === 0 && <hr />}
              <FormGroup key={`fg-${index}`} isInline fieldId="environment-checkbox-group">
                {environments.map(env =>
                  (<Checkbox
                    isChecked={(publishing && env.library) ||
                    envCheckedInList(env, userCheckedItems) ||
                    envCheckedInList(env, promotedEnvironments)}
                    isDisabled={(publishing && env.library)
                    || envCheckedInList(env, promotedEnvironments)}
                    className="env-path__labels-with-pointer"
                    key={`${env.id}${index}`}
                    id={`${env.id}${index}`}
                    label={<EnvironmentLabels environments={env} />}
                    aria-label={env.label}
                    onChange={checked => oncheckedChange(checked, env)}
                  />))}
              </FormGroup>
              <hr />
            </div>
          );
        })
          /* eslint-enable react/no-array-index-key */
        }
      </div>
    </>
  );
};

EnvironmentPaths.propTypes = {
  userCheckedItems: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  setUserCheckedItems: PropTypes.func.isRequired,
  promotedEnvironments: PropTypes.arrayOf(PropTypes.shape({})),
  publishing: PropTypes.bool,
  headerText: PropTypes.string,
  multiSelect: PropTypes.bool,
};

EnvironmentPaths.defaultProps = {
  promotedEnvironments: [],
  publishing: true,
  headerText: __('Select a lifecycle environment from the available promotion paths to promote new version.'),
  multiSelect: true,
};
export default EnvironmentPaths;
