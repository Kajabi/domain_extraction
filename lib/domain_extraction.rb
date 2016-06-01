require "domain_extraction/version"

class DomainExtraction
  def initialize
    @tlds = Set.new

    load_tlds
  end

  def extract_domain(hostname)
    if tld = extract_tld(hostname)
      hostname[/([^.]+\.#{tld}$)/, 1]
    end
  end

  def extract_tld(hostname)
    tld  = nil

    possible_domains_for_host(hostname).each do |domain|
      if tlds.include?(domain) || domain_matches_wildcard_tld?(domain)
        tld = domain
      end
    end

    tld
  end

  private

  attr_reader :tlds

  def dat_file
    File.open("#{File.dirname(__FILE__)}/../data/public_suffix_list.dat", "r:UTF-8")
  end

  def load_tlds
    dat_file.each_line do |line|
      line = line.strip
      unless line.empty? || line.start_with?("//")
        tlds << line
      end
    end
  end

  # Returns a breakdown of descending domains for a given host
  #
  # For example, members.example.co.uk would provide:
  #
  #   uk
  #   co.uk
  #   example.co.uk
  #   members.example.co.uk
  #
  def possible_domains_for_host(host)
    host_parts = host.split(".")
    domain     = nil

    Enumerator.new do |yielder|
      while part = host_parts.pop
        domain = "#{part}.#{domain}".sub(/\.$/, '')
        yielder << domain
      end
    end
  end

  def domain_matches_wildcard_tld?(domain)
    tlds.include?(domain.sub(/.+?\./, "*."))
  end
end
