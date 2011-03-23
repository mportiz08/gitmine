require 'ostruct'
require 'faster_csv'
require 'yaml'
require 'multi_json'
require 'octokit'

module Gitmine  
  class Transfer
    def initialize(path)
      @config = YAML.load(File.open(File.join(File.dirname(__FILE__), "../", "config", "github.yml")))["github"]
      @issues = parse(File.open(path).read)
      @github = Octokit::Client.new(:login => @config["username"], :token => @config["api_token"])
      @errors = 0
      @api_calls = 1
    end
    
    def run
      puts "transferring issues for #{@config["repo"]}..."
      transfer_issues
      puts "(#{@errors} errors)"
      puts "...done"
    end
    
    private
    
    def transfer_issues
      @issues.each do |i|
        begin
          sleep(120) if @api_calls % 30 == 0 # be gentle to avoid rate limiting errors
          post = @github.create_issue(@config["repo"], i.subject, i.description)
          @github.add_label(@config["repo"], i.tracker.downcase, post.number)
          @api_calls += 1
        rescue MultiJson::DecodeError
          @errors += 1
        end
      end
    end
    
    def parse(csv)
      issues = []
      FasterCSV.parse(csv) do |row|
        issue = OpenStruct.new
        issue.num = row[0]
        issue.status = row[1]
        issue.project = row[2]
        issue.tracker = row[3]
        issue.priority = row[4]
        issue.subject = row[5]
        issue.assigned_to = row[6]
        issue.category = row[7]
        issue.target_version = row[8]
        issue.author = row[9]
        issue.start_date = row[10]
        issue.due_date = row[11]
        issue.percent_done = row[12]
        issue.estimated_time = row[13]
        issue.parent_task = row[14]
        issue.created = row[15]
        issue.updated = row[16]
        issue.affected_version = row[17]
        issue.description = row[18]
        issues << issue
      end
      issues.drop(1)
    end
  end
end