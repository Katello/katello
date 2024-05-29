require 'katello_test_helper'

module Katello
  describe TaskStatus do
    let(:package_groups) { ["@mammals", "FTP Server"] }
    let(:packages) { %w(cheetah penguin) }
    let(:result) { {:errors => [] } }
    let(:task_type) { "package_install" }
    let(:state) { "running" }
    let(:parameters) { {} }

    subject do
      key = ActivationKey.new(:name => "test.example.com")
      TaskStatus.new(:task_type => task_type,
                     :parameters => parameters,
                     :result => result,
                     :state => state,
                     :uuid => "1234",
                     :task_owner => key)
    end

    describe "Package installation" do
      let(:task_type) { :package_install }
      let(:parameters) { { :packages => packages } }
      let(:state) { "finished" }

      it "has a valid description" do
        value(subject.description).must_equal("Package Install: cheetah, penguin")
      end

      describe "No packages installed" do
        let(:result) { { :details => {:rpm => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }

        it "has a result description of with no new packages installed" do
          value(subject.result_description).must_equal(["No new packages installed"])
        end
      end

      describe "Packages installed" do
        let(:result) do
          { :details =>
            { :rpm =>
              { :succeeded => true,
                :details =>
                  { "deps" => [{"qname" => "elephant-8.8-1.noarch",
                                "repoid" => "zoo-repo-updates",
                                "name" => "elephant",
                                "version" => "8.8",
                                "arch" => "noarch",
                                "epoch" => "0",
                                "release" => "1"}],
                    "resolved" => [{"qname" => "cheetah-1.26.3-5.noarch",
                                    "repoid" => "zoo-repo-updates",
                                    "name" => "cheetah",
                                    "version" => "1.26.3",
                                    "arch" => "noarch",
                                    "epoch" => "0",
                                    "release" => "5"}],
                  },
              },
            },
          }.with_indifferent_access
        end

        it "has a result description of with packages" do
          value(subject.result_description).must_equal(['cheetah-1.26.3-5.noarch', 'elephant-8.8-1.noarch'])
        end
      end
    end

    describe "Package group installation" do
      let(:task_type) { :package_group_install }
      let(:parameters) { { :groups => package_groups } }
      let(:state) { "finished" }

      it "has a valid description" do
        value(subject.description).must_equal("Package Group Install: @mammals, @FTP Server")
      end

      describe "No packages installed" do
        let(:result) { { :details => {:package_group => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }

        it "has a result description of with no new packages installed" do
          value(subject.result_description).must_equal(["No new packages installed"])
        end
      end

      describe "Packages installed" do
        let(:result) do
          { :details =>
            { :package_group =>
              { :succeeded => true,
                :details =>
                { "deps" => [{"qname" => "elephant-8.8-1.noarch",
                              "repoid" => "zoo-repo-updates",
                              "name" => "elephant",
                              "version" => "8.8",
                              "arch" => "noarch",
                              "epoch" => "0",
                              "release" => "1"}],
                  "resolved" => [{"qname" => "cheetah-1.26.3-5.noarch",
                                  "repoid" => "zoo-repo-updates",
                                  "name" => "cheetah",
                                  "version" => "1.26.3",
                                  "arch" => "noarch",
                                  "epoch" => "0",
                                  "release" => "5"}],
                },
              },
            },
          }.with_indifferent_access
        end

        it "has a result description of with packages" do
          value(subject.result_description).must_equal(['cheetah-1.26.3-5.noarch', 'elephant-8.8-1.noarch'])
        end
      end
    end

    describe "Package uninstallation" do
      let(:task_type) { :package_remove }
      let(:parameters) { { :packages => ["elephant"] } }
      let(:state) { "finished" }

      it "has a valid description" do
        value(subject.description).must_equal("Package Remove: elephant")
      end

      describe "No packages removed" do
        let(:result) { { :details => {:rpm => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }

        it "has a result description of with no packates removed" do
          value(subject.result_description).must_equal(["No packages removed"])
        end
      end

      describe "Packages removed" do
        let(:result) do
          { :details =>
            { :rpm =>
              { :succeeded => true,
                :details =>
                { "deps" => [{"qname" => "cheetah-1.26.3-5.noarch",
                              "repoid" => "installed",
                              "name" => "cheetah",
                              "version" => "1.26.3",
                              "arch" => "noarch",
                              "epoch" => "0",
                              "release" => "5"}],
                  "resolved" => [{"qname" => "elephant-8.8-1.noarch",
                                  "repoid" => "installed",
                                  "name" => "elephant",
                                  "version" => "8.8",
                                  "arch" => "noarch",
                                  "epoch" => "0",
                                  "release" => "1"}],
                },
              },
            },
          }.with_indifferent_access
        end

        it "has a result description of with packages" do
          value(subject.result_description).must_equal(['cheetah-1.26.3-5.noarch', 'elephant-8.8-1.noarch'])
        end
      end
    end

    describe "Package group uninstallation" do
      let(:task_type) { :package_group_remove }
      let(:parameters) { { :groups => package_groups } }
      let(:state) { "finished" }

      it "has a valid description" do
        value(subject.description).must_equal("Package Group Remove: @mammals, @FTP Server")
      end

      describe "No packages removed" do
        let(:result) { { :details => {:package_group => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }

        it "has a result description of with no packates removed" do
          value(subject.result_description).must_equal(["No packages removed"])
        end
      end

      describe "Packages removed" do
        let(:result) do
          { :details =>
            { :package_group =>
              { :succeeded => true,
                :details =>
                { "deps" => [{"qname" => "elephant-8.8-1.noarch",
                              "repoid" => "zoo-repo-updates",
                              "name" => "elephant",
                              "version" => "8.8",
                              "arch" => "noarch",
                              "epoch" => "0",
                              "release" => "1"}],
                  "resolved" => [{"qname" => "cheetah-1.26.3-5.noarch",
                                  "repoid" => "zoo-repo-updates",
                                  "name" => "cheetah",
                                  "version" => "1.26.3",
                                  "arch" => "noarch",
                                  "epoch" => "0",
                                  "release" => "5"}],
                },
              },
            },
          }.with_indifferent_access
        end

        it "has a result description with packages" do
          value(subject.result_description).must_equal(['cheetah-1.26.3-5.noarch', 'elephant-8.8-1.noarch'])
        end
      end
    end

    describe "Package update" do
      let(:task_type) { :package_update }
      let(:parameters) { { :packages => ["cheetah"] } }
      let(:state) { "finished" }

      it "has a valid description" do
        value(subject.description).must_equal("Package Update: cheetah")
      end

      describe "No packages updated" do
        let(:result) { { :details => {:rpm => { :succeeded => true, :details => { :deps => [], :resolved => []} } } } }

        it "has a result description of with no packates updated" do
          value(subject.result_description).must_equal(["No packages updated"])
        end
      end

      describe "Packages updated" do
        let(:result) do
          { :details =>
            { :rpm =>
              { :succeeded => true,
                :details =>
                { "deps" => [{"qname" => "elephant-8.8-1.noarch",
                              "repoid" => "zoo-repo-updates",
                              "name" => "elephant",
                              "version" => "8.8",
                              "arch" => "noarch",
                              "epoch" => "0",
                              "release" => "1"}],
                  "resolved" => [{"qname" => "cheetah-1.26.3-5.noarch",
                                  "repoid" => "zoo-repo-updates",
                                  "name" => "cheetah",
                                  "version" => "1.26.3",
                                  "arch" => "noarch",
                                  "epoch" => "0",
                                  "release" => "5"}],
                },
              },
            },
          }.with_indifferent_access
        end

        it "has a result description with packages" do
          value(subject.result_description).must_equal(['cheetah-1.26.3-5.noarch', 'elephant-8.8-1.noarch'])
        end
      end
    end

    describe "Yum error" do
      let(:result) do
        {:errors => ["['Errors were encountered while downloading packages.', 'katello-all-0.1.149-1.fc16.noarch: failure: " \
                               "katello-all-0.1.149-1.fc16.noarch.rpm from katello: [Errno 256] No more mirrors to try.']",
                     ["Traceback (most recent call last):\n",
                      "  File \"/usr/lib/python2.7/site-packages/pulp/server/tasking/task.py\", line 404, in run\n    result = self.callable(*self.args, **self.kwargs)\n",
                      "  File \"/usr/lib/python2.7/site-packages/pulp/server/api/consumer.py\", line 520, in __updatepackages\n    return packages.update(names)\n",
                      "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 72, in __call__\n    return self.stub._send(request, opts)\n",
                      "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 133, in _send\n    return self.__send(request, options)\n",
                      "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/stub.py\", line 164, in __send\n    any=opts.any)\n",
                      "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 144, in send\n    return self.__getreply(sn, reader)\n",
                      "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 181, in __getreply\n    return self.__onreply(envelope)\n",
                      "  File \"/usr/lib/python2.7/site-packages/gofer/rmi/policy.py\", line 197, in __onreply\n    raise RemoteException.instance(reply)\n",
                      "YumDownloadError: ['Errors were encountered while downloading packages.', 'katello-all-0.1.149-1.fc16.noarch: failure: " \
                      "katello-all-0.1.149-1.fc16.noarch.rpm from katello: [Errno 256] No more mirrors to try.']\n"]]}
      end
      let(:state) { "error" }

      it "has a valid result_description" do
        message = "Errors were encountered while downloading packages\n"
        message += "katello-all-0.1.149-1.fc16.noarch: failure: "
        message += "katello-all-0.1.149-1.fc16.noarch.rpm from katello: "
        message += "[Errno 256] No more mirrors to try"
        value(subject.result_description).must_equal(message)
      end
    end

    describe "Pulp error" do
      let(:result) do
        {:errors => ["('8341bcac-b627-49ce-9383-f75c75f24202', 0)",
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

      it "has a result description" do
        value(subject.result_description).must_equal('RequestTimeout')
      end
    end
  end
end
