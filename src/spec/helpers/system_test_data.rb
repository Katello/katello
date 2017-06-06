#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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

    def new_hypervisor
      {"href"=>"/consumers/host2",
       "facts"=>{"uname.machine"=>"x86_64"},
       "name"=>"host2",
       "entitlementCount"=>0,
       "idCert"=>
      {"serial"=>
       {"serial"=>7270161947420840345,
        "revoked"=>false,
        "expiration"=>"2012-12-22T10:19:23.355+0000",
        "id"=>7270161947420840345,
        "updated"=>"2011-12-22T10:19:23.355+0000",
        "collected"=>false,
        "created"=>"2011-12-22T10:19:23.355+0000"},
        "cert"=>
       "-----BEGIN
CERTIFICATE-----\nMIIDQjCCAqugAwIBAgIIZOTNxa+U0ZkwDQYJKoZIhvcNAQEFBQAwRDEjMCEGA1UE\nAwwaZGhjcC0yNy0xOTAuYnJxLnJlZGhhdC5jb20xCzAJBgNVBAYTAlVTMRAwDgYD\nVQQHDAdSYWxlaWdoMB4XDTExMTIyMjEwMTkyM1oXDTEyMTIyMjEwMTkyM1owEDEO\nMAwGA1UEAxMFaG9zdDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDO\n7augO01I5JArSzcy4w3F1AESdbc9glSIHsj3XunQNoP7Ld5herG73fcrbVSNL7TT\nwUEapI9bajFCYpFGF0t4jT24IFC1gloYfOeEhO18qKQ2orsx6L8nOhY312zNKY3T\ny4GqALXbNzWN8fIRGdbbbQGNpNwmkKUEwNL20OOCzkucl2gmCzFX6j4IRx5w0Nna\n3cy+qCYGjcjCeIZXmtEzpNZyAfzDhNTFHE4nzGfCtjufGn07lALthhbmA79SZQfy\nkNrsb5kkn62S2tjAOBrjbRcC/1kxydo4ATYAMm/nsY+fUxNgSiN4WP6gGtIXJMdr\nSR2DM6q/caIUd1ZBSZ1ZAgMBAAGjgewwgekwEQYJYIZIAYb4QgEBBAQDAgWgMAsG\nA1UdDwQEAwIEsDB0BgNVHSMEbTBrgBRgoRMN39a1IuDLfV6FjiMgBmhzIqFIpEYw\nRDEjMCEGA1UEAwwaZGhjcC0yNy0xOTAuYnJxLnJlZGhhdC5jb20xCzAJBgNVBAYT\nAlVTMRAwDgYDVQQHDAdSYWxlaWdoggkAgfw/FWClJowwHQYDVR0OBBYEFBIF8mVI\n/4uaO6bvQxexAZej5rNsMBMGA1UdJQQMMAoGCCsGAQUFBwMCMB0GA1UdEQQWMBSk\nEjAQMQ4wDAYDVQQDDAVob3N0MjANBgkqhkiG9w0BAQUFAAOBgQCCOVWrmLPLcu3A\nM/f/M1xhgt7QBn38ClV/T7L78V1yCeGOEbdrhdSkWRu27LzswTKJp+YnNpg0Xw72\neQk6DTW7MElFNEhM9pYW7xBDo2in0f0L2DnXyBAvzZ01cMzV2W85TIQzAT34QkeZ\nX1u+6UUVRPL7zv+jX+vx06OYYvnNwA==\n-----END
CERTIFICATE-----\n",
"id"=>"4028fa81346539d6013465484c9d000a",
"updated"=>"2011-12-22T10:19:24.189+0000",
"key"=>
"-----BEGIN RSA PRIVATE
KEY-----\nMIIEpAIBAAKCAQEAzu2roDtNSOSQK0s3MuMNxdQBEnW3PYJUiB7I917p0DaD+y3e\nYXqxu933K21UjS+008FBGqSPW2oxQmKRRhdLeI09uCBQtYJaGHznhITtfKikNqK7\nMei/JzoWN9dszSmN08uBqgC12zc1jfHyERnW220BjaTcJpClBMDS9tDjgs5LnJdo\nJgsxV+o+CEcecNDZ2t3MvqgmBo3IwniGV5rRM6TWcgH8w4TUxRxOJ8xnwrY7nxp9\nO5QC7YYW5gO/UmUH8pDa7G+ZJJ+tktrYwDga420XAv9ZMcnaOAE2ADJv57GPn1MT\nYEojeFj+oBrSFyTHa0kdgzOqv3GiFHdWQUmdWQIDAQABAoIBAQCwgn3WpR8soYL0\n2ykPqCxUZp4vf+g5eJXgstncYMLzT71PIfZCkmVPimxPR+hKsrn9syh0sJB0euXf\n6bJf5nkDMP/HsxEFc1ak8s6N9NGbd0L0M+WYEiAUNvFC2ui9LMgFNN+7AvYdMz/k\nf9Brk+35qEcd6tW7s8B/iHer/81CAmxFd6UfN45GSceogGDmteYrb05oXuy27zuz\ndjWSdi06kfcfSbzxUMOuRjmUmsEwCp9F2pZiCwoEXm6rmgRZ38QnBbQDEJxIdFta\nkhKsogktM5EguyRrS+c7Tzi5JAWEaJNK2FZbkEJ36adzCIo6mQBGTDUDJDPynOjU\nuEVFKs7NAoGBAOchsQnmEa8FL7tSZyIL8u2ru7wiCR1kCcM6L56vVsIeO2eDdyz0\nmAbUStl6XOO76DnGAdlotvexac8IgQVdrAAOp1zXaqsZQ8iyP5aWf1ikZkAVTi7d\nGjonzz8hzOgoR0lyve8ulX7g0cofPI5MbTy7Vp683B4O+YGz1Dpbojq/AoGBAOUx\nUtwT307s1TxpUSiMPI9p9RUiE3WBVE5sZsajFB53hOkwvycdErnli1LSs27kzcgJ\nN4D1R6247sCmfIo2R8Yhso3DTWMypspV8jEhDLs77qeKNp74PbKO7nW3ImOlipQL\nVDbbAsx6M4w0Q8UMW0ElXndJMjyNJjfOpF931yXnAoGAco/8lI95DGthsVOy0ulh\nS/TnZOTp56uCO0ZH/DukoSsi/rfnBl1mTVxEjW9dQ3QMMza2C/EfX76MV5Y7fVFk\nw9J/mkEcGhq3wm63ngiSrnkuRW1KB2iIa3L4Aq7aRehRDVLWWguZBf6hfbHl7hJr\nwsKIuL2bzTpW6bcc5qAs1TkCgYBrbc44CDyQ4yQkV/1Js0ojsvfE+x8B4ighRmB6\nVTB2A3HSWB4ReGgxqK3AmbCvlyH51JAmq1H41QlcVe1kX4MPFPZ7yoK4r6JMjzKh\n4qr0DGiWMYvewd8xlhuiI8BD0vF86T6FI+1Q6SrGWi017M/NXnXEFhQtG8BBQmP7\nt9GqGwKBgQDLT6I4/WTbr1OUddDe5R7KAQDJWO0k1vjw0Cvin+3Lkb4fL6cURNeH\nbAnetvtR4Fs1lc8J4P28smpbe9p432Zcp+Zc+xE816uQ9LtmjJf3Ur/MuWsVaKcb\npmWP//rcLb/vKbawnjTbTDnQVsmtrGT56VYq8rmoxq4hdihNOQLn8w==\n-----END
RSA PRIVATE KEY-----\n",
"created"=>"2011-12-22T10:19:24.189+0000"},
"lastCheckin"=>nil,
"autoheal"=>true,
"uuid"=>"host2",
"guestIds"=>
[{"id"=>"4028fa81346539d6013465484d07000c",
  "guestId"=>"GUEST3",
  "updated"=>"2011-12-22T10:19:24.295+0000",
  "created"=>"2011-12-22T10:19:24.295+0000"},
  {"id"=>"4028fa81346539d6013465484d27000f",
   "guestId"=>"GUEST4",
   "updated"=>"2011-12-22T10:19:24.327+0000",
   "created"=>"2011-12-22T10:19:24.327+0000"}],
   "username"=>nil,
   "canActivate"=>false,
   "id"=>"4028fa81346539d60134654849590008",
   "type"=>
{"label"=>"hypervisor",
 "id"=>"4028fa8134470443013447044dff0005",
 "manifest"=>false,
 "updated"=>"2011-12-16T13:16:31.615+0000",
 "created"=>"2011-12-16T13:16:31.615+0000"},
 "installedProducts"=>nil,
 "updated"=>"2011-12-22T10:19:24.328+0000",
 "created"=>"2011-12-22T10:19:23.353+0000",
 "owner"=>
{"href"=>"/owners/ACME_Corporation",
 "displayName"=>"ACME_Corporation",
 "id"=>"4028fa81346539d601346539f4470001",
 "key"=>"ACME_Corporation"}}.with_indifferent_access
    end

  end
end
