import Immutable from 'seamless-immutable';

const contentCredentialsResponse = Immutable({
  total: 2,
  subtotal: 2,
  selectable: 2,
  page: 1,
  per_page: 20,
  error: null,
  search: null,
  sort: {
    by: 'name',
    order: 'asc',
  },
  results: [
    {
      name: 'DevelServerCA',
      content_type: 'cert',
      content: '-----BEGIN CERTIFICATE-----\r\nMIIHHzCCBQegAwIBAgIJAIUIoI5kWBt2MA0GCSqGSIb3DQEBCwUAMIGTMQswCQYD\r\nVQQGEwJVUzEXMBUGA1UECAwOTm9ydGggQ2Fyb2xpbmExEDAOBgNVBAcMB1JhbGVp\r\nZ2gxEDAOBgNVBAoMB0thdGVsbG8xFDASBgNVBAsMC1NvbWVPcmdVbml0MTEwLwYD\r\nVQQDDChjZW50b3M3LWthdGVsbG8tZGV2ZWwuanR1cmVsLmV4YW1wbGUuY29tMB4X\r\nDTIxMDcyOTE1MDgwNVoXDTM4MDExODE1MDgwNVowgZMxCzAJBgNVBAYTAlVTMRcw\r\nFQYDVQQIDA5Ob3J0aCBDYXJvbGluYTEQMA4GA1UEBwwHUmFsZWlnaDEQMA4GA1UE\r\nCgwHS2F0ZWxsbzEUMBIGA1UECwwLU29tZU9yZ1VuaXQxMTAvBgNVBAMMKGNlbnRv\r\nczcta2F0ZWxsby1kZXZlbC5qdHVyZWwuZXhhbXBsZS5jb20wggIiMA0GCSqGSIb3\r\nDQEBAQUAA4ICDwAwggIKAoICAQC4WsCZQpmOrRis/o9IsyW03vUon4FXPD00zm33\r\nykygAktyD93FAY0QhDMGnir+c9Uo3kU194QDyLTcGrOTw2POLHR/GDX7G4H5qEO9\r\nq1ZrGho4bYcgFqMBaGtFwpOuU4MhbgbKnwvfqNqPypshNpah74zcih9tey7fyCxd\r\nSIkarp8zB1bGcec5uvVDEd1EwjnrCSGx7Me1v61n0Fb7SrGlPa3qJC2bsL+jj1DF\r\nMukGEVsUxqvRMXe6i1jy4W7rWNUIsX2vIne1wup4qeojJy9zWWhwi5aGx6mIsUHN\r\nCqyfG+qNgkuJ1DfaZ2DwC8VJ6H17Gzzw7HdkQ4aYqk1hGvpJMS2WXR3vsP7OUO1S\r\n3qeGipksp5e/IEVX7fq+RUEMwrTDDgBsIeHL8R9hOsdtdqOm4RJ1IcGG0tgMA64q\r\nH0qFj0YheqO0x5rM5fD0Xh6TokQO9slSZRjjc4LfhcsRf8oqHfzm8v8dT0HQToNI\r\nDfvmg2TyxPAGsun0/b+9k5UBEIqpoByFPjR5oaH46oAzjiQm40lw8aMkEWK0n/41\r\n601neQMqwJdXsXt20Zz3UeLf8n09lDGUSYVztJkglV3vMNlrWn7hYrPPr1xq7zMs\r\ntfziExBctw2j5xOjOCMf7rt67SqmrQwurr4hSLJ3Iz+4JOd2ksVrjfHfv3/bc/Nk\r\nqgGQZwIDAQABo4IBcjCCAW4wDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAaYwHQYD\r\nVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMBEGCWCGSAGG+EIBAQQEAwICRDA1\r\nBglghkgBhvhCAQ0EKBYmS2F0ZWxsbyBTU0wgVG9vbCBHZW5lcmF0ZWQgQ2VydGlm\r\naWNhdGUwHQYDVR0OBBYEFEgCBjRDDqs9/Vb4D/rDuddgqGTGMIHIBgNVHSMEgcAw\r\ngb2AFEgCBjRDDqs9/Vb4D/rDuddgqGTGoYGZpIGWMIGTMQswCQYDVQQGEwJVUzEX\r\nMBUGA1UECAwOTm9ydGggQ2Fyb2xpbmExEDAOBgNVBAcMB1JhbGVpZ2gxEDAOBgNV\r\nBAoMB0thdGVsbG8xFDASBgNVBAsMC1NvbWVPcmdVbml0MTEwLwYDVQQDDChjZW50\r\nb3M3LWthdGVsbG8tZGV2ZWwuanR1cmVsLmV4YW1wbGUuY29tggkAhQigjmRYG3Yw\r\nDQYJKoZIhvcNAQELBQADggIBAAVm6c0Rv5m2twcqAwlPLPQVBqBVE3k0+2/4zO0d\r\nNkVz9FPoD5v6psKEBnQS/qQ5pMmCTqJipG4BtVTHh0nLahi0bjHo1uesj/kZg5hg\r\nVbRPDIAhFXAOg1M2qV74DHCaCv1ALYgz6TlZFkeBfg4m/H9eucIKezgZaV/CNhWk\r\nBeKaOgh7qQl8qTCp0CL97csmfmxLe51EzejNXAXjwwZ2R4438mR2K252fbzts0LS\r\nq9Dfx1XK0HmS0l5dhMFYfBQ4nY0ZQ/jgb/h8SxLTeKPJOHHdhzse6IL1f2rBIWL2\r\nmH7bLn8rfQaqyXZh/iKpY/xxVauCSsQcYVNaXOF66h20/wtPIQWx1xxzgnUa3/xW\r\nuMCocIzG3vBBBDeVs8M0mTTxMGRtfx2KMj7wZv6trq2SSyUtVk1CWn80iv8PQUfn\r\nOQwecX1cMdh5K21fK16aAlB48VKXpuxKQPxGYdNSFYVnadMgXvdQAyofjwGWCzWL\r\n9C/N37gtz8WsFXr54QYWkKlbuvYM1tuUNaZdySTW0RPO4Eqbmogh3ffDtrq8RaHh\r\nPBtTLwxf0LZgqqOCxGFhgPrVt3vhj8K9G5IC9dzl7lGamQ8YDJRuBkAhmtD5yxL7\r\nwAmqhAMBTDvNRT83b9WiMAakRVjuWgwIcDwzgeCErjCPCVTFP7Gvl1HveVvFsPXR\r\n7GZO\r\n-----END CERTIFICATE-----\r\n',
      id: 6,
      organization_id: 4,
      organization: {
        name: 'ISS',
        label: 'ISS',
        id: 4,
      },
      created_at: '2021-10-28 16:50:48 -0400',
      updated_at: '2021-10-28 16:50:48 -0400',
      gpg_key_products: [],
      gpg_key_repos: [],
      ssl_ca_products: [],
      ssl_ca_root_repos: [],
      ssl_client_products: [],
      ssl_client_root_repos: [],
      ssl_key_products: [],
      ssl_key_root_repos: [],
      permissions: {
        view_content_credenials: true,
        edit_content_credenials: true,
        destroy_content_credenials: true,
      },
    },
    {
      name: 'UpstreamServerCA',
      content_type: 'cert',
      content: '-----BEGIN CERTIFICATE-----\nMIIHGTCCBQGgAwIBAgIJAK+PvWdMGcRbMA0GCSqGSIb3DQEBCwUAMIGRMQswCQYD\nVQQGEwJVUzEXMBUGA1UECAwOTm9ydGggQ2Fyb2xpbmExEDAOBgNVBAcMB1JhbGVp\nZ2gxEDAOBgNVBAoMB0thdGVsbG8xFDASBgNVBAsMC1NvbWVPcmdVbml0MS8wLQYD\nVQQDDCZjZW50b3M3LWthdGVsbG8tNC0yLmp0dXJlbC5leGFtcGxlLmNvbTAeFw0y\nMTEwMjYxNTQzMjlaFw0zODAxMTcxNTQzMjlaMIGRMQswCQYDVQQGEwJVUzEXMBUG\nA1UECAwOTm9ydGggQ2Fyb2xpbmExEDAOBgNVBAcMB1JhbGVpZ2gxEDAOBgNVBAoM\nB0thdGVsbG8xFDASBgNVBAsMC1NvbWVPcmdVbml0MS8wLQYDVQQDDCZjZW50b3M3\nLWthdGVsbG8tNC0yLmp0dXJlbC5leGFtcGxlLmNvbTCCAiIwDQYJKoZIhvcNAQEB\nBQADggIPADCCAgoCggIBALKfp6gXOiyUU9z7b1Zrg4arCQ1QK8J2PvwVJo+NeNZC\nVnUzw3hof0rIovL4/cUUpZYGtCME0PSthxsnYwRSXALW2Gmy3qIm6k+3K524+yYX\n9PWE1CVCPjgboLfBIrkb1WlviZZ4pKdoPxF2DUUksw4T9inpeir/Nlul9dEvbGHw\nIXkNxolVrkrD2bD9C0z+JjzfLwlJ8CH/FX/tan3jMUqKF70Gi5MEyL6TDhHmduGG\nNPywwdC5oH6jUg94w38SdVovI7uHb/Pu5Kgw9sVBAZ4I+7vQqFL0M8YG/Di/kp/V\nLlqqRxjn1T7FepMo/gNWb3Yc9ZBcSyxHgqHlZi/dy4zW+l/y3OgCGekGkma5IjzY\n9qJyNxGUXennAMkjW1+P40CLFuqN77rmV7dYwIR+jcPmzhz1eEhkLNyNfvcQlVTf\nCCkqaX53kVH4Cu4MFcWFs74W9v5BiPydhhzfy7O3rhDCrIu7Z9A5Qt0d3Ctj5x/C\ny2sj+oO35QGhj0KsjuvCfR3HxojSNfjM65tkKzdSRDt9hYP8+Up2YT6EDo72Mp6m\ndAiwrPxiAUOQDVEhzeEjMN8Cgsb3vyOy1cnYCttgiPXvTdGOt5NTUoolWn4ubBOY\nnLROTPyJmqevhQjcxQdSwsjPkFnZWFx6xB6WT10leFGFhclUa2lHVWHn5r9ZZf75\nAgMBAAGjggFwMIIBbDAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBpjAdBgNVHSUE\nFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwEQYJYIZIAYb4QgEBBAQDAgJEMDUGCWCG\nSAGG+EIBDQQoFiZLYXRlbGxvIFNTTCBUb29sIEdlbmVyYXRlZCBDZXJ0aWZpY2F0\nZTAdBgNVHQ4EFgQUdMirW7cQqNXyPyRXrrEb38l2sq8wgcYGA1UdIwSBvjCBu4AU\ndMirW7cQqNXyPyRXrrEb38l2sq+hgZekgZQwgZExCzAJBgNVBAYTAlVTMRcwFQYD\nVQQIDA5Ob3J0aCBDYXJvbGluYTEQMA4GA1UEBwwHUmFsZWlnaDEQMA4GA1UECgwH\nS2F0ZWxsbzEUMBIGA1UECwwLU29tZU9yZ1VuaXQxLzAtBgNVBAMMJmNlbnRvczct\na2F0ZWxsby00LTIuanR1cmVsLmV4YW1wbGUuY29tggkAr4+9Z0wZxFswDQYJKoZI\nhvcNAQELBQADggIBAFriP91uFIPUOwrgVqbFDWykSWQtcP8NrvPJ5LPCkjhSgh6u\nnOL9ZDL2w6/oYzO70q/tQmWbBwnYfv+D5lrHjkXejXIpR2rjOPZbTSKLst0qtTF3\nwqK33vty7jTx/l91dV8HY/Ip/WoXPmGT8FmDN8UWXX6MGA6m6nPMQCJuDYCmXaEz\nMQNd6Hgew0ArtgY4dPTvK0vmvMgEXw9v3FY8xIbgoAzoZ44/C/X5OodkJRPL8qwx\nwEWlPLe4a53WD/jU+qKJA71J4DL+QiXREDfVeuoqRAvWt4NrN0emEgDGlXn+gybS\nbU4s2GotQQKgqbmk9yA0/ZsZbd8zAV13CtRhiApsCPwO6YmIgzG0yqbM8VV6hATo\nkYiLmrgaMaIUJpyZze7P4PDSwAeMjqXs9p4oYA/aBD+pJ+OWI/PhPIdyl5e4kr7L\ne8hZkcuOo7Mw7kyvjKWo8zI/v9NJVSDAFXvBWVY+nYXLc7ovfX/msYgvyF2ylAHq\nNqJR6OZQoS1nWz2kYRqn4p3ygNSKUfctNA24CgorMqKLJ0XNJEBSoNV9rRczKghY\nXKScr3j4HnfLeyHmIo05XFPCCh1SfnQDG0H0rDHXNGABJhfNc35Y6TyXZhUgMxit\nQ9Vgl2JTl8+5swzfVdLemBXg4N6ITISkvyL3/keCca3U+4UTPCw9w/qx7+pd\n-----END CERTIFICATE-----',
      id: 4,
      organization_id: 4,
      organization: {
        name: 'ISS',
        label: 'ISS',
        id: 4,
      },
      created_at: '2021-10-28 12:14:10 -0400',
      updated_at: '2021-10-28 16:25:06 -0400',
      gpg_key_products: [],
      gpg_key_repos: [],
      ssl_ca_products: [],
      ssl_ca_root_repos: [],
      ssl_client_products: [],
      ssl_client_root_repos: [],
      ssl_key_products: [],
      ssl_key_root_repos: [],
      permissions: {
        view_content_credenials: true,
        edit_content_credenials: true,
        destroy_content_credenials: true,
      },
    },
  ],
});

export default contentCredentialsResponse;
