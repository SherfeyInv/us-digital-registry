# Use this hook to configure devise mailer, warden hooks and so forth. The first
# four configuration values can also be set straight in your models.


class CustomFailure < Devise::FailureApp
    def redirect_url
       "https://#{ENV['REGISTRY_HOSTNAME']}/users/auth/login_dot_gov"
    end

    # You need to override respond to eliminate recall
    def respond
      if http_auth?
        http_auth
      else
        redirect
      end
    end
  end


Devise.setup do |config|
  # CAS SPECIFIC IMPLEMENTATION
  # config.cas_base_url = "https://login.max.gov/cas/"

  # you can override these if you need to, but cas_base_url is usually enough
  # config.cas_login_url = "https://cas.myorganization.com/login"
  # config.cas_logout_url = "https://cas.myorganization.com/logout"
  # config.cas_validate_url = "https://cas.myorganization.com/serviceValidate"

  # The CAS specification allows for the passing of a follow URL to be displayed when
  # a user logs out on the CAS server. RubyCAS-Server also supports redirecting to a
  # URL via the destination param. Set either of these urls and specify either nil,
  # 'destination' or 'follow' as the logout_url_param. If the urls are blank but
  # logout_url_param is set, a default will be detected for the service.
  # config.cas_destination_url = 'https://cas.myorganization.com'
  # config.cas_follow_url = 'https://cas.myorganization.com'
  # config.cas_logout_url_param = nil

  # You can specify the name of the destination argument with the following option.
  # e.g. the following option will change it from 'destination' to 'url'
  # config.cas_destination_logout_param_name = 'url'

  # By default, devise_cas_authenticatable will create users.  If you would rather
  # require user records to already exist locally before they can authenticate via
  # CAS, uncomment the following line.
  # config.cas_create_user = false
  # config.cas_username_column = :user

  # You can enable Single Sign Out, which by default is disabled.
  # config.cas_enable_single_sign_out = true

  # If you want to use the Devise Timeoutable module with single sign out,
  # uncommenting this will redirect timeouts to the logout url, so that the CAS can
  # take care of signing out the other serviced applocations. Note that each
  # application manages timeouts independently, so one application timing out will
  # kill the session on all applications serviced by the CAS.
  # config.warden do |manager|
  #   manager.failure_app = DeviseCasAuthenticatable::SingleSignOut::WardenFailureApp
  # end

  # If you need to specify some extra configs for rubycas-client, you can do this via:
  # config.cas_client_config_options = {
  #     logger: Rails.logger
  # }

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :login_dot_gov, {
      name: :login_dot_gov,
      client_id: ENV['REGISTRY_IDP_CLIENT_ID'], # same value as registered in the Partner Dashboard
      idp_base_url: ENV['REGISTRY_IDP'], # login.gov sandbox environment IdP
      ial: 1,
      private_key: OpenSSL::PKey::RSA.new(File.read('config/private.pem')),
      redirect_uri: ENV['REGISTRY_LOGIN_REDIRECT'],
    }
  end
  OmniAuth.config.allowed_request_methods = %i[get post]

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class with default "from" parameter.
  config.mailer_sender = "please-change-me-at-config-initializers-devise@example.com"

  # Configure the class responsible to send e-mails.
  # config.mailer = "Devise::Mailer"

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  # config.authentication_keys = [ :email ]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [ :email ]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [ :email ]

  # Tell if authentication through request.params is enabled. True by default.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Basic Auth is enabled. False by default.
  # config.http_authenticatable = false

  # If http headers should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. "Application" by default.
  # config.http_authentication_realm = "Application"

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments.
  config.stretches = Rails.env.test? ? 1 : 10

  # Setup a pepper to generate the encrypted password.
  # config.pepper = "506e45315d972fbce89b7144af6253a01be863dc33b43c6310375458220db0de22608c0fbbb95f990a88b28d0732b94b82d383d1dc3b00740ecee5da2f1ee8b0"

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming his account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming his account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming his account.
  # config.confirm_within = 2.days

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [ :email ]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
   config.remember_for = 2.seconds

  # If true, a valid remember token can be re-used between multiple browsers.
  # config.remember_across_browsers = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # If true, uses the password salt as remember token. This should be turned
  # to false if you are not using database authenticatable.


  # Options to be passed to the created cookie. For instance, you can set
  # :secure => true in order to force SSL only cookies.
  # config.cookie_options = {}

  # ==> Configuration for :validatable
  # Range for password length. Default is 6..128.
  # config.password_length = 6..128

  # Email regex used to validate email formats. It simply asserts that
  # an one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  # config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [ :email ]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [ :email ]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 2.hours

  # ==> Configuration for :encryptable
  # Allow you to use another encryption algorithm besides bcrypt (default). You can use
  # :sha1, :sha512 or encryptors from others authentication tools as :clearance_sha1,
  # :authlogic_sha512 (then you should set stretches above to 20 for default behavior)
  # and :restful_authentication_sha1 (then you should set stretches to 10, and copy
  # REST_AUTH_SITE_KEY to pepper)
  # config.encryptor = :sha512

  # ==> Configuration for :token_authenticatable
  # Defines name of the authentication token params key
  # config.token_authentication_key = :auth_token

  # If true, authentication through token does not store user in session and needs
  # to be supplied on each request. Useful if you are using the token as API token.
  # config.stateless_token = false

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Configure sign_out behavior.
  # Sign_out action can be scoped (i.e. /users/sign_out affects only :user scope).
  # The default is true, which means any logout action will sign out all active scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The :"*/*" and "*/*" formats below is required to match Internet
  # Explorer requests.
  # config.navigational_formats = [:"*/*", "*/*", :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :get

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  config.warden do |manager|
    manager.failure_app = CustomFailure
  end
  # line from initializer that overrides this on build
  config.secret_key = ENV['REGISTRY_RAILS_COOKIE_TOKEN']
end
