import React from 'react';
import { useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Form, FormGroup, Checkbox } from '@patternfly/react-core';
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
      <b
        style={{ marginBottom: '1em' }}
      >{headerText}
      </b>
      <Form style={{ marginTop: '1em' }}>{results.map((path, count) => {
        const {
          environments,
        } = path || {};
        return (
          <React.Fragment key={count}>
            <FormGroup key={`fg-${count}`} isInline fieldId="environment-checkbox-group">
              {environments.map(env =>
                (<Checkbox
                  isChecked={(publishing && env.library) ||
                  envCheckedInList(env, userCheckedItems) ||
                  envCheckedInList(env, promotedEnvironments)}
                  isDisabled={(publishing && env.library)
                  || envCheckedInList(env, promotedEnvironments)}
                  style={{ marginRight: '3px', marginBottom: '1px' }}
                  className="env-labels-with-pointer"
                  key={`${env.id}${count}`}
                  id={`${env.id}${count}`}
                  label={<EnvironmentLabels environments={env} />}
                  aria-label={env.label}
                  onChange={checked => oncheckedChange(checked, env)}
                />))}
            </FormGroup>
            <hr key={`hr${count}`} style={{ margin: '0em' }} />
          </React.Fragment>
        );
      })}
      </Form>
    </>
  );
  /* eslint-enable react/no-array-index-key */
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
