import React, { useState } from 'react';
import {
  Alert,
  Grid,
  GridItem,
  CodeBlock,
  CodeBlockAction,
  CodeBlockCode,
  ClipboardCopyButton,
  ExpandableSection,
  ExpandableSectionToggle,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import { copyToClipboard } from '../helpers';

const ContentSourceTemplate = ({ template }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [isCopied, setCopied] = useState(false);

  const handleCopy = (e) => {
    copyToClipboard(e, template);
    setCopied(true);
  };

  const actions = (
    <CodeBlockAction>
      <ClipboardCopyButton
        onClick={e => handleCopy(e)}
        exitDelay={600}
        maxWidth="110px"
        variant="plain"
      >
        {isCopied ? __('Copied to clipboard') : __('Copy to clipboard')}
      </ClipboardCopyButton>
    </CodeBlockAction>
  );

  return (
    <Grid>
      <GridItem span={7}>
        <Alert
          ouiaId="host-server-content-source-complete"
          variant="info"
          title={__('Configuration updated on Foreman')}
          className="margin-top-20"
          isInline
        />
        <Alert
          ouiaId="host-configuration-alert"
          variant="warning"
          title={__('Configuration still must be updated on hosts')}
          className="margin-top-20"
          isInline
        >
          {__('To finish the process of changing hosts\' content source, run the following script manually on the host(s).')}
        </Alert>

      </GridItem>
      <GridItem span={7}>
        <CodeBlock actions={actions} className="cs_template_code margin-top-20">
          <CodeBlockCode>
            {__('Change content source')}
            <ExpandableSection isExpanded={isExpanded} isDetached>
              {template}
            </ExpandableSection>
          </CodeBlockCode>
          <ExpandableSectionToggle
            isExpanded={isExpanded}
            onToggle={() => setIsExpanded(!isExpanded)}
            contentId="code-block-expand"
            direction="up"
          >
            {isExpanded ? 'Show less' : 'Show more'}
          </ExpandableSectionToggle>
        </CodeBlock>
      </GridItem>
    </Grid>);
};

ContentSourceTemplate.propTypes = {
  template: PropTypes.string,
};

ContentSourceTemplate.defaultProps = {
  template: '',
};

export default ContentSourceTemplate;
