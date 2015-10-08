require 'chef/provider/lwrp_base'
require_relative 'helpers'
require_relative 'helpers_rhel'

class Chef
  class Provider
    class HttpdConfigRhel < Chef::Provider::LWRPBase
      include HttpdCookbook::Helpers
      include HttpdCookbook::Helpers::Rhel

      provides :httpd_config, platform_family: %w(rhel fedora suse)

      use_inline_resources

      def whyrun_supported?
        true
      end

      action :create do
        directory "#{new_resource.name} :create /etc/#{apache_name}/conf.d" do
          path "/etc/#{apache_name}/conf.d"
          owner 'root'
          group 'root'
          mode '0755'
          recursive true
          action :create
        end

        template "#{new_resource.name} :create /etc/#{apache_name}/conf.d/#{new_resource.config_name}.conf" do
          path "/etc/#{apache_name}/conf.d/#{new_resource.config_name}.conf"
          owner 'root'
          group 'root'
          mode '0644'
          variables(new_resource.variables)
          source new_resource.source
          cookbook new_resource.cookbook
          action :create
        end
      end

      action :delete do
        file "#{new_resource.name} :create /etc/#{apache_name}/conf.d/#{new_resource.config_name}" do
          path "/etc/#{apache_name}/conf.d/#{new_resource.config_name}.conf"
          action :delete
        end
      end
    end
  end
end
