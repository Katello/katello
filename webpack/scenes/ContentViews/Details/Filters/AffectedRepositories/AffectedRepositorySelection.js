import React, { useState } from 'react';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Select, SelectOption } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectCVFilterDetails } from '../../ContentViewDetailSelectors';
import { editCVFilter, getCVFilterDetails } from '../../ContentViewDetailActions';

const AffectedRepositorySelection = ({
  cvId, filterId, setShowAffectedRepos, disabled,
}) => {
  const dispatch = useDispatch();
  const response = useSelector(state => selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const { repositories = [] } = response;
  const [type, setType] = useState(repositories.length ? 'affect_repos' : 'all_repos');
  const [typeSelectOpen, setTypeSelectOpen] = useState(false);

  const onSelect = (event, selection) => {
    if (selection === 'all_repos') {
      setShowAffectedRepos(false);
      if (repositories.length) {
        dispatch(editCVFilter(
          filterId,
          { id: filterId, repository_ids: [] },
          () => {
            dispatch(getCVFilterDetails(cvId, filterId));
          },
        ));
      }
    }
    if (selection === 'affect_repos') {
      setShowAffectedRepos(true);
    }
    setType(selection);
    setTypeSelectOpen(false);
  };

  return (
    <Select
      ouiaId="affected-repos"
      selections={type}
      onSelect={onSelect}
      isOpen={typeSelectOpen}
      onToggle={isExpanded => setTypeSelectOpen(isExpanded)}
      id="affected_repos"
      name="affected_repos"
      aria-label="affected_repos"
      isDisabled={disabled}
    >
      <SelectOption key="all_repos" value="all_repos">{__('Apply to all repositories in the CV')}</SelectOption>
      <SelectOption key="affect_repos" value="affect_repos">{__('Apply to subset of repositories')}</SelectOption>
    </Select>
  );
};

AffectedRepositorySelection.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
  disabled: PropTypes.bool,
};

AffectedRepositorySelection.defaultProps = {
  disabled: false,
};
export default AffectedRepositorySelection;
