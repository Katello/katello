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
import AffectedActivationKeys from '../../Delete/affectedActivationKeys';
import { BulkDeleteContext } from '../BulkDeleteContextWrapper';
import {
  getEnvironmentList,
  getNumberOfActivationKeys,
} from '../BulkDeleteHelpers';

export default () => {
  const dispatch = useDispatch();
  const {
    selectedEnvForAK,
    setSelectedEnvForAK,
    versions,
    selectedCVForAK,
    setSelectedCVForAK,
  } = useContext(BulkDeleteContext);

  const { results = [] } = useSelector(selectContentViews);
  const { content_view: { id: cvId } } = first(versions);
  const contentViewsInEnvStatus = useSelector(selectContentViewStatus);
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [toggleCVSelect, setToggleCVSelect] = useState(false);

  const numberOfActivationKeys = getNumberOfActivationKeys(versions);
  const versionEnvironments = getEnvironmentList(versions);

  useDeepCompareEffect(
    () => {
      if (selectedEnvForAK.length) {
        dispatch(getContentViews({
          environment_id: first(selectedEnvForAK).id,
          include_default: true,
          full_result: true,
        }));
      }
    },
    [selectedEnvForAK, dispatch],
  );

  const contentViewEligible = (id) => {
    if (id === cvId) {
      return (versionEnvironments.filter(env =>
        env.id === first(selectedEnvForAK)?.id).length === 0);
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
    case cvInEnvLoading && !!selectedEnvForAK.length:
      return __('Loading...');
    case selectedEnvForAK.length === 0:
      return __('Select an environment above');
    case selectOptions.length > 0:
      return __('Select a content view');
    default:
      return __('No content views available');
    }
  })();

  const setUserCheckedItems = (value) => {
    setSelectedCVForAK(null);
    setSelectedEnvForAK(value);
  };

  const onSelect = (_event, selection) => {
    setSelectedCVForAK(selection);
    setToggleCVSelect(false);
  };

  return (
    <>
      <WizardHeader
        title={numberOfActivationKeys > 1 ?
          __('Reassign affected activation keys') :
          __('Reassign affected activation key')}
        description={
          <>
            <FormattedMessage
              id="there-are-x-activation-keys"
              values={{
                numberOfActivationKeys,
              }}
              defaultMessage={numberOfActivationKeys > 1 ?
                __('There are {numberOfActivationKeys} activation keys that need to be reassigned.') :
                __('There is {numberOfActivationKeys} activation key that needs to be reassigned.')
              }
            />
            <br />
            <>
              {numberOfActivationKeys > 1 ?
                __('Please select a lifecycle environment and a content view to move these activation keys.') :
                __('Please select a lifecycle environment and a content view to move this activation key.')}
              <Popover
                appendTo={() => document.body}
                aria-label="activationKeys-popover"
                position={PopoverPosition.top}
                bodyContent={
                  __('Before removing versions you must move activation keys to an environment where the associated version is not in use.')
                }
              >
                <Button style={{ padding: '8px' }} variant="plain" aria-label="popoverButton">
                  <OutlinedQuestionCircleIcon />
                </Button>
              </Popover>
            </>
          </>
        }
      />
      <ExpandableSection
        toggleTextCollapsed={__('Show affected activation keys')}
        toggleTextExpanded={__('Hide affected activation keys')}
      >
        <AffectedActivationKeys
          {...{
            cvId,
          }}
          versionEnvironments={versionEnvironments}
          deleteCV
        />
      </ExpandableSection >
      <EnvironmentPaths
        userCheckedItems={selectedEnvForAK}
        setUserCheckedItems={setUserCheckedItems}
        publishing={false}
        headerText={__('Select an environment')}
        multiSelect={false}
      />
      <TextContent>
        {__('Select a content view')}
      </TextContent>
      <Select
        selections={selectedCVForAK}
        onSelect={onSelect}
        isDisabled={cvInEnvLoading || !selectOptions?.length || !selectedEnvForAK?.length}
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

