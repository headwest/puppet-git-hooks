require 'rubygems'
require 'json'

desc "Run json_syntax_check.sh on all JSON fixtures"
task :json do
  bad = FileList.new('fixtures/json/fails/*.json')
  good = FileList.new('fixtures/json/passes/*.json')
  bad_results = []
  good_results = []

  bad.each do |file|
    sh %{./commit_hooks/json_syntax_check.sh #{file} >/dev/null 2>&1}, :verbose => false do |ok, res|
      if ok
        sh "/bin/echo -n $(tput setaf 1)", :verbose => false
        puts "Error: invalid JSON not detected in #{file}"
        sh "/bin/echo -n $(tput sgr0)", :verbose => false
      else
        bad_results << res
      end
    end
  end
  bad_failures = bad.count - bad_results.count

  good.each do |file|
    sh %{./commit_hooks/json_syntax_check.sh #{file} >/dev/null 2>&1}, :verbose => false do |ok, res|
      if ! ok
        sh "/bin/echo -n $(tput setaf 1)", :verbose => false
        puts "Error: valid JSON not detected in #{file}"
        sh "/bin/echo -n $(tput sgr0)", :verbose => false
      else
        good_results << res
      end
    end
  end
  good_failures = good.count - good_results.count

  total_failures = bad_failures + good_failures
  total_files = bad.count + good.count

  if total_failures > 0
    puts "---\n( #{total_failures} / #{total_files} ) failed"
    exit 1
  end
end
