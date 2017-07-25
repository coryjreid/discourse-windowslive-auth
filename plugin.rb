# name: windowslive-oauth2
# about: Discourse plugin to allow login via Windows Live / Microsoft Accounts
# version: 1.0.0
# authors: Cory J. Reid

require_dependency 'auth/oauth2_authenticator.rb'
require File.expand_path('../omniauth-windowslive.rb', __FILE__)

enabled_site_setting :windows_live_enabled

class WindowsLiveAuthenticator < ::Auth::OAuth2Authenticator

  def name
    'windows_live'
  end

  def after_authenticate(auth)
    log("after_authenticate response: \n\ncreds: #{auth['credentials'].to_hash}\ninfo: #{auth['info'].to_hash}\nextra: #{auth['extra'].to_hash}")

    result = Auth::Result.new
    token = auth['credentials']['token']
    user_details = fetch_user_details(token, auth['info'][:id])

    result.name = user_details[:name]
    result.username = user_details[:username]
    result.email = user_details[:email]
    result.email_valid = result.email.present? && SiteSetting.windows_live_email_verified?

    current_info = ::PluginStore.get("windows_live", "windows_live_user_#{user_details[:user_id]}")
    if current_info
      result.user = User.where(id: current_info[:user_id]).first
    elsif SiteSetting.windows_live_email_verified?
      result.user = User.where(email: Email.downcase(result.email)).first
      if result.user && user_details[:user_id]
        ::PluginStore.set("windows_live", "windows_live_user_#{user_details[:user_id]}", {user_id: result.user.id})
      end
    end

    result.extra_data = { windows_live_user_id: user_details[:user_id] }
    result
  end

  def after_create_account(user, auth)
    # save user information
    ::PluginStore.set("windows_live", "windows_live_user_#{auth[:extra_data][:windows_live_user_id]}", {user_id: user.id })
    
    # get user avatar
    Jobs.enqueue(:download_avatar_from_url, url: "https://apis.live.net/v5.0/#{auth[:extra_data][:windows_live_user_id]}/picture", user_id: user.id, override_gravatar: false)
  end

  def register_middleware(omniauth)
    omniauth.provider :windows_live,
                      name: 'windows_live',
                      setup: lambda {|env|
                        opts = env['omniauth.strategy'].options
                        opts[:client_id] = SiteSetting.windows_live_client_id
                        opts[:client_secret] = SiteSetting.windows_live_client_secret
                        opts[:provider_ignores_state] = false
                        opts[:token_params] = {headers: {'Authorization' => 
                          "Basic " + Base64.strict_encode64("#{SiteSetting.windows_live_client_id}:#{SiteSetting.windows_live_client_secret}") }}
                      }
  end

  def fetch_user_details(token, id)
    user_json_url = "https://apis.live.net/v5.0/me/?access_token=:token".sub(':token', token.to_s).sub(':id', id.to_s)

    log("user_json_url: #{user_json_url}")

    response = JSON.parse(open(user_json_url).read)

    log("user_json: #{response}")

    result = {}
    result[:user_id] = response['id']
    result[:username] = response['']
    result[:name] = response['name']
    result[:email] = response['emails']['account']

    result
  end

  def log(info)
    Rails.logger.warn("WindowsLive Debugging: #{info}") if SiteSetting.windows_live_debug_auth
  end
end

auth_provider title_setting: "windows_live_button_title",
              enabled_setting: "windows_live_enabled",
              authenticator: WindowsLiveAuthenticator.new('windows_live'),
              message: "Windows Live"

register_css <<CSS

  button.btn-social.windows_live {
    background-color: #0052a4;
  }

  button.btn-social.windows_live:before {
    content: $fa-var-windows;
  }

CSS
