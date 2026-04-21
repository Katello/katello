import React, {
  useContext,
  useState,
} from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { first } from 'lodash';
import { FormattedMessage } from 'react-intl';
import {
  useDispatch,
  useSelector,
} from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';

import { ExpandableSection } from '@patternfly/react-core';
import {
  SelectDirection,
  SelectOption,
} from '@patternfly/react-core/deprecated';

import EnvironmentPaths
  from '../../../../components/EnvironmentPaths/EnvironmentPaths';
import WizardHeader from '../../../../components/WizardHeader';
import getContentViews from '../../../../ContentViewsActions';
import {
  selectContentViews,
  selectContentViewStatus,
} from '../../../../ContentViewSelectors';
import { BulkDeleteContext } from '../BulkDeleteContextWrapper';
import {
  getEnvironmentList,
  getNumberOfHostgroups,
} from '../BulkDeleteHelpers';
import ContentViewSelect from '../../../../components/ContentViewSelect/ContentViewSelect';
import { getCVPlaceholderText, shouldDisableCVSelect } from '../../../../components/ContentViewSelect/helpers';
import AffectedHostgroups from '../../Delete/affectedHostgroups';

export default () => {
  const dispatch = useDispatch();
  const {
    versions,
    selectedEnvForHostgroups,
    setSelectedEnvForHostgroups,
    selectedCVForHostgroups,
    setSelectedCVForHostgroups,
  } = useContext(BulkDeleteContext);

  const { results = [] } = useSelector(selectContentViews);
  const { content_view: { id: cvId } } = first(versions);
  const contentViewsInEnvStatus = useSelector(selectContentViewStatus);
  const [toggleCVSelect, setToggleCVSelect] = useState(false);
  const [showHostgroups, setShowHostgroups] = useState(false);

  const numberOfHostgroups = getNumberOfHostgroups(versions);
  const versionEnvironments = getEnvironmentList(versions);

  useDeepCompareEffect(
    () => {
      if (selectedEnvForHostgroups.length) {
        dispatch(getContentViews({
          environment_id: first(selectedEnvForHostgroups).id,
          include_default: true,
          full_result: true,
        }));
      }
    },
    [selectedEnvForHostgroups, dispatch],
  );

  const contentViewEligible = (id) => {
    if (id === cvId) {
      return (versionEnvironments.filter(env =>
        env.id === first(selectedEnvForHostgroups)?.id).length === 0);
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

  const placeholderText = getCVPlaceholderText({
    contentSourceId: null,
    environments: selectedEnvForHostgroups,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions: selectOptions,
  });

  const setUserCheckedItems = (value) => {
    setSelectedCVForHostgroups(null);
    setSelectedEnvForHostgroups(value);
  };

  const onClear = () => {
    setSelectedCVForHostgroups(null);
    setSelectedEnvForHostgroups([]);
  };

  const onSelect = (_event, selection) => {
    setSelectedCVForHostgroups(selection);
    setToggleCVSelect(false);
  };

  const disableCVSelect = shouldDisableCVSelect({
    contentSourceId: null,
    environments: selectedEnvForHostgroups,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions: selectOptions,
  });

  return (
    <>
      <WizardHeader
        title={numberOfHostgroups > 1 ?
          __('Reassign affected host groups') :
          __('Reassign affected host group')}
        description={
          <>
            <FormattedMessage
              id="there-are-x-hostgroups"
              values={{
                numberOfHostgroups,
              }}
              defaultMessage={numberOfHostgroups > 1 ?
                __('There are {numberOfHostgroups} host groups that need to be reassigned.') :
                __('There is {numberOfHostgroups} host group that needs to be reassigned.')
              }
            />
            <br />
            {numberOfHostgroups > 1 ?
              __('Select a lifecycle environment and a content view to move these host groups.') :
              __('Select a lifecycle environment and a content view to move this host group.')}
          </>
        }
      />
      <ExpandableSection
        toggleText={showHostgroups ? __('Hide host groups') : __('Show host groups')}
        onToggle={(_event, expanded) => setShowHostgroups(expanded)}
        isExpanded={showHostgroups}
        style={{ marginBottom: '20px' }}
      >
        <AffectedHostgroups cvId={cvId} />
      </ExpandableSection>
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHostgroups}
        setUserCheckedItems={setUserCheckedItems}
        publishing={false}
        headerText={__('Select an environment')}
        multiSelect={false}
      />
      <ContentViewSelect
        selections={selectedCVForHostgroups}
        onSelect={onSelect}
        onClear={onClear}
        isDisabled={disableCVSelect}
        placeholderText={placeholderText}
        isOpen={toggleCVSelect}
        onToggle={setToggleCVSelect}
        menuAppendTo={() => document.body}
        direction={SelectDirection.up}
        maxHeight={300}
        width={350}
      >
        {selectOptions}
      </ContentViewSelect>
    </>
  );
};
