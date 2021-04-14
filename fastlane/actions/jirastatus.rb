module Fastlane
  module Actions
    class JirastatusAction < Action
      def self.run(params)
        options = params || {}

        [:log].each do |key|
          UI.user_error!("No #{key} given.") unless options[key]
        end

        # [xxxx](https://jira.hellotalk8.com/jira/browse/IOS-3591)
        log = options[:log]

        people = ["fred@hellotalk.com", "luke@hellotalk.com", "sunshine@hellotalk.com", "caddie@hellotalk.com", "lucia@hellotalk.com"]

        if log != nil
          log_arr = log.split("\n")
          for item in log_arr do
              item_strip = item.strip
            if item_strip.include? "https://jira.hellotalk8.com/jira/browse/"
              issue = item_strip.gsub(/.*https:\/\/jira.hellotalk8.com\/jira\/browse\//, '').gsub(/\)/, '')
              puts issue
              p = self.change_assignee(issue)
              if p.empty? == false 
                people = people + p
              end
            end
          end
        end

        people = people.uniq

        puts("people ---- ")
        puts(people)

        useidJson = {
          "zhuzhi@hellotalk.com" => "6875492720006135809",
          "jersey@hellotalk.com" => "6875253745668653059",
          "rayen@hellotalk.com" => "6876257595473100802",
          "brant@hellotalk.com"=>"6875250454616522755",
          "luke@hellotalk.com"=>"6875570438441795587",
          "sunshine@hellotalk.com"=>"6876265455259041794",
          "caddie@hellotalk.com"=>"6876330288549462017",
          "lucia@hellotalk.com"=>"6875597008632037377",
          "elfin@hellotalk.com"=>"6811756702556225537",
          "young@hellotalk.com"=>"6903690988133285890",
          "wade@hellotalk.com"=>"6881428612185063427",
          "carol@hellotalk.com"=>"6875255520157040642",
          "may@hellotalk.com"=>"6876259085566623745",
          "joffy@hellotalk.com"=>"6875247895130505220",
          "zhangpan@hellotalk.com"=>"6875248630517760002",
          "jessie@hellotalk.com"=>"6938713639201292289",
          "ken@hellotalk.com"=>"6875492741011210243",
          "huiwei@hellotalk.com"=>"6876332678837256194",
          "maple@hellotalk.com"=>"6875888081564696578",
          "warner@hellotalk.com"=>"6876338046900387841",
          "gwynn@hellotalk.com"=>"6876617603280797697",
          "xiwi@hellotalk.com"=>"6875306950737788932",
          "bobo@hellotalk.com"=>"6876342027886280706",
          "jane@hellotalk.com"=>"6875248265617555460",
          "zackery@hellotalk.com"=>"6810314062455373825",
          "nina@hellotalk.com"=>"6701653341576888583",
          "fred@hellotalk.com"=>"6875250100105478145"
        }      

        users = []

        for p in people do 
          userid = useidJson[p]
          if userid 
            users << userid
          end
        end

        puts("users ---- ")
        puts(users)

        # test: https://open.feishu.cn/open-apis/bot/v2/hook/c0b05de8-428b-4288-99ce-67a54e280e1c
        # Project: https://open.feishu.cn/open-apis/bot/v2/hook/e48b50e0-9616-4406-83b9-6785d2c07940

        if users.length > 0 
          other_action.wechatwork(
            title: "",
            subTitle: "",
            contents: "",
            webhook: "https://open.feishu.cn/open-apis/bot/v2/hook/e48b50e0-9616-4406-83b9-6785d2c07940",
            mentioned_mobile_list: users
            )
        end
        
      end

      def self.change_workflow_status(issue, workflow)
        require 'net/http'
        require 'net/https'
        require 'uri'
        require 'json'
        api = "https://jira.hellotalk8.com/jira/rest/api/2/issue/"
        url = api + "#{issue}" + "/transitions"
        uri = URI(url)
        header = {"Content-Type": "application/json"}
        workflow_id = {"transition":{"id":"#{workflow}"}}

        Net::HTTP.start(uri.host, uri.port,
          :use_ssl => uri.scheme == 'https',
          :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

          request = Net::HTTP::Post.new(uri.request_uri, header)
          request.body = workflow_id.to_json
          request.basic_auth('jenkins', 'JeN%@K8s4HT')

          response = http.request(request)
          puts "Change workflow status code: #{response.code}"
        end
      end

      def self.change_assignee(issue)
        require 'net/http'
        require 'net/https'
        require 'uri'
        require 'json'
        api = "https://jira.hellotalk8.com/jira/rest/api/2/issue/"
        url = api + "#{issue}"
        puts "Issue url:"
        puts url
        uri = URI(url)
        header = {"Content-Type": "application/json"}

        people = []

        Net::HTTP.start(uri.host, uri.port,
          :use_ssl => uri.scheme == 'https', 
          :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

          #Get assignee info.
          request = Net::HTTP::Get.new(uri.request_uri, header)
          request.basic_auth('jenkins', 'JeN%@K8s4HT')

          response = http.request(request)
          full_json = JSON.parse(response.body)
          puts "Get assignee info status code: #{response.code}"


          fields = full_json['fields']

          tester = fields["customfield_10600"]
          if tester 
            email = tester["emailAddress"]
            if email 
              people << email
          end
          end

          creator = fields["creator"]
          if creator 
            email = creator["emailAddress"]
            if email 
              people << email
          end
          end

          watchers = fields["customfield_10301"]
          for item in watchers do
            p = item["emailAddress"]
            if p 
              people << p
            end
          end

          productManager = fields["customfield_10521"]
          if productManager 
            email = productManager["emailAddress"]
            if email 
              people << email
          end
          end

          assignee = fields["assignee"]
          if assignee 
            email = assignee["emailAddress"]
            if email 
              people << email
          end
          end

          designer = fields["customfield_10510"]
          if designer 
            email = designer["emailAddress"]
            if email 
              people << email
            end
          end

          ios = fields["customfield_10511"]
          if ios 
            email = ios["emailAddress"]
            if email 
              people << email
            end
          end

          service = fields["customfield_10513"]
          if service 
            email = service["emailAddress"]
            if email 
              people << email
            end
          end

          datap = fields["customfield_10514"]
          if datap 
            email = datap["emailAddress"]
            if email 
              people << email
            end
          end

          backend = fields["customfield_10519"]
          if backend 
            email = backend["emailAddress"]
            if email 
              people << email
            end
          end

          if full_json['fields']['issuetype']['name'] == "Story"
            puts "Issue #{issue} type is: Story."
            #workflow "Passed Build" statu id
            workflow = "91"
            puts "Change status to: Passed Build."
            change_workflow_status(issue, workflow)
            #workflow "Product Verify" statu id
            workflow = "211"
            puts "Change status to: Product Verify."
            change_workflow_status(issue, workflow)

            if full_json['fields']['customfield_10521']
              pm = full_json['fields']['customfield_10521']['name']
            end

            if full_json['fields']['customfield_10514']
              data = full_json['fields']['customfield_10514']['name']
            end

            if full_json['fields']['customfield_10515']
              operation = full_json['fields']['customfield_10515']['name']
            end

            if full_json['fields']['reporter']
              reporter = full_json['fields']['reporter']['name']
            end

            if pm
              user = pm
            elsif data
              user = data
            elsif operation
              user = operation
            else
              user = reporter
            end
          # elsif full_json['fields']['issuetype']['name'] == "Story Bugs"
          #   puts "Issue #{issue} type is: Story Bugs."
          #   user = "sunshine"
          #   #workflow "Story Bug Fixed" statu id
          #   workflow = "11"
          #   puts "Change status to: Story Bug Fixed."
          #   change_workflow_status(issue, workflow)
          elsif full_json['fields']['issuetype']['name'] == "Bug"
            puts "Issue #{issue} type is: Bugs."
            #user = full_json['fields']['reporter']['name']
            user = "sunshine"
            #workflow "Passed Build" statu id
            workflow = "91"
            puts "Change status to: Passed Build."
            change_workflow_status(issue, workflow)

          # sub-task，UI bug，Story bug 这三种类型的仅更改assignee为report
          elsif full_json['fields']['issuetype']['name'] == "Sub-task"
            user = full_json['fields']['reporter']['name']

          elsif full_json['fields']['issuetype']['name'] == "UI Bug"
            user = full_json['fields']['reporter']['name']

          elsif full_json['fields']['issuetype']['name'] == "Story Bugs"
            user = full_json['fields']['reporter']['name']

          else
              user = full_json['fields']['assignee']['name']
          end

          assignee = {"update": {"assignee": [{"set": {"name": "#{user}"}}]}}

          #set assignee.
          request = Net::HTTP::Put.new(uri.request_uri, header)
          request.body = assignee.to_json
          puts "assignee josn: #{request.body}"
          request.basic_auth('jenkins', 'JeN%@K8s4HT')

          response = http.request(request)

          puts "Change assignee to #{user}."
          puts "Set assignee status code: #{response.code}"
        end

        return people

      end

      def self.description
        "Change jira workflow status and assignee."
      end

      def self.available_options
        [
          ['log', 'log_from_changelog'],
        ]
      end

      def self.author
        "Archon"
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'jirastatus(
              log: "log_from_changelog"
          )'
        ]
      end

      def self.category
        :notifications
      end
    end
  end
end