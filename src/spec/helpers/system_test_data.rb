module SystemTestData
  class << self

    def guests
      [{"href"=>"/consumers/fcba65f1-5fe4-42e0-8f7b-6c719ec2bc42",
        "facts"=>
      {
        "lscpu.virtualization_type"=>"full",
        "virt.is_guest"=>"true",
        "virt.host_type"=>"kvm",
        "virt.uuid"=>"5ac4f5df-49c9-2d1e-30f6-c84022deda65",
      },
      "name"=>"f16-2",
      "entitlementCount"=>0,
      "lastCheckin"=>"2011-11-09T10:57:57.877+0000",
      "autoheal"=>true,
      "uuid"=>"fcba65f1-5fe4-42e0-8f7b-6c719ec2bc42",
      "guestIds"=>[],
      "username"=>"admin",
      "canActivate"=>false,
      "id"=>"4028fa81338751be0133875709ab0007",
      "type"=>
      {"label"=>"system",
       "id"=>"ff808081337cf90501337cf910ae0001",
       "manifest"=>false,
       "updated"=>"2011-11-07T07:40:57.390+0000",
       "created"=>"2011-11-07T07:40:57.390+0000"},
       "installedProducts"=>[],
       "updated"=>"2011-11-09T10:57:57.882+0000",
       "created"=>"2011-11-09T07:59:48.139+0000",
       "owner"=>
      {"href"=>"/owners/ACME_Corporation",
       "displayName"=>"ACME_Corporation",
       "id"=>"4028fa81338751be01338751f44b0001",
       "key"=>"ACME_Corporation"}}].map(&:with_indifferent_access)
    end

    def host
      {"href"=>"/consumers/f4ca72d5-d087-49e3-a3bd-1012e12328d4",
       "facts"=> { "virt.host_type"=>"Not Applicable",
                   "lscpu.virtualization"=>"VT-x"
      },
        "name"=>"f15",
        "entitlementCount"=>0,
        "lastCheckin"=>"2011-11-09T11:07:42.902+0000",
        "autoheal"=>true,
        "uuid"=>"f4ca72d5-d087-49e3-a3bd-1012e12328d4",
        "guestIds"=>
      [{"id"=>"4028fa81338751be0133876749fd0012",
        "guestId"=>"9715d70d-933a-0035-0e7f-9bb9370196ea",
        "updated"=>"2011-11-09T08:17:33.181+0000",
        "created"=>"2011-11-09T08:17:33.181+0000"}],
        "username"=>"admin",
        "canActivate"=>false,
        "id"=>"4028fa81338751be01338755dba10003",
        "type"=>
      {"label"=>"system",
       "id"=>"ff808081337cf90501337cf910ae0001",
       "manifest"=>false,
       "updated"=>"2011-11-07T07:40:57.390+0000",
       "created"=>"2011-11-07T07:40:57.390+0000"},
       "installedProducts"=>[],
       "updated"=>"2011-11-09T11:07:42.908+0000",
       "created"=>"2011-11-09T07:58:30.817+0000",
       "owner"=>
      {"href"=>"/owners/ACME_Corporation",
       "displayName"=>"ACME_Corporation",
       "id"=>"4028fa81338751be01338751f44b0001",
       "key"=>"ACME_Corporation"}}.with_indifferent_access
    end

  end
end
