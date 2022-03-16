import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

// a defaultMessage like
// "{count, plural, =0 {No errata} one {# erratum} other {# errata}}"
// will give us properly translated pluralized strings!
// see https://formatjs.io/docs/react-intl/components/#message-syntax
export const TranslatedPlural = ({
  count, singular,
  plural = `${singular}s`,
  zeroMsg = `No ${plural}`,
  id,
  ...props
}) => (
  <FormattedMessage
    defaultMessage={`{count, plural, =0 {${zeroMsg}} one {# ${singular}} other {# ${plural}}}`}
    values={{
      count,
    }}
    id={id}
    {...props}
  />
);

TranslatedPlural.propTypes = {
  count: PropTypes.number.isRequired,
  singular: PropTypes.string.isRequired,
  plural: PropTypes.string,
  zeroMsg: PropTypes.string,
  id: PropTypes.string.isRequired,
};

TranslatedPlural.defaultProps = {
  plural: undefined,
  zeroMsg: undefined,
};

export const TranslatedAnchor = ({
  href, style, ariaLabel, ...props
}) => (
  <a href={href} style={style} aria-label={ariaLabel}>
    <TranslatedPlural
      {...props}
    />
  </a>
);

TranslatedAnchor.propTypes = {
  href: PropTypes.string.isRequired,
  style: PropTypes.shape({}),
  ariaLabel: PropTypes.string.isRequired,
};

TranslatedAnchor.defaultProps = {
  style: undefined,
};
