require 'json'

class Module
  def track_subclasses
    instance_eval %{
        def self.known_subclasses
          @__deploytool_subclasses
        end
        
        def self.add_known_subclass(s)
          superclass.add_known_subclass(s) if superclass.respond_to?(:inherited_tracking_subclasses)
          (@__deploytool_subclasses ||= []) << s
        end
        
        def self.inherited_tracking_subclasses(s)
          add_known_subclass(s)
          inherited_not_tracking_subclasses(s)
        end
        alias :inherited_not_tracking_subclasses :inherited
        alias :inherited :inherited_tracking_subclasses
    }
  end
end

class DeployTool::Target
  track_subclasses
  
  def self.find(target_spec)
    known_subclasses.each do |klass|
      next unless klass.matches?(target_spec)
      return klass.create(target_spec)
    end
    nil
  end
  
  def self.from_config(config)
    known_subclasses.each do |klass|
      next unless klass.to_s.split('::').last == config['type']
      return klass.new(config)
    end
    nil
  end
  
  def self.get_json_resource(url)
    res = nil
    begin
      timeout(5) do
        res = Net::HTTP.get_response(Addressable::URI.parse(url))
      end
    rescue Timeout::Error
      $logger.debug "Calling '%s' took longer than 5s, skipping" % [url, res.code, res.body]
      return nil
    end
    return nil if res.nil?
    if res.code != '200'
      $logger.debug "Calling '%s' returned %s, skipping" % [url, res.code, res.body]
      return nil
    end
    JSON.parse(res.body)
  end
end

(Dir.glob(File.dirname(__FILE__)+'/target/*.rb') - [__FILE__]).sort.each do |f|
  require 'deploytool/target/' + File.basename(f)
end