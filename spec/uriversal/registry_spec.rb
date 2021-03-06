require 'spec_helper'

describe Uriversal::Registry do
  
  it 'should load Uriversal::Registry::Domain' do
    Uriversal::Registry.const_defined?(:Domain).should == true
  end
  
  it 'should load Uriversal::Registry::Path' do
    Uriversal::Registry.const_defined?(:Path).should == true
  end
  
  it 'should load Uriversal::Registry::FileType' do
    Uriversal::Registry.const_defined?(:FileType).should == true
  end
  
  describe '.config' do
    it 'should not fail with no data' do
      Uriversal::Registry.config do
      end
    end
  end
  
  describe '.domain' do
    it 'should return Uriversal::Registry::Domain' do
      Uriversal::Registry.domain.class.should == Uriversal::Registry::Domain
    end
    it 'should add to the beginning domains class variable' do
      d = Uriversal::Registry.domain
      Uriversal::Registry.domains[0].should == d
    end
  end
  
  describe '.match' do
    
    before(:all) do
      Uriversal.registry.config do
        domain [/^valid-registry-match.com$/i], [:default]
        domain [/^valid-registry-file-match.com$/i] do
          file_type [/^end$/i], [:file]
        end
        domain [/^valid-registry-query-match.com$/i] do
          query [/^?q=hello$/i], [:default]
        end
        domain [/^valid-registry-path-match.com$/i,/^valid-registry-nested-match.com$/i] do
          path [/^\/path$/i], [:default] do
            file_type [/^png$/i], [:file]
            query [/^?q='should_not_be_matched'$/i], [:default]
          end
        end
      end
      @valid_link = Uriversal::Url.new('http://valid-registry-match.com')
      @valid_file_link = Uriversal::Url.new('http://valid-registry-file-match.com/file.end')
      @valid_query_link = Uriversal::Url.new('http://valid-registry-query-match.com/?q=hello')
      @valid_path_link = Uriversal::Url.new('http://valid-registry-path-match.com/path')
      @valid_path_with_query_link = Uriversal::Url.new('http://valid-registry-nested-fallback-match.com/path?q=hello')
      @valid_path_with_file_link = Uriversal::Url.new('http://valid-registry-path-match.com/path.png')
    end
    it 'should return a match object' do
      [@valid_link,@valid_file_link].each do |link|
        Uriversal::Registry.match(link).class.should == Uriversal::Registry::Match
      end
    end
    it 'should return a match object with valid strategries' do
      [@valid_link,@valid_file_link,@valid_query_link,@valid_query_link].each do |link|
        Uriversal::Registry.match(link).match_object.strategies.length.should >= 1
      end
    end
    
    it 'should match on file type' do
      Uriversal::Registry.match(@valid_file_link).match_object.class.should == Uriversal::Registry::FileType
    end
    
    it 'should match on query' do
      Uriversal::Registry.match(@valid_query_link).match_object.class.should == Uriversal::Registry::Query
    end
    
    it 'should match on path' do
      Uriversal::Registry.match(@valid_path_link).match_object.class.should == Uriversal::Registry::Path
    end
    
    it 'should match on file under nested path' do
      Uriversal::Registry.match(@valid_path_with_file_link).match_object.class.should == Uriversal::Registry::FileType
    end
    
    it 'should fall back on previous match level if no match was found under the nesting' do
      Uriversal::Registry.match(@valid_path_with_query_link).match_object.class.should == Uriversal::Registry::Path
    end
    
    it 'should match on domain' do
      Uriversal::Registry.match(@valid_link).match_object.class.should == Uriversal::Registry::Domain
    end
    
  end
  
end