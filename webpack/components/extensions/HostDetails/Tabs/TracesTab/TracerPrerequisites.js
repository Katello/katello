import React from 'react';
import PropTypes from 'prop-types';
import {
  Alert,
  TextList,
  TextListItem,
} from '@patternfly/react-core';
import { ArrowRightIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

const TracerPrerequisites = ({ items, onLinkClick }) => (
  <>
    <Alert
      ouiaId="enable-tracer-modal-prereq-text"
      variant="warning"
      isInline
      title={__('Before continuing, ensure that all of the following prerequisites are met:')}
    />
    <TextList className="enable-tracer-modal-prereq-list">
      {items.map(({
        text, href, linkText, id, itemId,
      }) => (
        <TextListItem key={id || text} id={itemId}>
          {text}
          {href && (
            <>
              <a onClick={onLinkClick} href={href} id={id}>{linkText}</a>
              <ArrowRightIcon />
            </>
          )}
        </TextListItem>
      ))}
    </TextList>
  </>
);

TracerPrerequisites.propTypes = {
  items: PropTypes.arrayOf(PropTypes.shape({
    text: PropTypes.string.isRequired,
    href: PropTypes.string,
    linkText: PropTypes.string,
    id: PropTypes.string,
    itemId: PropTypes.string,
  })).isRequired,
  onLinkClick: PropTypes.func.isRequired,
};

export default TracerPrerequisites;
