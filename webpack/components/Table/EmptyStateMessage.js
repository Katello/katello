import React from 'react';
import {
  EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  Bullseye,
  Title,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { CubeIcon, ExclamationCircleIcon, SearchIcon, CheckCircleIcon } from '@patternfly/react-icons';
import { global_danger_color_200 as dangerColor, global_success_color_100 as successColor } from '@patternfly/react-tokens';

const KatelloEmptyStateIcon = ({ error, search, customIcon, happyIcon }) => {
  if (error) return <EmptyStateIcon icon={ExclamationCircleIcon} color={dangerColor.value} />;
  if (search) return <EmptyStateIcon icon={SearchIcon} />;
  if (happyIcon) return <EmptyStateIcon icon={CheckCircleIcon} color={successColor.value} />;
  if (customIcon) return <EmptyStateIcon icon={customIcon} />;
  return <EmptyStateIcon icon={CubeIcon} />;
};

const EmptyStateMessage = ({
  title, body, error, search, customIcon, happy,
}) => {
  let emptyStateTitle = title;
  let emptyStateBody = body;
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
  return (
    <Bullseye>
      <EmptyState variant={happy ? EmptyStateVariant.large : EmptyStateVariant.small}>
        <KatelloEmptyStateIcon error={!!error} search={search} customIcon={customIcon} happyIcon={happy} />
        <Title headingLevel="h2" size="lg">
          {emptyStateTitle}
        </Title>
        <EmptyStateBody>
          {emptyStateBody}
        </EmptyStateBody>
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
  body: PropTypes.string,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  search: PropTypes.bool,
  customIcon: PropTypes.elementType,
};

EmptyStateMessage.defaultProps = {
  title: __('Unable to connect'),
  body: __('There was an error retrieving data from the server. Check your connection and try again.'),
  error: undefined,
  search: false,
  customIcon: undefined,
};

export default EmptyStateMessage;
