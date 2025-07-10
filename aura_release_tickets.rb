#!/usr/bin/env ruby

# Fetch all remote tags first
puts "Fetching remote tags..."
`git fetch --tags`

def find_latest_release_tag
  # Get all tags that match the aura release pattern
  tags = `git tag --list | grep -E "^aura-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+$"`.split("\n")
  
  # Filter for release tags (even patch versions only)
  release_tags = tags.select do |tag|
    # Extract the patch version from tag format: aura-major.minor.patch-build
    if tag =~ /^aura-(\d+)\.(\d+)\.(\d+)-(\d+)$/
      patch_version = $3.to_i
      patch_version.even?  # Only even patch versions are releases
    else
      false
    end
  end
  
  # Sort tags by version and return the latest
  if release_tags.empty?
    puts "No release tags found matching pattern aura-x.x.x-x with even patch version"
    return nil
  end
  
  # Sort by version components
  latest_tag = release_tags.max_by do |tag|
    tag.match(/^aura-(\d+)\.(\d+)\.(\d+)-(\d+)$/) do |m|
      [m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i]
    end
  end
  
  latest_tag
end

def get_commits_since_tag(tag)
  if tag.nil?
    # If no release tag found, get all commits
    commits = `git log --oneline --pretty=format:"%s" origin/main`.split("\n")
  else
    # Get commits from the tag to HEAD on main branch
    commits = `git log --oneline --pretty=format:"%s" #{tag}..origin/main`.split("\n")
  end
  
  commits.reject(&:empty?)
end

def extract_ticket_urls(commits)
  ticket_urls = []
  
  commits.each do |commit|
    # Find all PRODUCT-{number} patterns anywhere in the commit message
    commit.scan(/PRODUCT-\d+/) do |ticket_id|
      url = "https://notion.so/pushd/#{ticket_id}"
      ticket_urls << url unless ticket_urls.include?(url)
    end
  end
  
  ticket_urls
end

# Main execution
latest_release = find_latest_release_tag

if latest_release
  puts "Latest release tag: #{latest_release}"
  puts "Commits since #{latest_release}:"
  puts "=" * 50
else
  puts "No release tags found. Showing all commits on main:"
  puts "=" * 50
end

commits = get_commits_since_tag(latest_release)

if commits.empty?
  puts "No new commits since the last release."
else
  commits.each_with_index do |commit, index|
    puts "#{index + 1}. #{commit}"
  end
  
  puts "\nTotal commits: #{commits.length}"
end

# Extract and display ticket URLs
ticket_urls = extract_ticket_urls(commits)

unless ticket_urls.empty?
  puts "\n" + "=" * 50
  puts "Notion Ticket URLs:"
  puts "=" * 50
  
  ticket_urls.each do |url|
    puts url
  end
  
  puts "\nTotal tickets: #{ticket_urls.length}"
end