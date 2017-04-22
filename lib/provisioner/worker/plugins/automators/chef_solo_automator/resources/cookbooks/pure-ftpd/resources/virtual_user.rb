actions :create_or_update, :delete
default_action :create_or_update

attribute :username, kind_of: String, required: true
attribute :password, kind_of: String, required: true
attribute :uid, kind_of: [Integer, NilClass], default: nil
attribute :gid, kind_of: [Integer, NilClass], default: nil

attribute :max_concurrency, kind_of: Integer, default: 5

def home_directory
  "#{node['pure_ftpd']['home']}/#{username}"
end
