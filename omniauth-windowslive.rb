# name: omniauth-windowslive
# about: A light OmniAuth implementation for Windows Live / Microsoft Accounts
# version: 0.0.1
# author: Cory J. Reid

require "omniauth/strategies/oauth2"
require 'multi_json'

module OmniAuth
  module Strategies
    class WindowsLive < OmniAuth::Strategies::OAuth2
      option :name, "windows_live"

      option :client_options, {
        authorize_url: 'https://login.live.com/oauth20_authorize.srf?scope=wl.signin%20wl.basic%20wl.emails&',
        token_url:     'https://login.live.com/oauth20_token.srf'
      }

      info do
        {
          id: access_token['id']
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end