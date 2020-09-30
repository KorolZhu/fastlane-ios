module Fastlane
  module Actions
    class WechatworkAction < Action
      def self.run(params)
        options = params || {}

        [:title, :subTitle, :contents, :webhook, :mentioned_mobile_list].each do |key|
          UI.user_error!("No #{key} given.") unless options[key]
        end

        title = options[:title]
        subTitle = options[:subTitle]
        changelog = options[:contents]
        contents = changelog.split("\n")
        webhook = options[:webhook]
        mentioned_mobile_list = options[:mentioned_mobile_list]

        # title = "HelloTalk(iOS) 4.1.5 (28)"
        # subTitle = "branch: develop/main"
        # changelog = 
        # "找语伴页面部分多语言更新
        # vip banner track once埋点
        # [隐身按钮可点击区域调大至48pt](https://jira.hellotalk8.com/jira/browse/IOS-3382)
        # [会员进入搜索页点击gender，出现VIP图标](https://jira.hellotalk8.com/jira/browse/IOS-3402)"
        # contents = changelog.split("\n")

        UI.success("5555555")
        UI.success(params)

        webhook = "https://open.feishu.cn/open-apis/bot/v2/hook/2b666371-e2b8-464b-a19a-19de6a8b1631"
        mentioned_mobile_list = []

        json = self.buildParams(title, subTitle, contents)
        self.post_to_wechat(webhook, json)

        if mentioned_mobile_list.empty? == false
          params = {}
          params["msgtype"] = "text"
          params["text"] = {"content": "", "mentioned_mobile_list": mentioned_mobile_list}
          self.post_to_wechat(webhook, params)
        end

      end

      def self.buildParams(title, subTitle, contents) 
        title = title.strip
        subTitle = subTitle.strip

        zh_cn = {}
        if title.length > 0 
          zh_cn["title"] = title
        end

        texts = []

        if subTitle.length > 0 
          info = {}
          info["tag"] = "text"
          info["text"] = subTitle.strip + "\n\n"

          texts << [info]
        end

        for item in contents do
          item = item.strip
          if item.length > 0
            match = item.match(/^\[.*\]\(.*\)$/)
            if match != nil 
              item[0] = ''
              item[-1]= ''
              value = item.split("](")
              if value.length == 2 
                info = {}
                info["tag"] = "a"
                info["text"] = value[0]
                info["href"] = value[1]

                texts << [info]
              end
            else
              info = {}
              info["tag"] = "text"
              info["text"] = item

              texts << [info]
            end
          end
        end

        zh_cn["content"] = texts

        params = {}
        params["msg_type"] = "post"
        params["content"] = {"post" => {
          "zh_cn" => zh_cn
        }}

        return params
      end

      def self.post_to_wechat(webhook, params)
        require 'net/http'
        require 'uri'
        require 'json'


        uri = URI.parse("#{webhook}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        # 设置请求参数
        data = params.to_json

        UI.success(data)


        # 设置请求头
        header = {'Content-Type':'application/json'}
        response = http.post(uri, data, header)
        self.check_response(response)

      end

      def self.check_response(response)
        case response.code.to_i
        when 200, 204
          UI.success('---Successfully sent wechatwork notification')
          true
        else
          UI.user_error!("--- Could not sent wechatwork notification")
        end
      end

      def self.description
        "Post a markdown to [WeChat_Work](https://work.weixin.qq.com/api/doc#90000/90136/91770)"
      end

      def self.available_options
        [
          ['webhook', 'wechatwork webhook'],
          ['markdown', 'The markdown to post'],
          ['mentioned_mobile_list', 'The mentioned_mobile_list']
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
              webhook: "url",
              markdown: "",
              mentioned_mobile_list: ["136***", "159***"]
          )'
        ]
      end

      def self.category
        :notifications
      end
    end
  end
end
