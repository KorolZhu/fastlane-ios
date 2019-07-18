module Fastlane
  module Actions
    class WechatworkAction < Action
      def self.run(params)
        options = params || {}

        [:markdown].each do |key|
          UI.user_error!("No #{key} given.") unless options[key]
        end

        markdown = options[:markdown]

        self.post_to_wechat(markdown)
        
      end

      def self.post_to_wechat(markdown)
        require 'net/http'
        require 'uri'
        require 'json'

        uri = URI.parse("https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=ff00389c-ece4-4648-9a7e-0f5f50c06a23")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        # 设置请求参数
        params = {}
        params["msgtype"] = "markdown"
        params["markdown"] = {"content": markdown}
        data = params.to_json

        # 设置请求头
        header = {'Content-Type':'application/json'}
        response = http.post(uri, data, header)

        self.check_response(response)
      end

      def self.check_response(response)
        case response.code.to_i
        when 200, 204
          UI.success('Successfully sent wechatwork notification')
          true
        else
          UI.user_error!("Could not sent wechatwork notification")
        end
      end

      def self.description
        "Post a markdown to [WeChat_Work](https://work.weixin.qq.com/api/doc#90000/90136/91770)"
      end

      def self.available_options
        [
          ['markdown', 'The markdown to post']
        ]
      end

      def self.author
        "Korol Zhu"
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'wechatwork(
              markdown: ""
          )'
        ]
      end

      def self.category
        :notifications
      end
    end
  end
end
