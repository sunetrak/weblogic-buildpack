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

module JavaBuildpack
  module Container
    module Wls

      # Collection of constants used by the Weblogic container
      module WlsConstants

        # New line character
        NEWLINE                    = "\n".freeze
        # Application web-inf directory name
        WEB_INF_DIRECTORY          = 'WEB-INF'.freeze
        # Java binary to execute
        JAVA_BINARY                = 'java'.freeze
        # Server option name
        SERVER_VM                  = '-server'.freeze
        # Client option name
        CLIENT_VM                  = '-client'.freeze

        # Name of the Weblogic configuration script
        WLS_CONFIGURE_SCRIPT       = 'configure.sh'.freeze

        # Prefer App Bundled Config or Buildpack bundled Config
        PREFER_APP_CONFIG          = 'prefer_app_config'.freeze

        # Prefer App Bundled Config or Buildpack bundled Config
        START_IN_WLX_MODE          = 'start_in_wlx_mode'.freeze

        # Prefer Root as web app context
        PREFER_ROOT_WEB_CONTEXT    = 'prefer_root_web_context'.freeze

        # Parent Location to save/store the application during deployment
        DOMAIN_APPS_FOLDER         = 'apps'.freeze

        # WLS_DOMAIN_PATH is relative to sandbox
        WLS_DOMAIN_PATH            = 'domains/'.freeze

        # Expect to see a '.wls' folder containing domain configurations and script to create the domain within the App
        # bits
        APP_WLS_CONFIG_CACHE_DIR   = '.wls'.freeze

        # Relative to the .wls folder all under the APP ROOT
        WLS_PRE_JARS_CACHE_DIR     = 'preJars'.freeze
        # Relative to the .wls folder all under the APP ROOT
        WLS_POST_JARS_CACHE_DIR    = 'postJars'.freeze

        # JMS directory
        WLS_JMS_CONFIG_DIR         = 'jms'.freeze
        # JDBC directory
        WLS_JDBC_CONFIG_DIR        = 'jdbc'.freeze
        # Foreign JMS Directory
        WLS_FOREIGN_JMS_CONFIG_DIR = 'foreignjms'.freeze

        # Following are relative to the .wls folder all under the APP ROOT
        # Scripts
        SCRIPT_CACHE_DIR           = 'script'.freeze
        # Hooks
        HOOKS_CACHE_DIR            = 'hooks'.freeze
        # preStart script under hooks
        PRE_START_SCRIPT           = 'preStart.sh'.freeze
        # postStop script under hooks
        POST_STOP_SCRIPT           = 'postStop.sh'.freeze

        # Default WebLogic Configurations packaged within the buildpack
        BUILDPACK_CONFIG_CACHE_DIR = Pathname.new(File.expand_path('../../../../resources/wls',
                                                                   File.dirname(__FILE__))).freeze

        # Set to true if there are custom resources and startup scripts
        CUSTOM_RESOURCES_PRESENT = false

        # the package structure would be:
        # wls-buildpack
        #  -- resources
        #      -- wls    # BUILDPACK_CONFIG_CACHE_DIR
        #         -- hooks
        #            --- preStart.sh
        #            --- postStop.sh
        #      -- custom1 # CUSTOM1_RESOURCE_PATH
        #         -- hooks
        #            --- preCustomStart.sh
        #            --- postCustomStop.sh
        #         -- script  # CUSTOM1_SCRIPT_PATH
        #            --- customDomainExtensionScript.py  # Custom Domain extension script
        #         -- customType1  # CUSTOM1_TYPE1_RESOURCE_PATH
        #            --- lib # containing jars
        #         -- customType2  # CUSTOM1_TYPE2_RESOURCE_PATH
        #            --- lib # containing jars

        # Allow customization of resources
        # Uncomment and edit names as required

        # Resource folder under /resources
        CUSTOM1_RESOURCE         = 'custom1'.freeze
        # Custom Type1 Resource folder under /resources/custom1
        CUSTOM1_TYPE1_RESOURCE   = 'custom1Type1'.freeze
        # Custom Type2 Resource folder under /resources/custom1
        CUSTOM1_TYPE2_RESOURCE   = 'custom1Type2'.freeze
        # Custom PreStart script /resources/custom1
        PRE_CUSTOM1_START_SCRIPT = 'preCustom1Start.sh'.freeze
        # Resource folder under /resources
        POST_CUSTOM1_STOP_SCRIPT = 'postCustom1Stop.sh'.freeze

        # Hooks folder under buildpack config cache
        START_STOP_HOOKS_SRC_PATH   = "#{BUILDPACK_CONFIG_CACHE_DIR}/#{HOOKS_CACHE_DIR}".freeze
        # Full path to custom resource relative (obtained relative to buildpack config cache
        CUSTOM1_RESOURCE_PATH       = "#{BUILDPACK_CONFIG_CACHE_DIR}/../#{CUSTOM1_RESOURCE}".freeze
        # Full path to hooks under custom resources
        CUSTOM1_HOOKS_SRC_PATH      = "#{CUSTOM1_RESOURCE_PATH}/#{HOOKS_CACHE_DIR}".freeze
        # Full path to custom resources of type 1 under custom1 resources
        CUSTOM1_TYPE1_RESOURCE_PATH = "#{CUSTOM1_RESOURCE_PATH}/#{CUSTOM1_TYPE1_RESOURCE}".freeze
        # Full path to custom resources of type 2 under custom2 resources
        CUSTOM1_TYPE2_RESOURCE_PATH = "#{CUSTOM1_RESOURCE_PATH}/#{CUSTOM1_TYPE2_RESOURCE}".freeze

      end
    end
  end
end
