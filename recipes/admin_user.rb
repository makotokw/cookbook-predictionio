#
# Cookbook Name:: predictionio
# Recipe:: admin_user
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

# add user to PredictionIO
# TODO: bin/users will stop, should be waiting for completion starting PredictionIO?
# Please execute bash ~/.pio/pio-adduser.sh

pio = {}
pio[:user] = node[:predictionio][:user]
pio[:setup_dir] = "/home/#{pio[:user]}/.pio"

bash 'add user to PredictionIO' do
  code <<-EOH
    bash #{pio[:setup_dir]}/pio-adduser.sh > #{pio[:setup_dir]}/pio-adduser.log
    touch #{pio[:setup_dir]}/adduser.done
  EOH
  not_if { ::File.exists?("#{pio[:setup_dir]}/adduser.done") }
end
