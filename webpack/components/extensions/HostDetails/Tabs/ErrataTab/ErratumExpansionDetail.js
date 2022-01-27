import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  DescriptionList,
  DescriptionListTerm as Term,
  DescriptionListGroup,
  DescriptionListDescription as Description,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const ErratumExpansionDetail = ({ erratum }) => {
  const {
    title: synopsis,
    description,
    summary, solution,
  } = erratum;
  const [showDescription, setShowDescription] = useState(false);
  // whiteSpace: 'pre-line' will convert \n to line breaks
  return (
    <DescriptionList>
      <DescriptionListGroup>
        <Term>{__('Synopsis')}</Term>
        <Description>{synopsis}</Description>
      </DescriptionListGroup>
      <DescriptionListGroup>
        <Term>{__('Summary')}</Term>
        <Description>{summary}</Description>
      </DescriptionListGroup>
      <DescriptionListGroup>
        <Term>{__('Solution')}</Term>
        <Description>{solution}</Description>
      </DescriptionListGroup>
      {showDescription &&
        <DescriptionListGroup>
          <Term>{__('Full description')}</Term>
          <Description>
            <span style={{ whiteSpace: 'pre-line' }}>{description}</span>
          </Description>
          <Term>
            <Button variant="link" onClick={() => setShowDescription(false)}>
              {__('Hide description')}
            </Button>
          </Term>
        </DescriptionListGroup>
      }
      {!showDescription &&
        <DescriptionListGroup>
          <Term>
            <Button variant="link" onClick={() => setShowDescription(true)}>
              {__('Show full description')}
            </Button>
          </Term>
        </DescriptionListGroup>
      }
    </DescriptionList>
  );
};

ErratumExpansionDetail.propTypes = {
  erratum: PropTypes.shape({
    title: PropTypes.string,
    description: PropTypes.string,
    summary: PropTypes.string,
    solution: PropTypes.string,
  }).isRequired,
};

export default ErratumExpansionDetail;
