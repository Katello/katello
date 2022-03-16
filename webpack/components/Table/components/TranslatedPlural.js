import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

// a defaultMessage like
// "{errataTotal, plural, =0 {No errata} one {# erratum} other {# errata}}"
// will give us properly translated pluralized strings!
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

export const TranslatedAnchor = ({ href, style, ...props }) => (
  <a href={href} style={style} >
    <TranslatedPlural
      {...props}
    />
  </a>
);

TranslatedAnchor.propTypes = {
  href: PropTypes.string.isRequired,
  style: PropTypes.shape({}),
};

TranslatedAnchor.defaultProps = {
  style: { marginLeft: 'initial' },
};
