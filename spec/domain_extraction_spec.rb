require "spec_helper"

RSpec.describe DomainExtraction do
  subject { DomainExtraction.new }

  it "has a version number" do
    expect(DomainExtraction::VERSION).not_to be nil
  end

  describe "#extract_tld" do
    it "returns the tld for a given host" do
      expect(subject.extract_tld("domain.no")).to eq("no")
      expect(subject.extract_tld("www.domain.no")).to eq("no")

      expect(subject.extract_tld("domain.com")).to eq("com")
      expect(subject.extract_tld("www.domain.com")).to eq("com")
    end

    it "returns the most specific tld if multiple could match" do
      expect(subject.extract_tld("domain.co.uk")).to eq("co.uk")
      expect(subject.extract_tld("www.domain.co.uk")).to eq("co.uk")

      expect(subject.extract_tld("domain.uk")).to eq("uk")
      expect(subject.extract_tld("www.domain.uk")).to eq("uk")
    end

    it "can handle wildcard entries" do
      expect(subject.extract_tld("www.domain.bd")).to eq("domain.bd")
    end

    it "returns nil if no tld can be extracted" do
      expect(subject.extract_tld("domain.nope")).to be_nil
      expect(subject.extract_tld("www.domain.nope")).to be_nil
    end
  end

  describe "#extract_domain" do
    it "can return the domain for a given hostname" do
      expect(subject.extract_domain("www.domain.com")).to eq("domain.com")
      expect(subject.extract_domain("members.domain.com")).to eq("domain.com")
      expect(subject.extract_domain("www.members.domain.com")).to eq("domain.com")
      expect(subject.extract_domain("www.domain.co.uk")).to eq("domain.co.uk")
    end

    it "returns nil if it can't find a tld for the hostname" do
      expect(subject.extract_tld("www.domain.nope")).to be_nil
    end
  end
end
