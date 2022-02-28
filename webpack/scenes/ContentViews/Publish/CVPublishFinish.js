import { STATUS } from 'foremanReact/constants';
import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { Bullseye, Button, Grid, GridItem,
  Progress, ProgressSize, ProgressMeasureLocation,
  ProgressVariant, EmptyState, EmptyStateIcon, EmptyStateVariant,
  Title } from '@patternfly/react-core';
import { ExternalLinkAltIcon, InProgressIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  selectPublishContentViewsError, selectPublishContentViews,
  selectPublishContentViewStatus,
} from './ContentViewPublishSelectors';
import { selectPublishTaskPoll, selectPublishTaskPollStatus } from '../Details/ContentViewDetailSelectors';
import getContentViews, { publishContentView } from '../ContentViewsActions';
import Loading from '../../../components/Loading';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';
import { cvVersionPublishKey } from '../ContentViewsConstants';
import { startPollingTask, stopPollingTask, toastTaskFinished } from '../../Tasks/TaskActions';
import getContentViewDetails from '../Details/ContentViewDetailActions';

const CVPublishFinish = ({
  cvId,
  userCheckedItems, setUserCheckedItems,
  forcePromote, description, setDescription,
  setIsOpen, versionCount, currentStep, setCurrentStep,
}) => {
  const dispatch = useDispatch();
  const [publishDispatched, setPublishDispatched] = useState(false);
  const [saving, setSaving] = useState(true);
  const [polling, setPolling] = useState(false);
  const [taskErrored, setTaskErrored] = useState(false);
  const response = useSelector(state => selectPublishContentViews(state, cvId, versionCount));
  const status = useSelector(state => selectPublishContentViewStatus(state, cvId, versionCount));
  const error = useSelector(state => selectPublishContentViewsError(state, cvId, versionCount));
  const pollResponse = useSelector(state =>
    selectPublishTaskPoll(state, cvVersionPublishKey(cvId, versionCount)), shallowEqual);
  const pollResponseStatus = useSelector(state =>
    selectPublishTaskPollStatus(state, cvVersionPublishKey(cvId, versionCount)), shallowEqual);

  const progressCompleted = () => (pollResponse.progress ? pollResponse.progress * 100 : 0);

  const handleEndTask = useCallback(({ taskComplete }) => {
    if (currentStep !== 1) {
      dispatch(stopPollingTask(cvVersionPublishKey(cvId, versionCount)));
      setCurrentStep(1);
      setIsOpen(false);
      dispatch(getContentViewDetails(cvId));
      dispatch(getContentViews);
      if (taskComplete) {
        dispatch(toastTaskFinished(pollResponse));
      }
    }
  }, [currentStep, cvId, dispatch, pollResponse, setCurrentStep, setIsOpen, versionCount]);


  useEffect(() => {
    if (currentStep !== 3 && !publishDispatched) {
      setCurrentStep(3);
      setSaving(true);
      setPublishDispatched(true);
      dispatch(publishContentView({
        id: cvId,
        versionCount,
        description,
        environment_ids: userCheckedItems.map(item => item.id),
        is_force_promote: (forcePromote.length > 0),
      }));
      setDescription('');
      setUserCheckedItems([]);
    }
  }, [dispatch, setSaving, publishDispatched, setPublishDispatched,
    setDescription, setUserCheckedItems, currentStep, setCurrentStep,
    cvId, versionCount, description, forcePromote, userCheckedItems]);

  useDeepCompareEffect(() => {
    if (!response) return;
    const pollPublishTask = (cvPublishVersionKey, task) => {
      if (!polling) dispatch(startPollingTask(cvPublishVersionKey, task));
    };

    setSaving(true);
    const { id } = response;
    if (id && status === STATUS.RESOLVED) {
      setSaving(false);
      pollPublishTask(cvVersionPublishKey(cvId, versionCount), response);
      setPolling(true);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [response, status, error, cvId, versionCount,
    dispatch, polling, setPolling, setSaving]);


  useDeepCompareEffect(() => {
    const { state, result } = pollResponse;
    if (state === 'paused' || result === 'error') {
      setTaskErrored(true);
      setTimeout(() => {
        handleEndTask({ taskComplete: true });
      }, 500);
    }
    if (state === 'stopped' && result === 'success') {
      setTimeout(() => {
        handleEndTask({ taskComplete: true });
      }, 500);
    }
  }, [pollResponse, dispatch, setTaskErrored,
    setPolling, setIsOpen, pollResponseStatus, handleEndTask]);

  if (saving) {
    return <Loading />;
  }
  if (polling && pollResponse) {
    return (
      <>
        <EmptyState style={{ marginTop: '10px' }} variant={EmptyStateVariant.large}>
          <EmptyStateIcon icon={InProgressIcon} />
          <Title headingLevel="h2" size="lg">
            {__('Publishing content view')}
          </Title>
        </EmptyState>
        <Grid hasGutter>
          <GridItem span={12} rowSpan={19}>
            <Progress
              value={progressCompleted()}
              title={__('In progress')}
              measureLocation={ProgressMeasureLocation.outside}
              variant={taskErrored ? ProgressVariant.danger : ProgressVariant.default}
              size={ProgressSize.lg}
            />
          </GridItem>
          <GridItem style={{ marginTop: '10px' }} span={12} rowSpan={1}>
            <Bullseye>
              <Button
                onClick={() => {
                  handleEndTask({ taskComplete: false });
                }}
                variant="primary"
                aria-label="publish_content_view"
              >
                {__('Close')}
              </Button>
              <Button
                component="a"
                aria-label="view tasks button"
                href={`/foreman_tasks/tasks/${pollResponse.id}`}
                target="_blank"
                variant="link"
              >
                {__(' View task details ')}
                <ExternalLinkAltIcon />
              </Button>
            </Bullseye>
          </GridItem>
        </Grid>
      </>
    );
  }
  if (status === STATUS.PENDING) return (<Loading />);
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);
  return <Loading />;
};

CVPublishFinish.propTypes = {
  cvId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]).isRequired,
  forcePromote: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  description: PropTypes.string.isRequired,
  setDescription: PropTypes.func.isRequired,
  userCheckedItems: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  setUserCheckedItems: PropTypes.func.isRequired,
  setIsOpen: PropTypes.func.isRequired,
  versionCount: PropTypes.number.isRequired,
  currentStep: PropTypes.number.isRequired,
  setCurrentStep: PropTypes.func.isRequired,
};


export default CVPublishFinish;
