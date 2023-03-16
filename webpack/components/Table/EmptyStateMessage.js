import React from 'react';
import {
  EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  EmptyStateSecondaryActions,
  Bullseye,
  Title,
  Button,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { CubeIcon, ExclamationCircleIcon, SearchIcon, CheckCircleIcon, PlusCircleIcon } from '@patternfly/react-icons';
import { global_danger_color_200 as dangerColor, global_success_color_100 as successColor } from '@patternfly/react-tokens';
import { useDispatch, useSelector } from 'react-redux';
import { selectHostDetailsClearSearch } from '../extensions/HostDetails/HostDetailsSelectors';

const KatelloEmptyStateIcon = ({
  error, search, customIcon, happyIcon,
}) => {
  if (error) return <EmptyStateIcon icon={ExclamationCircleIcon} color={dangerColor.value} />;
  if (search) return <EmptyStateIcon icon={SearchIcon} />;
  if (happyIcon) return <EmptyStateIcon icon={CheckCircleIcon} color={successColor.value} />;
  if (customIcon) return <EmptyStateIcon icon={customIcon} />;
  return <EmptyStateIcon icon={CubeIcon} />;
};

const EmptyStateMessage = ({
  title, body, error, search,
  customIcon, happy, ...extraTableProps
}) => {
  let emptyStateTitle = title;
  let emptyStateBody = body;
  const {
    primaryActionTitle, showPrimaryAction, showSecondaryAction, showSecondaryActionButton,
    secondaryActionTitle, primaryActionLink, secondaryActionLink, searchIsActive, resetFilters,
    filtersAreActive, requestKey, primaryActionButton, secondaryActionTextOverride,
  } = extraTableProps;
  if (error) {
    if (error?.response?.data?.error) {
      const { response: { data: { error: { message, details } } } } = error;
      emptyStateTitle = message;
      emptyStateBody = details;
    } else if (error?.response?.status) {
      const { response: { status } } = error;
      emptyStateTitle = status;
      emptyStateBody = error?.response?.data?.displayMessage || __('Something went wrong! Please check server logs!');
    }
  }
  const defaultSecondaryActionText = searchIsActive ? __('Clear search') : __('Clear filters');
  const secondaryActionText = secondaryActionTextOverride || defaultSecondaryActionText;
  const dispatch = useDispatch();
  const clearSearch = useSelector(selectHostDetailsClearSearch);
  const showSecondaryActionAnchor = showSecondaryAction && secondaryActionLink;
  const handleClick = () => {
    if (searchIsActive) {
      clearSearch();
    }
    if (filtersAreActive || showSecondaryActionButton) {
      resetFilters();
    }
    dispatch({
      type: `${requestKey}_REQUEST`,
      key: requestKey,
    });
  };

  const actionButton = primaryActionButton ?? (
    <Button ouiaId="empty-state-primary-action-button">
      <a href={primaryActionLink} style={{ color: 'white', textDecoration: 'none' }}>{primaryActionTitle}</a>
    </Button>
  );
  return (
    <Bullseye>
      <EmptyState
        variant={happy ? EmptyStateVariant.large : EmptyStateVariant.small}
      >
        <KatelloEmptyStateIcon
          error={!!error}
          search={search && !showPrimaryAction}
          customIcon={PlusCircleIcon}
          happyIcon={happy}
        />
        <Title headingLevel="h2" size="lg" ouiaId="empty-state-title">
          {emptyStateTitle}
        </Title>
        <EmptyStateBody>
          {emptyStateBody}
        </EmptyStateBody>
        {showPrimaryAction && actionButton}
        {showSecondaryActionAnchor &&
          <EmptyStateSecondaryActions>
            <Button variant="link" ouiaId="empty-state-secondary-action-link">
              {extraTableProps.secondaryActionTargetBlank ? (
                <a href={secondaryActionLink} target="_blank" rel="noreferrer" style={{ textDecoration: 'none' }} >{secondaryActionTitle}</a>
              ) : (
                <a href={secondaryActionLink} style={{ textDecoration: 'none' }} >{secondaryActionTitle}</a>
              )}
            </Button>
          </EmptyStateSecondaryActions>
        }

        {(!showSecondaryActionAnchor &&
          (showSecondaryActionButton || searchIsActive || !!filtersAreActive)) &&
          <EmptyStateSecondaryActions>
            <Button variant="link" onClick={handleClick} ouiaId="empty-state-secondary-action-router-link">
              {secondaryActionText}
            </Button>
          </EmptyStateSecondaryActions>
        }
      </EmptyState>
    </Bullseye>
  );
};


KatelloEmptyStateIcon.propTypes = {
  error: PropTypes.bool,
  search: PropTypes.bool,
  customIcon: PropTypes.elementType,
  happyIcon: PropTypes.bool,
};

KatelloEmptyStateIcon.defaultProps = {
  error: false,
  search: false,
  customIcon: undefined,
  happyIcon: undefined,
};

EmptyStateMessage.propTypes = {
  title: PropTypes.string,
  body: PropTypes.oneOfType([PropTypes.string, PropTypes.shape({})]),
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  search: PropTypes.bool,
  customIcon: PropTypes.elementType,
  happy: PropTypes.bool,
  searchIsActive: PropTypes.bool,
  activeFilters: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string),
  ])),
  defaultFilters: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string),
  ])),
  // eslint-disable-next-line react/require-default-props
  resetFilters: (props, propName) => {
    if (props.showSecondaryActionButton || props.defaultFilters?.length
        || props.activeFilters?.length) {
      if (typeof props[propName] !== 'function') {
        return new Error(`A ${propName} function is required when using activeFilters, defaultFilters, or showSecondaryActionButton`);
      }
    }
    return null;
  },
  showPrimaryAction: PropTypes.bool,
  showSecondaryAction: PropTypes.bool,
  primaryActionButton: PropTypes.element,
};

EmptyStateMessage.defaultProps = {
  title: __('Unable to connect'),
  body: __('There was an error retrieving data from the server. Check your connection and try again.'),
  error: undefined,
  search: false,
  customIcon: undefined,
  happy: false,
  searchIsActive: false,
  activeFilters: [],
  defaultFilters: [],
  showPrimaryAction: false,
  showSecondaryAction: false,
  primaryActionButton: undefined,
};

export default EmptyStateMessage;
