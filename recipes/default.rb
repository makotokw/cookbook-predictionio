#
# Cookbook Name:: predictionio
# Recipe:: default
#
# Copyright 2014  Makoto Kawasaki
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

pio = {}
pio[:root_path] = node[:predictionio][:root_path]
pio[:version] = node[:predictionio][:version]
pio[:hadoop_version] = node[:predictionio][:hadoop_version]
pio[:user] = node[:predictionio][:user]
pio[:vendors_dir] = "#{pio[:root_path]}/vendors"
pio[:hadoop_dir] = "#{pio[:vendors_dir]}/hadoop-#{pio[:hadoop_version]}"
pio[:setup_dir] = "/home/#{pio[:user]}/.pio"

directory pio[:setup_dir] do
  owner pio[:user]
  group pio[:user]
  mode 00755
end

# stop previous PredictionIO
bash 'stop previous PredictionIO' do
  code <<-EOH
    su -c "yes | #{pio[:root_path]}/bin/stop-all.sh" #{pio[:user]}
  EOH
  only_if do
    (::File.exist?("#{pio[:root_path]}/admin.pid") ||
    ::File.exist?("#{pio[:root_path]}/api.pid") ||
    ::File.exist?("#{pio[:root_path]}/scheduler.pid")) &&
    ::File.exist?("#{pio[:root_path]}/bin/stop-all.sh")
  end
end

# download PredictionIO
remote_file "#{pio[:setup_dir]}/PredictionIO-#{pio[:version]}.zip" do
  source "http://download.prediction.io/PredictionIO-#{pio[:version]}.zip"
  action :create_if_missing
  not_if { ::Dir.exist?(pio[:root_path]) }
end
bash 'extract_pio' do
  cwd pio[:setup_dir]
  code <<-EOH
    unzip #{pio[:setup_dir]}/PredictionIO-#{pio[:version]}.zip
    mv #{pio[:setup_dir]}/PredictionIO-#{pio[:version]} #{pio[:root_path]}
    chown -R #{pio[:user]}:#{pio[:user]} #{pio[:root_path]}
    EOH
  not_if { ::Dir.exist?(pio[:root_path]) }
end

# create root_path/vendors
directory pio[:vendors_dir] do
  owner pio[:user]
  group pio[:user]
  mode 00777
end

# download hadoop
remote_file "#{pio[:vendors_dir]}/hadoop-#{pio[:hadoop_version]}.tar.gz" do
  source "http://archive.apache.org/dist/hadoop/core/hadoop-#{pio[:hadoop_version]}/hadoop-#{pio[:hadoop_version]}.tar.gz"
  action :create_if_missing
  not_if { ::Dir.exist?(pio[:hadoop_dir]) }
end
# copy additional setup files
%w(hdfs-site.xml pio-adduser.sh).each do |file|
  template "#{pio[:setup_dir]}/#{file}" do
    source "#{file}.erb"
  end
end
bash 'extract_hadoop' do
  cwd pio[:vendors_dir]
  code <<-EOH
    tar xzf hadoop-#{pio[:hadoop_version]}.tar.gz
    rm #{pio[:vendors_dir]}/hadoop-#{pio[:hadoop_version]}.tar.gz
    cp #{pio[:root_path]}/conf/hadoop/* #{pio[:hadoop_dir]}/conf
    cp #{pio[:setup_dir]}/hdfs-site.xml #{pio[:hadoop_dir]}/conf
    echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre' >> #{pio[:hadoop_dir]}/conf/hadoop-env.sh
    echo 'io.prediction.commons.settings.hadoop.home=#{pio[:hadoop_dir]}' >> #{pio[:root_path]}/conf/predictionio.conf
    mkdir -p#{pio[:vendors_dir]}/hadoop/nn
    mkdir -p #{pio[:vendors_dir]}/hadoop/dn
    chown -R #{pio[:user]}:#{pio[:user]} #{pio[:vendors_dir]}
  EOH
  not_if { ::Dir.exist?(pio[:hadoop_dir]) }
end

# setup-vendors
bash 'setup-vendors' do
  cwd pio[:root_path]
  code <<-EOH
    yes n | bin/setup-vendors.sh
    chown -R #{pio[:user]}:#{pio[:user]} #{pio[:vendors_dir]}
    touch #{pio[:setup_dir]}/setup-vendors.done
  EOH
  not_if { ::File.exist?("#{pio[:setup_dir]}/setup-vendors.done") }
end

bash 'hadoop namenode' do
  code <<-EOH
      sudo -u #{pio[:user]} #{pio[:hadoop_dir]}/bin/hadoop namenode -format -force
      touch #{pio[:setup_dir]}/namenode.done
  EOH
  not_if { ::File.exist?("#{pio[:setup_dir]}/namenode.done") }
end

bash 'wait for MongoDB ready' do
  code <<-EOH
    #{pio[:root_path]}/bin/conncheck
    touch #{pio[:setup_dir]}/mongodb.done
  EOH
  not_if { ::File.exist?("#{pio[:setup_dir]}/mongodb.done") }
end

# setup PredictionIO
bash 'setup PredictionIO' do
  code <<-EOH
    sudo -u #{pio[:user]} #{pio[:root_path]}/bin/setup.sh > #{pio[:setup_dir]}/setup.log
    touch #{pio[:setup_dir]}/setup.done
  EOH
  not_if { ::File.exist?("#{pio[:setup_dir]}/setup.done") }
end

# force remove previous pid files
%w{admin.pid api.pid scheduler.pid}.each do |pid_file|
  file "#{pio[:root_path]}/#{pid_file}" do
    action :delete
    only_if { ::File.exist?("#{pio[:root_path]}/#{pid_file}") }
  end
end

# start PredictionIO
bash 'start PredictionIO' do
  code <<-EOH
    su -c "yes | #{pio[:root_path]}/bin/start-all.sh" #{pio[:user]} > #{pio[:setup_dir]}/setup.log
  EOH
end

bash 'chown PredictionIO setup files' do
  code <<-EOH
    chown -R #{pio[:user]}:#{pio[:user]} #{pio[:setup_dir]}
  EOH
end
