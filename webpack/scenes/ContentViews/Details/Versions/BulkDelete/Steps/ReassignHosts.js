import React, {
  useContext,
  useState,
} from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { first } from 'lodash';
import { FormattedMessage } from 'react-intl';
import {
  useDispatch,
  useSelector,
} from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';

import {
  Button,
  ExpandableSection,
  Popover,
  PopoverPosition,
  Select,
  SelectDirection,
  SelectOption,
  TextContent,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';

import EnvironmentPaths
  from '../../../../components/EnvironmentPaths/EnvironmentPaths';
import WizardHeader from '../../../../components/WizardHeader';
import getContentViews from '../../../../ContentViewsActions';
import {
  selectContentViews,
  selectContentViewStatus,
} from '../../../../ContentViewSelectors';
import AffectedHosts from '../../Delete/affectedHosts';
import { BulkDeleteContext } from '../BulkDeleteContextWrapper';
import {
  getEnvironmentList,
  getNumberOfActivationKeys,
  getNumberOfHosts,
} from '../BulkDeleteHelpers';

export default () => {
  const dispatch = useDispatch();
  const {
    versions,
    setSelectedEnvForAK,
    setSelectedCVForAK,
    selectedEnvForHosts,
    setSelectedEnvForHosts,
    selectedCVForHosts,
    setSelectedCVForHosts,
  } = useContext(BulkDeleteContext);

  const { results = [] } = useSelector(selectContentViews);
  const { content_view: { name: cvName, id: cvId } } = first(versions);
  const contentViewsInEnvStatus = useSelector(selectContentViewStatus);
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [toggleCVSelect, setToggleCVSelect] = useState(false);

  const numberOfHosts = getNumberOfHosts(versions);
  const numberOfAKs = getNumberOfActivationKeys(versions);
  const versionEnvironments = getEnvironmentList(versions);

  useDeepCompareEffect(
    () => {
      if (selectedEnvForHosts.length) {
        dispatch(getContentViews({
          environment_id: first(selectedEnvForHosts).id,
          include_default: true,
          full_result: true,
        }));
      }
    },
    [selectedEnvForHosts, dispatch],
  );

  const contentViewEligible = (id) => {
    if (id === cvId) {
      return (versionEnvironments.filter(env =>
        env.id === first(selectedEnvForHosts)?.id).length === 0);
    }
    return true;
  };

  const selectOptions = results.filter(({ id }) => contentViewEligible(id))
    .map(({ id, name }) => (
      <SelectOption
        key={id}
        value={id}
      >
        {name}
      </SelectOption>));

  const placeHolder = (() => {
    switch (true) {
    case cvInEnvLoading && !!selectedEnvForHosts.length:
      return __('Loading...');
    case selectedEnvForHosts.length === 0:
      return __('Select an environment above');
    case selectOptions.length > 0:
      return __('Select a content view');
    default:
      return __('No content views available');
    }
  })();

  const setUserCheckedItems = (value) => {
    setSelectedCVForHosts(null);
    setSelectedEnvForHosts(value);
    if (numberOfAKs) {
      setSelectedCVForAK(null);
      setSelectedEnvForAK(value);
    }
  };

  const onSelect = (_event, selection) => {
    setSelectedCVForHosts(selection);
    if (numberOfAKs) {
      setSelectedCVForAK(selection);
    }
    setToggleCVSelect(false);
  };

  const contentHostHref =
    `/content_hosts?search=content_view = ${cvName} AND ( ${versionEnvironments.map(({ name }) =>
      `lifecycle_environment = ${name}`).join(' OR ')})`;
  return (
    <>
      <WizardHeader
        title={numberOfHosts > 1 ?
          __('Reassign affected hosts') :
          __('Reassign affected host')}
        description={
          <>
            <FormattedMessage
              id="there-are-x-hosts"
              values={{
                numberOfHosts,
              }}
              defaultMessage={numberOfHosts > 1 ?
                __('There are {numberOfHosts} hosts that need to be reassigned.') :
                __('There is {numberOfHosts} host that needs to be reassigned.')
              }
            />
            <br />
            <>
              {numberOfHosts > 1 ?
                __('Select a lifecycle environment and a content view to move these hosts.') :
                __('Select a lifecycle environment and a content view to move this host.')}
              <Popover
                appendTo={() => document.body}
                aria-label="contentHost-prefer-portions-popover"
                position={PopoverPosition.top}
                bodyContent={
                  <>
                    {__('Before removing versions you must move hosts to an environment where the associated version is not in use. ')}
                    <FormattedMessage
                      id="click-here-if-you-would-prefer-hosts"
                      values={{
                        clickHere: (<a href={contentHostHref}>{__('click here')}</a>),
                      }}
                      defaultMessage={__('If you would prefer to move some of these hosts to different content views or environments then {clickHere} to manage these hosts individually.')
                      }
                    />
                  </>
                }
              >
                <Button ouiaId="reassign-hosts-info" style={{ padding: '8px' }} variant="plain" aria-label="popoverButton">
                  <OutlinedQuestionCircleIcon />
                </Button>
              </Popover>
            </>
          </>
        }
      />
      <ExpandableSection
        toggleTextCollapsed={__('Show affected hosts')}
        toggleTextExpanded={__('Hide affected hosts')}
      >
        <AffectedHosts
          {...{
            cvId,
            versionEnvironments,
          }}
          deleteCV
        />
      </ExpandableSection >
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHosts}
        setUserCheckedItems={setUserCheckedItems}
        publishing={false}
        headerText={__('Select an environment')}
        multiSelect={false}
      />
      <TextContent>
        {__('Select a content view')}
      </TextContent>
      <Select
        selections={selectedCVForHosts}
        onSelect={onSelect}
        isDisabled={cvInEnvLoading || !selectOptions?.length || !selectedEnvForHosts?.length}
        id="selectCV"
        name="selectCV"
        aria-label="selectCV"
        placeholderText={placeHolder}
        isOpen={toggleCVSelect}
        onToggle={setToggleCVSelect}
        menuAppendTo={() => document.body}
        direction={SelectDirection.up}
        maxHeight={300}
        width={350}
      >
        {selectOptions}
      </Select>
    </>
  );
};

