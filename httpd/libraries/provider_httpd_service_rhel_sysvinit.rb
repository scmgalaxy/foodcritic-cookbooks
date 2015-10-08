require_relative 'provider_httpd_service_rhel'

class Chef
  class Provider
    class HttpdServiceRhelSysvinit < Chef::Provider::HttpdServiceRhel
      # This is Chef-12.0.0 back-compat, it is different from current core chef 12.4.0 declarations
      provides :httpd_service, platform_family: %w(rhel fedora suse)

      def self.provides?(node, resource)
        super && Chef::Platform::ServiceHelpers.service_resource_providers.include?(:redhat)
      end

      action :start do
        template "#{new_resource.name} :create /etc/init.d/#{apache_name}" do
          path "/etc/init.d/#{apache_name}"
          source "#{parsed_version}/sysvinit/el-#{elversion}/httpd.erb"
          owner 'root'
          group 'root'
          mode '0755'
          variables(apache_name: apache_name)
          cookbook 'httpd'
          action :create
        end

        template "#{new_resource.name} :create /etc/sysconfig/#{apache_name}" do
          path "/etc/sysconfig/#{apache_name}"
          source "rhel/sysconfig/httpd-#{parsed_version}.erb"
          owner 'root'
          group 'root'
          mode '0644'
          variables(
            apache_name: apache_name,
            mpm: parsed_mpm,
            pid_file: pid_file
          )
          cookbook 'httpd'
          notifies :restart, "service[#{new_resource.name} :create #{apache_name}]"
          action :create
        end

        service "#{new_resource.name} :create #{apache_name}" do
          service_name apache_name
          supports status: true
          provider Chef::Provider::Service::Init::Redhat
          action [:start, :enable]
        end
      end

      action :stop do
        service "#{new_resource.name} delete #{apache_name}" do
          service_name apache_name
          supports status: true
          provider Chef::Provider::Service::Init::Redhat
          action :stop
        end
      end

      action :restart do
        service "#{new_resource.name} delete #{apache_name}" do
          service_name apache_name
          supports restart: true
          provider Chef::Provider::Service::Init::Redhat
          action :restart
        end
      end

      action :reload do
        service "#{new_resource.name} delete #{apache_name}" do
          service_name apache_name
          supports reload: true
          provider Chef::Provider::Service::Init::Redhat
          action :reload
        end
      end

      def create_stop_system_service
        service "#{new_resource.name} :create httpd" do
          service_name 'httpd'
          supports status: true
          provider Chef::Provider::Service::Init::Redhat
          action [:stop, :disable]
        end
      end

      def delete_stop_service
        service "#{new_resource.name} :delete #{apache_name}" do
          service_name apache_name
          supports status: true
          provider Chef::Provider::Service::Init::Redhat
          action [:stop, :disable]
        end
      end
    end
  end
end
