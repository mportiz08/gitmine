require 'ostruct'
require 'faster_csv'
require 'yaml'
require 'octokit'

module Gitmine  
  class Transfer
    def initialize(path)
      @config = YAML.load(File.open(File.join(File.dirname(__FILE__), "../", "config", "github.yml")))["github"]
      @issues = parse(File.open(path).read)
      @github = Octokit::Client.new(:login => @config["username"], :token => @config["api_token"])
    end
    
    def run
      puts "transferring labels for #{@config["repo"]}..."
      transfer_labels
      puts "transferring issues for #{@config["repo"]}..."
      transfer_issues
      puts "...done"
    end
    
    private
    
    def transfer_labels
      uniq_labels = @issues.map(&:tracker).uniq.map(&:downcase)
      uniq_labels.each {|l| @github.add_label(@config["repo"], l)}
    end
    
    def transfer_issues
      
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