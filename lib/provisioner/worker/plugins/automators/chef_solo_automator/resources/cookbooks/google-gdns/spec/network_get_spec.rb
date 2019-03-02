# Copyright 2018 Google Inc.
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

# ----------------------------------------------------------------------------
#
#     ***     AUTO GENERATED CODE    ***    AUTO GENERATED CODE     ***
#
# ----------------------------------------------------------------------------
#
#     This file is automatically generated by Magic Modules and manual
#     changes will be clobbered when the file is regenerated.
#
#     Please read more about how to change this file in README.md and
#     CONTRIBUTING.md located at the root of this package.
#
# ----------------------------------------------------------------------------

require 'spec_helper'
require 'uri'

class TestCred
  def authorize(request)
    request
  end
end

describe Google::Dns::Network::Get do
  let(:credential) { TestCred.new }
  let(:uri) { Google::Dns::NetworkBlocker::ALLOWED_TEST_URI }

  context 'successful request' do
    before(:each) do
      Google::Dns::NetworkBlocker.instance.allow_get(
        uri, 200, 'application/myfooapp', { field1: 'FOOBAR' }.to_json
      )
    end

    subject { described_class.new(uri, credential).send }

    it { is_expected.to be_a_kind_of(Net::HTTPResponse) }
    it { is_expected.to have_attributes(body: { field1: 'FOOBAR' }.to_json) }
    it { is_expected.to have_attributes(code: 200) }
    it { is_expected.to have_attributes(content_type: 'application/myfooapp') }
    it { is_expected.to have_attributes(uri: uri) }
  end

  context 'failed request' do
    before(:each) { Google::Dns::NetworkBlocker.instance.deny(uri) }

    subject { described_class.new(uri, credential).send }

    it { is_expected.to be_a_kind_of(Net::HTTPNotFound) }
    it { is_expected.to have_attributes(code: 404) }
  end
end
