# Cloud Foundry WebLogic Buildpack
# Copyright 2013-2017 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/container/wls/jvm_arg_helper'
require 'pathname'
require 'yaml'

module JavaBuildpack
  module Container
    module Wls

      # Release the Weblogic instance
      class WlsReleaser
        include JavaBuildpack::Container::Wls::WlsConstants

        def initialize(application, app_config_cache_root, droplet, domain_home, server_name, start_in_wlx_mode)
          @droplet           = droplet
          @application       = application
          @domain_home       = domain_home
          @server_name       = server_name
          @start_in_wlx_mode = start_in_wlx_mode
          @app_config_cache_root = app_config_cache_root

          create_scripts
        end

        # Create a pre-start script that will handle following
        # 1. Recreate the staging env folder structure as wls install scripts will fail otherwise
        # 2. Add app based jvm args (like application name, instance index, space name, warden container ip and names)
        # 3. Allow scale up/down based on variance between actual and staging memory settings
        # 4. Modify script to use updated jvm args (including resized heaps)
        # 5. Modify the server name reference to include the app instance index to differentiate between instances of
        #    the same app

        # Create a post-shutdown script that will handle following
        # 1. Report shutting down of the server instance
        # 2. Sleep for a predetermined period so users can download files if needed

        def create_scripts
          system "/bin/cp #{START_STOP_HOOKS_SRC_PATH}/* #{@application.root}/"

          @pre_start_script = Dir.glob("#{@application.root}/#{PRE_START_SCRIPT}")[0]
          @post_stop_script = Dir.glob("#{@application.root}/#{POST_STOP_SCRIPT}")[0]

          # Change this to add any number of custom scripts/resources to app root
          if CUSTOM_RESOURCES_PRESENT
            system "/bin/cp #{CUSTOM1_HOOKS_SRC_PATH}/*.sh #{@application.root}/"
            system "/bin/cp -r #{CUSTOM1_RESOURCE_PATH} #{@app_config_cache_root}"
            @pre_custom1_start_script = Dir.glob("#{@application.root}/#{PRE_CUSTOM1_START_SCRIPT}")[0]
          end

          system "chmod +x #{@application.root}/*.sh"
          system "chmod -R 755 #{@app_config_cache_root}"

          modify_pre_start_script
        end

        # The Pre-Start script
        def pre_start
          # Uncomment following line if need to add custom hook script to be part of the startup
          if CUSTOM_RESOURCES_PRESENT
            "/bin/bash ./#{PRE_START_SCRIPT} && . ./#{PRE_CUSTOM1_START_SCRIPT} "
          else
            "/bin/bash ./#{PRE_START_SCRIPT}"
          end
        end

        # The Post-Shutdown script
        def post_shutdown
          if CUSTOM_RESOURCES_PRESENT
            "/bin/bash ./#{POST_STOP_SCRIPT} && . ./#{POST_CUSTOM1_STOP_SCRIPT}"
          else
            "/bin/bash ./#{POST_STOP_SCRIPT}"
          end
        end

        private

        HOOKS_RESOURCE   = 'hooks'.freeze
        PRE_START_SCRIPT = 'preStart.sh'.freeze
        POST_STOP_SCRIPT = 'postStop.sh'.freeze

        START_STOP_HOOKS_SRC_PATH = "#{BUILDPACK_CONFIG_CACHE_DIR}/#{HOOKS_RESOURCE}".freeze

        # the package structure would be:
        # wls-buildpack
        #  -- resources
        #      -- wls    # BUILDPACK_CONFIG_CACHE_DIR
        #         -- hooks
        #            --- preStart.sh
        #            --- postStop.sh
        #      -- custom1 # CUSTOM1_RESOURCE_PATH
        #         -- hooks
        #            --- preCustom1Start.sh
        #            --- postCustom1Stop.sh
        #         -- customType1  # CUSTOM1_TYPE1_RESOURCE_PATH
        #            --- lib # containing jars
        #         -- customType2  # CUSTOM1_TYPE2_RESOURCE_PATH
        #            --- lib # containing jars

        # Allow customization of resources
        # Edit names as required
        CUSTOM1_RESOURCE         = 'custom1'.freeze
        CUSTOM1_TYPE1_RESOURCE   = 'custom1Type1'.freeze
        CUSTOM1_TYPE2_RESOURCE   = 'custom1Type2'.freeze
        PRE_CUSTOM1_START_SCRIPT = 'preCustom1Start.sh'.freeze

        CUSTOM1_RESOURCE_PATH       = "#{BUILDPACK_CONFIG_CACHE_DIR}/../#{CUSTOM1_RESOURCE}".freeze
        CUSTOM1_TYPE1_RESOURCE_PATH = "#{CUSTOM1_RESOURCE_PATH}/#{CUSTOM1_TYPE1_RESOURCE}".freeze
        CUSTOM1_TYPE2_RESOURCE_PATH = "#{CUSTOM1_RESOURCE_PATH}/#{CUSTOM1_TYPE2_RESOURCE}".freeze
        CUSTOM1_HOOKS_SRC_PATH      = "#{CUSTOM1_RESOURCE_PATH}/#{HOOKS_RESOURCE}".freeze

        # Modify the templated preStart script with actual values

        def modify_pre_start_script
          # Load the app bundled configurations and re-configure as needed the JVM parameters for the Server VM
          log("JVM config passed via droplet java_opts : #{@droplet.java_opts}")

          JavaBuildpack::Container::Wls::JvmArgHelper.update(@droplet.java_opts)
          JavaBuildpack::Container::Wls::JvmArgHelper.add_wlx_server_mode(@droplet.java_opts, @start_in_wlx_mode)
          log("Consolidated Java Options for Server: #{@droplet.java_opts.join(' ')}")

          staging_memory_limit = ENV['MEMORY_LIMIT']
          staging_memory_limit = '512m' unless staging_memory_limit

          script_path = @pre_start_script.to_s
          vcap_root = Pathname.new(@application.root).parent.to_s

          original = File.open(script_path, 'r', &:read)

          modified = original.gsub(/REPLACE_VCAP_ROOT_MARKER/, vcap_root)
          modified = modified.gsub(/REPLACE_JAVA_ARGS_MARKER/, @droplet.java_opts.join(' '))
          modified = modified.gsub(/REPLACE_DOMAIN_HOME_MARKER/, @domain_home.to_s)
          modified = modified.gsub(/REPLACE_SERVER_NAME_MARKER/, @server_name)
          modified = modified.gsub(/REPLACE_WLS_PRE_JARS_CACHE_DIR_MARKER/, WLS_PRE_JARS_CACHE_DIR)
          modified = modified.gsub(/REPLACE_WLS_POST_JARS_CACHE_DIR_MARKER/, WLS_POST_JARS_CACHE_DIR)
          modified = modified.gsub(/REPLACE_STAGING_MEMORY_LIMIT_MARKER/, staging_memory_limit)

          File.open(script_path, 'w') { |f| f.write modified }

          log('Updated preStart.sh files!!')
        end

        def log(content)
          JavaBuildpack::Container::Wls::WlsUtil.log(content)
        end
      end
    end
  end
end
