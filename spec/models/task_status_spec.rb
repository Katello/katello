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

require 'spec_helper'

describe TaskStatus do
  let(:package_groups) { ["@mammals", "FTP Server"] }
  let(:packages) { %w[cheetah penguin] }
  let(:result) { {:errors => [] } }
  let(:task_type) { "package_install" }
  let(:state) { "running" }
  let(:parameters) { {} }

  subject do
    system = System.new(:name => "test.example.com")
    task_status = TaskStatus.new(:task_type => task_type,
                                             :parameters => parameters,
                                             :result => result,
                                             :state => state,
                                             :uuid => "1234",
                                             :task_owner => system)
  end

  its(:as_json) { should have_key(:description) }
  its(:as_json) { should have_key(:result_description) }
  its(:as_json) { should have_key(:system_name) }

  context "Package installation" do
    let(:task_type) { :package_install }
    let(:parameters) { { :packages => packages } }
    let(:state) { "finished" }

    its(:description) { should == "Package Install: cheetah, penguin" }

    context "No packages installed" do
      let(:result) { { :details => {:rpm => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }
      its(:result_description) { should == "No new packages installed" }
    end

    context "Packages installed" do
      let(:result) do
        { :details =>
          { :rpm =>
            { :succeeded => true,
              :details =>
                { "deps"=>
                     [{"qname"=>"elephant-8.8-1.noarch",
                       "repoid"=>"zoo-repo-updates",
                       "name"=>"elephant",
                       "version"=>"8.8",
                       "arch"=>"noarch",
                       "epoch"=>"0",
                       "release"=>"1"}],
                  "resolved"=>
                     [{"qname"=>"cheetah-1.26.3-5.noarch",
                       "repoid"=>"zoo-repo-updates",
                       "name"=>"cheetah",
                       "version"=>"1.26.3",
                       "arch"=>"noarch",
                       "epoch"=>"0",
                       "release"=>"5"}]
                }
            }
          }
        }.with_indifferent_access
      end
      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
cheetah-1.26.3-5.noarch
elephant-8.8-1.noarch
      EXPECTED_MESSAGE
    end
  end

  context "Package group installation" do
    let(:task_type) { :package_group_install }
    let(:parameters) { { :groups => package_groups } }
    let(:state) { "finished" }

    its(:description) { should == "Package Group Install: @mammals, @FTP Server" }

    context "No packages installed" do
      let(:result) { { :details => {:package_group => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }
      its(:result_description) { should == "No new packages installed" }
    end

    context "Packages installed" do
      let(:result) do
        { :details =>
          { :package_group =>
            { :succeeded => true,
              :details =>
              { "deps"=>
                    [{"qname"=>"elephant-8.8-1.noarch",
                      "repoid"=>"zoo-repo-updates",
                      "name"=>"elephant",
                      "version"=>"8.8",
                      "arch"=>"noarch",
                      "epoch"=>"0",
                      "release"=>"1"}],
                "resolved"=>
                    [{"qname"=>"cheetah-1.26.3-5.noarch",
                      "repoid"=>"zoo-repo-updates",
                      "name"=>"cheetah",
                      "version"=>"1.26.3",
                      "arch"=>"noarch",
                      "epoch"=>"0",
                      "release"=>"5"}]
              }
            }
          }
        }.with_indifferent_access
      end
      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
cheetah-1.26.3-5.noarch
elephant-8.8-1.noarch
      EXPECTED_MESSAGE
    end
  end

  context "Package uninstallation" do
    let(:task_type) { :package_remove }
    let(:parameters) { { :packages => ["elephant"] } }
    let(:state) { "finished" }

    its(:description) { should == "Package Remove: elephant" }

    context "No packages removed" do
      let(:result) { { :details => {:rpm => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }
      its(:result_description) { should == "No packages removed" }
    end

    context "Packages removed" do
      let(:result) do
        { :details =>
          { :rpm =>
            { :succeeded => true,
              :details =>
              { "deps"=>
                    [{"qname"=>"cheetah-1.26.3-5.noarch",
                      "repoid"=>"installed",
                      "name"=>"cheetah",
                      "version"=>"1.26.3",
                      "arch"=>"noarch",
                      "epoch"=>"0",
                      "release"=>"5"}],
                "resolved"=>
                    [{"qname"=>"elephant-8.8-1.noarch",
                      "repoid"=>"installed",
                      "name"=>"elephant",
                      "version"=>"8.8",
                      "arch"=>"noarch",
                      "epoch"=>"0",
                      "release"=>"1"}]
              }
            }
          }
        }.with_indifferent_access
      end

      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
elephant-8.8-1.noarch
cheetah-1.26.3-5.noarch
      EXPECTED_MESSAGE
    end
  end

  context "Package group uninstallation" do
    let(:task_type) { :package_group_remove }
    let(:parameters) { { :groups => package_groups } }
    let(:state) { "finished" }

    its(:description) { should == "Package Group Remove: @mammals, @FTP Server" }

    context "No packages removed" do
      let(:result) { { :details => {:package_group => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }
      its(:result_description) { should == "No packages removed" }
    end

    context "Packages removed" do
      let(:result) do
        { :details =>
          { :package_group =>
            { :succeeded => true,
              :details =>
              { "deps"=>
                   [{"qname"=>"elephant-8.8-1.noarch",
                     "repoid"=>"zoo-repo-updates",
                     "name"=>"elephant",
                     "version"=>"8.8",
                     "arch"=>"noarch",
                     "epoch"=>"0",
                     "release"=>"1"}],
                "resolved"=>
                   [{"qname"=>"cheetah-1.26.3-5.noarch",
                     "repoid"=>"zoo-repo-updates",
                     "name"=>"cheetah",
                     "version"=>"1.26.3",
                     "arch"=>"noarch",
                     "epoch"=>"0",
                     "release"=>"5"}]
              }
            }
          }
        }.with_indifferent_access
      end

      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
cheetah-1.26.3-5.noarch
elephant-8.8-1.noarch
      EXPECTED_MESSAGE
    end
  end

  context "Package update" do
    let(:task_type) { :package_update }
    let(:parameters) { { :packages => ["cheetah"] } }
    let(:state) { "finished" }

    its(:description) { should == "Package Update: cheetah" }

    context "No packages updated" do
      let(:result) { { :details => {:rpm => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }
      its(:result_description) { should == "No packages updated" }
    end

    context "Packages updated" do
      let(:result) do
        { :details =>
          { :rpm =>
            { :succeeded => true,
              :details =>
              { "deps"=>
                    [{"qname"=>"elephant-8.8-1.noarch",
                      "repoid"=>"zoo-repo-updates",
                      "name"=>"elephant",
                      "version"=>"8.8",
                      "arch"=>"noarch",
                      "epoch"=>"0",
                      "release"=>"1"}],
                "resolved"=>
                    [{"qname"=>"cheetah-1.26.3-5.noarch",
                      "repoid"=>"zoo-repo-updates",
                      "name"=>"cheetah",
                      "version"=>"1.26.3",
                      "arch"=>"noarch",
                      "epoch"=>"0",
                      "release"=>"5"}]
              }
            }
          }
        }.with_indifferent_access
      end

      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
cheetah-1.26.3-5.noarch
elephant-8.8-1.noarch
      EXPECTED_MESSAGE
    end
  end

  context "Yum error" do
    let(:result) do
      {:errors=>
       ["['Errors were encountered while downloading packages.', 'katello-all-0.1.149-1.fc16.noarch: failure: katello-all-0.1.149-1.fc16.noarch.rpm from katello: [Errno 256] No more mirrors to try.']",
        ["Traceback (most recent call last):\n",
         "  File \"/usr/lib/python2.7/site-packages/pulp/server/tasking/task.py\", line 404, in run\n    result = self.callable(*self.args, **self.kwargs)\n",
         "  File \"/usr/lib/python2.7/site-packages/pulp/server/api/consumer.py\", line 520, in __updatepackages\n    return packages.update(names)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 72, in __call__\n    return self.stub._send(request, opts)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 133, in _send\n    return self.__send(request, options)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 164, in __send\n    any=opts.any)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 144, in send\n    return self.__getreply(sn, reader)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 181, in __getreply\n    return self.__onreply(envelope)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 197, in __onreply\n    raise RemoteException.instance(reply)\n",
         "YumDownloadError: ['Errors were encountered while downloading packages.', 'katello-all-0.1.149-1.fc16.noarch: failure: katello-all-0.1.149-1.fc16.noarch.rpm from katello: [Errno 256] No more mirrors to try.']\n"]]}
    end
    let(:state) { "error" }

    its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
Errors were encountered while downloading packages
katello-all-0.1.149-1.fc16.noarch: failure: katello-all-0.1.149-1.fc16.noarch.rpm from katello: [Errno 256] No more mirrors to try
    EXPECTED_MESSAGE
  end

  context "Pulp error" do
    let(:result) do
      {:errors=>
       ["('8341bcac-b627-49ce-9383-f75c75f24202', 0)",
        ["Traceback (most recent call last):\n",
         "  File \"/usr/lib/python2.7/site-packages/pulp/server/tasking/task.py\", line 404, in run\n    result = self.callable(*self.args, **self.kwargs)\n",
         "  File \"/usr/lib/python2.7/site-packages/pulp/server/api/consumer.py\", line 456, in __installpackages\n    return packages.install(names, reboot)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 72, in __call__\n    return self.stub._send(request, opts)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 133, in _send\n    return self.__send(request, options)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 164, in __send\n    any=opts.any)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 143, in send\n    self.__getstarted(sn, reader)\n",
         "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 166, in __getstarted\n    raise RequestTimeout(sn, 0)\n",
         "RequestTimeout: ('8341bcac-b627-49ce-9383-f75c75f24202', 0)\n"]]}
    end
    let(:state) { "error" }

    its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
RequestTimeout
    EXPECTED_MESSAGE
  end

end
