require_relative 'spec_helper'
require 'logger'

include Coopr::Logging

describe Coopr::Worker::PluginManager do
  # These run before each test
  before :each do
    @pluginmanager = Coopr::Worker::PluginManager.new
  end

# TODO: fix this
# rubocop:disable CommentIndentation
#  describe '#new' do
#    it 'creates an instance of PluginManager' do
#      expect(pluginmanager).to be_an_instance_of PluginManager
#    end
#  end
# rubocop:enable CommentIndentation
end
