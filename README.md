predictionio Cookbook
=====================
Installs standalone [PredictionIO](http://prediction.io/) for **development in Vagrant**.

TODO
------------

* Support redhat platform_family
* Fix ``admin_user`` recipe
* For production servers

Requirements
------------
This cookbook requires Chef 11.0.0 or later.

#### Platform

 * Ubuntu 12.04

Attributes
----------

#### predictionio::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['predictionio']['root_path']</tt></td>
    <td>String</td>
    <td>Path to install PredictionIO</td>
    <td><tt>'/opt/PredictionIO'</tt></td>
  </tr>
  <tr>
    <td><tt>['predictionio']['version']</tt></td>
    <td>String</td>
    <td>Version of PredictionIO to install</td>
    <td><tt>'0.7.1'</tt></td>
  </tr>
  <tr>
    <td><tt>['predictionio']['hadoop_version']</tt></td>
    <td>String</td>
    <td>Version of Hadoop</td>
    <td><tt>'1.2.1</tt></td>
  </tr>
  <tr>
    <td><tt>['predictionio']['user']</tt></td>
    <td>String</td>
    <td>Version of Hadoop</td>
    <td><tt>'vagrant'</tt></td>
  </tr>
</table>

Usage
-----
#### predictionio::default

Just include `predictionio` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[java]",
    "recipe[mongodb::10gen_repo]",
    "recipe[mongodb]",
    "recipe[predictionio]"
  ],
  "java": {
    "install_flavor": "openjdk",
    "jdk_version": "7"
  },
  "predictionio": {
      "user": "vagrant",
      "version": "0.7.1",
      "hadoop_version": "1.2.1"
  }
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------

 * Author:: Makoto Kawasaki <makoto.kw@gmail.com>

```text
Copyright:: 2014, Makoto Kawasaki

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
