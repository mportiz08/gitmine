require 'ostruct'
require 'faster_csv'
require 'octokit'

module Gitmine  
  class Transfer
    def initialize(path)
      @csv = File.open(path).read
    end
    
    def run
      issues = []
      FasterCSV.parse(@csv) do |row|
        issue = OpenStruct.new
        issue.num = row[0]
        
        issues << issue
      end
    end
  end
end