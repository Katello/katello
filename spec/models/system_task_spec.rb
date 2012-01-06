
require 'spec_helper'

describe SystemTask do
  let(:package_groups) { ["@Editors", "FTP Server"] }
  let(:packages) { %w[zsh bash] }
  let(:result) { {:errors => [] } }
  let(:task_type) { "package_install" }
  let(:state) { "running" }
  let(:parameters) { {} }

  subject do
    system_task = SystemTask.new
    system_task.system = System.new(:name => "test.example.com")
    system_task.task_status = TaskStatus.new(:task_type => task_type,
                                             :parameters => parameters,
                                             :result => result,
                                             :state => state,
                                             :uuid => "1234")
    system_task
  end

  its(:as_json) { should have_key(:description) }
  its(:as_json) { should have_key(:result_description) }
  its(:as_json) { should have_key(:system_name) }

  context "Package installation" do
    let(:task_type) { :package_install }
    let(:parameters) { { :packages => packages } }
    let(:state) { "finished" }

    its(:description) { should == "Package Install: zsh, bash" }

    context "No packages installed" do
      let(:result) { { :installed => [], :reboot_scheduled => false } }
      its(:result_description) { should == "No new packages installed" }
    end

    context "Packages installed" do
      let(:result) { { :installed => ["zsh","bash"], :reboot_scheduled => false } }
      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
zsh installed
bash installed
      EXPECTED_MESSAGE
    end
  end

  context "Package group installation" do
    let(:task_type) { :package_group_install }
    let(:parameters) { { :groups => package_groups } }
    let(:state) { "finished" }

    its(:description) { should == "Package Group Install: @@Editors, @FTP Server" }

    context "No packages installed" do
      let(:result) { {} }
      its(:result_description) { should == "No new packages installed" }
    end

    context "Packages installed" do
      let(:result) { {"FTP Server"=>["vsftpd-2.3.4-2.fc15.x86_64"]} }
      its(:result_description) { should == <<-EXPECTED_MESSAGE }
@FTP Server
vsftpd-2.3.4-2.fc15.x86_64 installed
      EXPECTED_MESSAGE
    end
  end

  context "Package uninstallation" do
    let(:task_type) { :package_remove }
    let(:parameters) { { :packages => packages } }
    let(:state) { "finished" }

    its(:description) { should == "Package Remove: zsh, bash" }

    context "No packages removed" do
      let(:result) { [] }
      its(:result_description) { should == "No packages removed" }
    end

    context "Packages removed" do
      let(:result) { ["zsh","bash"] }
      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
zsh removed
bash removed
      EXPECTED_MESSAGE
    end
  end

  context "Package group uninstallation" do
    let(:task_type) { :package_group_remove }
    let(:parameters) { { :groups => package_groups } }
    let(:state) { "finished" }

    its(:description) { should == "Package Group Remove: @@Editors, @FTP Server" }

    context "No packages removed" do
      let(:result) { {} }
      its(:result_description) { should == "No packages removed" }
    end

    context "Packages installed" do
      let(:result) { {"FTP Server"=>["vsftpd-2.3.4-2.fc15.x86_64"]} }
      its(:result_description) { should == <<-EXPECTED_MESSAGE }
@FTP Server
vsftpd-2.3.4-2.fc15.x86_64 removed
      EXPECTED_MESSAGE
    end
  end

  context "Package update" do
    let(:task_type) { :package_update }
    let(:parameters) { { :packages => packages } }
    let(:state) { "finished" }

    its(:description) { should == "Package Update: zsh, bash" }

    context "No packages updated" do
      let(:result) { {"updated" => []}.with_indifferent_access }
      its(:result_description) { should == "No packages updated" }
    end

    context "Packages updated" do
      let(:result) do
        {"reboot_scheduled"=>false,
         "updated"=>
        [["bash-4.2.20-1.fc16.x86_64",
          {"updates"=>["bash-4.2.10-5.fc16.x86_64"], "obsoletes"=>[]}]]}.with_indifferent_access
      end
      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
bash-4.2.20-1.fc16.x86_64 updated bash-4.2.10-5.fc16.x86_64
      EXPECTED_MESSAGE
    end

    context "Packages obsoleted" do
      let(:result) do
        {"reboot_scheduled"=>false,
         "updated"=>
        [["zsh-4.2.20-1.fc16.x86_64",
          {"updates"=>[], "obsoletes" => ["bash-4.2.10-5.fc16.x86_64"]}]]}.with_indifferent_access
      end
      its(:result_description) { should == <<-EXPECTED_MESSAGE.chomp }
zsh-4.2.20-1.fc16.x86_64 obsoleted bash-4.2.10-5.fc16.x86_64
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
