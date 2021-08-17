import React, { useState, useMemo, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { Form, FormGroup, TextArea, ActionGroup, Button, Modal, ModalVariant, Alert } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

import {
  selectEnvironmentPaths,
  selectEnvironmentPathsStatus,
} from '../../components/EnvironmentPaths/EnvironmentPathSelectors';
import EnvironmentPaths from '../../components/EnvironmentPaths/EnvironmentPaths';
import { getContentViewVersions, promoteContentViewVersion } from '../ContentViewDetailActions';
import {
  selectPromoteCVVersionError, selectPromoteCVVersionResponse,
  selectPromoteCVVersionStatus,
} from './ContentViewVersionPromoteSelectors';
import ComponentEnvironments from '../ComponentContentViews/ComponentEnvironments';
import Loading from '../../../../components/Loading';

const ContentViewVersionPromote = ({
  cvId, versionIdToPromote, versionNameToPromote, versionEnvironments, setIsOpen,
}) => {
  const [description, setDescription] = useState('');
  const [userCheckedItems, setUserCheckedItems] = useState([]);
  const [promoting, setPromoting] = useState(false);
  const [forcePromote, setForcePromote] = useState([]);
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const environmentPathStatus = useSelector(selectEnvironmentPathsStatus);
  const environmentPathLoading = environmentPathStatus === STATUS.PENDING;
  const promoteResponse = useSelector(state =>
    selectPromoteCVVersionResponse(state, versionIdToPromote, versionEnvironments));
  const promoteStatus = useSelector(state =>
    selectPromoteCVVersionStatus(state, versionIdToPromote, versionEnvironments));
  const promoteError = useSelector(state =>
    selectPromoteCVVersionError(state, versionIdToPromote, versionEnvironments));
  const promoteResolved = promoteStatus === STATUS.RESOLVED;
  const dispatch = useDispatch();

  const onPromote = () => {
    setPromoting(true);
    dispatch(promoteContentViewVersion({
      id: versionIdToPromote,
      description,
      versionEnvironments,
      environment_ids: userCheckedItems.map(item => item.id),
      force: true,
    }));
  };

  useDeepCompareEffect(() => {
    if (promoteResolved && promoteResponse) {
      setIsOpen(false);
      dispatch(getContentViewVersions(cvId));
    }
    if (promoteError) {
      setPromoting(false);
    }
  }, [promoteResponse, promoteResolved, promoteError, setPromoting, setIsOpen, dispatch, cvId]);

  const envPathFlat = useMemo(() => {
    if (!environmentPathLoading) {
      const { results } = environmentPathResponse || {};
      return results.map(result => result.environments).flatten();
    }
    return [];
  }, [environmentPathResponse, environmentPathLoading]);

  const prior = useCallback(
    env => envPathFlat.find(item => item.id === env.prior.id),
    [envPathFlat],
  );

  const isChecked = useCallback(
    env => (userCheckedItems.includes(env) ||
      versionEnvironments.filter(item => item.id === env.id).length),
    [userCheckedItems, versionEnvironments],
  );

  const isValid = useCallback((env) => {
    if (!env.prior) return true;
    if (!isChecked(prior(env))) return false;
    return isValid(prior(env));
  }, [prior, isChecked]);

  useDeepCompareEffect(() => {
    setForcePromote(userCheckedItems.filter(item => !isValid(item)));
  }, [userCheckedItems, setForcePromote, isValid]);

  return (
    <Modal
      title={__(`Promote version ${versionNameToPromote}`)}
      isOpen
      variant={ModalVariant.large}
      onClose={() => {
        setIsOpen(false);
      }}
      appendTo={document.body}
    >
      {promoting ? <Loading loadingText={__('Please wait while the task starts..')} /> :
      <>
        <Form>
          <FormGroup label="Description" fieldId="description">
            <TextArea
              isRequired
              type="text"
              id="description"
              aria-label="input_description"
              name="description"
              value={description}
              onChange={value => setDescription(value)}
            />
          </FormGroup>
        </Form>
        <hr />
        {forcePromote.length > 0 && (
          <Alert variant="info" isInline title="Force Promotion">
            <p>{__('Selected environments are out of the environment order. ' +
              'The recommended practice is to promote to the next environment in the path.')}
            </p>
            <ComponentEnvironments environments={forcePromote} />
          </Alert>)}
        <EnvironmentPaths
          userCheckedItems={userCheckedItems}
          setUserCheckedItems={setUserCheckedItems}
          promotedEnvironments={versionEnvironments}
          publishing={false}
        />
        <Form>
          <ActionGroup>
            <Button
              aria-label="promote_content_view"
              variant="primary"
              isDisabled={promoting}
              onClick={() => onPromote()}
            >
              {__('Promote')}
            </Button>
            <Button variant="link" onClick={() => setIsOpen(false)}>
              {__('Cancel')}
            </Button>
          </ActionGroup>
        </Form>
      </>}
    </Modal>
  );
};

ContentViewVersionPromote.propTypes = {
  cvId: PropTypes.number.isRequired,
  versionIdToPromote: PropTypes.number.isRequired,
  versionNameToPromote: PropTypes.string.isRequired,
  versionEnvironments: PropTypes.arrayOf(PropTypes.shape({})),
  setIsOpen: PropTypes.func,
};

ContentViewVersionPromote.defaultProps = {
  versionEnvironments: [],
  setIsOpen: null,
};

export default ContentViewVersionPromote;
