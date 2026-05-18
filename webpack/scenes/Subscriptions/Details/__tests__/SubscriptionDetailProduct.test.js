import React from 'react';
import { render, screen } from '@testing-library/react';
import SubscriptionDetailProduct from '../SubscriptionDetailProduct';
import { availableContent } from '../../../Products/__tests__/products.fixtures.js';

describe('subscription detail enabled product component', () => {
  it('renders content details', () => {
    render(<SubscriptionDetailProduct content={availableContent.content} />);

    expect(screen.getByText('Red Hat Enterprise Linux 7 Server (RPMs)')).toBeInTheDocument();
    expect(screen.getByText('Content Download URL')).toBeInTheDocument();
    expect(screen.getByText('/content/dist/rhel/server/7/$releasever/$basearch/os')).toBeInTheDocument();
    expect(screen.getByText('GPG Key URL')).toBeInTheDocument();
    expect(screen.getByText('file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release')).toBeInTheDocument();
    expect(screen.getByText('Repo Type')).toBeInTheDocument();
    expect(screen.getByText('yum')).toBeInTheDocument();
    expect(screen.getByText('Enabled')).toBeInTheDocument();
    expect(screen.getByText('no')).toBeInTheDocument();
  });
});
