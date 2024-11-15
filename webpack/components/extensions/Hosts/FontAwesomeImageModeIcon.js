import React from 'react';
import propTypes from 'prop-types';
import { Tooltip } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const FontAwesomeImageModeIcon = ({ fill, margin, title }) => (
  <Tooltip content={title}>
    <svg
      id="Layer_2"
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 221.37 221.44"
      width="14px"
      height="14px"
      version="1.1"
      xmlSpace="preserve"
      style={{
        fillRule: 'evenodd',
        clipRule: 'evenodd',
        strokeLinejoin: 'round',
        strokeMiterlimit: 2,
        margin: margin || '-2px',
      }}
    >
      <g id="Layer_1-2">
        <circle
          fill={fill}
          className="cls-1"
          cx="77.01"
          cy="87"
          r="20.41"
          transform="translate(-39.07 79) rotate(-45)"
        />
        <path
          className="cls-1"
          fill={fill}
          d="M205.48,40.09L120.07,1.72c-5.84-2.28-12.28-2.29-18.13-.02L15.93,40.09h0C6.25,43.85,0,52.98,0,63.37v91.2c0,9.48,5.5,18.28,14.02,22.44l85.84,41.91c3.45,1.68,7.2,2.52,10.95,2.52,4.03,0,8.05-.97,11.69-2.89l85.58-45.31c8.2-4.34,13.29-12.8,13.29-22.07V63.35c0-10.36-6.24-19.49-15.88-23.26ZM110.97,28.55l82.09,37.07v60.44l-39.44-37.64c-2.09-2.09-5.48-2.09-7.57,0l-60.43,60.43-24.76-24.76c-2.09-2.09-5.48-2.09-7.57,0l-25,26.93v-85.39L110.97,28.55Z"
        />
      </g>
    </svg>
  </Tooltip>
);

FontAwesomeImageModeIcon.propTypes = {
  fill: propTypes.string,
  margin: propTypes.string,
  title: propTypes.string,
};

FontAwesomeImageModeIcon.defaultProps = {
  fill: 'var(--pf-global--palette--black-600)',
  margin: '-2px',
  title: __('Image mode'),
};

export default FontAwesomeImageModeIcon;
