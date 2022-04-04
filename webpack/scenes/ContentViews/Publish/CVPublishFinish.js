import { STATUS } from 'foremanReact/constants';
import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { useHistory } from 'react-router-dom';
import {
  Bullseye, Button, Grid, GridItem,
  Progress, ProgressSize, ProgressMeasureLocation,
  ProgressVariant, EmptyState, EmptyStateIcon, EmptyStateVariant,
  Title,
} from '@patternfly/react-core';
import { ExternalLinkAltIcon, InProgressIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  selectPublishContentViewsError, selectPublishContentViews,
  selectPublishContentViewStatus,
} from './ContentViewPublishSelectors';
import { selectTaskPoll, selectTaskPollStatus } from '../Details/ContentViewDetailSelectors';
import { publishContentView } from '../ContentViewsActions';
import Loading from '../../../components/Loading';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';
import { cvVersionTaskPollingKey } from '../ContentViewsConstants';
import { clearPollTaskData, startPollingTask, stopPollingTask, toastTaskFinished } from '../../Tasks/TaskActions';
import getContentViewDetails from '../Details/ContentViewDetailActions';

const CVPublishFinish = ({
  cvId,
  userCheckedItems,
  forcePromote, description,
  onClose, versionCount, currentStep,
}) => {
  const dispatch = useDispatch();
  const history = useHistory();
  const [publishDispatched, setPublishDispatched] = useState(false);
  const [saving, setSaving] = useState(true);
  const POLLING_TASK_KEY = cvVersionTaskPollingKey(cvId);
  const [taskErrored, setTaskErrored] = useState(false);
  const response = useSelector(state => selectPublishContentViews(state, cvId, versionCount));
  const status = useSelector(state => selectPublishContentViewStatus(state, cvId, versionCount));
  const error = useSelector(state => selectPublishContentViewsError(state, cvId, versionCount));

  const pollResponse = useSelector(state =>
    selectTaskPoll(state, POLLING_TASK_KEY), shallowEqual);
  const pollResponseStatus = useSelector(state =>
    selectTaskPollStatus(state, POLLING_TASK_KEY), shallowEqual);

  const { input: { content_view_version_id: cvvID } = {} } = response;

  const progressCompleted = pollResponse.progress ? pollResponse.progress * 100 : 0;

  // Fire this on load
  useDeepCompareEffect(() => {
    if (currentStep === 3 && !publishDispatched) {
      setPublishDispatched(true);
      dispatch(publishContentView({
        id: cvId,
        versionCount,
        description,
        environment_ids: userCheckedItems.map(item => item.id),
        is_force_promote: (forcePromote.length > 0),
      }, ({ data: task }) => {
        // First callback
        dispatch(startPollingTask(
          POLLING_TASK_KEY, task,
          () => {
            // Second Callback
            setSaving(false);
          },
        ));
      }, () => { setSaving(false); }));
    }
  }, [POLLING_TASK_KEY, currentStep, cvId, description, dispatch, forcePromote,
    publishDispatched, userCheckedItems, versionCount]);

  useDeepCompareEffect(() => {
    const { state, result } = pollResponse;
    if (!state || !result || !publishDispatched || saving) return;
    if (state === 'paused' || result === 'error') {
      setTaskErrored(true);
    }
    if (state === 'stopped' && result === 'success') {
      dispatch(stopPollingTask(POLLING_TASK_KEY));
      dispatch(clearPollTaskData(POLLING_TASK_KEY));
      dispatch(getContentViewDetails(cvId));
      dispatch(toastTaskFinished(pollResponse));
      history.push(`/content_views/${cvId}#/versions/${cvvID || ''}`);
      onClose();
    }
  }, [pollResponse, dispatch, setTaskErrored, pollResponseStatus,
    POLLING_TASK_KEY, cvId, history, taskErrored, cvvID, onClose,
    publishDispatched, saving]);

  if (saving || status === STATUS.PENDING) {
    return <Loading />;
  }

  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);

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
            value={progressCompleted}
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
                dispatch(stopPollingTask(POLLING_TASK_KEY));
                onClose(true);
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
};

CVPublishFinish.propTypes = {
  cvId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]).isRequired,
  forcePromote: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  description: PropTypes.string.isRequired,
  userCheckedItems: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  onClose: PropTypes.func.isRequired,
  versionCount: PropTypes.number.isRequired,
  currentStep: PropTypes.number.isRequired,
};


export default CVPublishFinish;
