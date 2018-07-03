require 'securerandom'
require 'httparty'

module BbRuby
  class Client
    attr_reader :token, :username, :password, :header, :cookie

    include HTTParty
    default_options.update(verify: false)

    def initialize(base_url:)
      self.class.base_uri base_url
      configure_session
      @header = {'User-Agent' => 'Chrome', 'Content-Type' => 'application/x-www-form-urlencoded', 'Cookie' => cookie}
    end

    def create_account(username: SecureRandom.hex(8) << '.51d281ef@mailosaur.io', password: SecureRandom.hex(8))
      @username = username
      @password = password
      self.class.post("/register?SubAction=sub_add_update&email=#{username}&pwd=#{password}&checkPwd=#{password}&termofuse=true&_termofuse=on&_subscribe=on&CSRFToken=#{token}",:headers => @header)
    end

    def add_item_to_cart(product, qty=1)
      self.class.post("/cart/add?productCode=#{product}&qty=#{qty}&CSRFToken=#{token}",:headers => @header)
    end

    def add_shipping_address(data={})
      # data = {
      #     first_name: 'Fname',
      #     last_name: 'Lname',
      #     address: '99 Atlantic Ave',
      #     apt: '123',
      #     city: 'Toronto',
      #     province: 'CA-ON',
      #     postal: 'M6K 3J8',
      #     phone: '6135550148',
      #     email: @client.username
      # }
      self.class.post("/my-account/add-address?firstName=#{data[:first_name]}&lastName=#{data[:last_name]}&address=#{data[:address]}&apt=#{data[:apt]}&city=#{data[:city]}&province=#{data[:province]}&postalCode=#{data[:postal]}&phone=#{data[:phone]}&email=#{data[:email]}&CSRFToken=#{token}",:headers => @header)
    end

    def configure_session
      self.class.get('/').tap do |r|
        @cookie = r.header['set-cookie']
        @token  = r.body.match('<input type="hidden" name="CSRFToken".*')[0].match('([a-z]|[0-9]){8}-(([a-z]|[0-9]){4}-){3}([a-z]|[0-9]){12}')[0]
      end
    end
  end
end
