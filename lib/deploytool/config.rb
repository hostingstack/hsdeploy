require 'inifile'

class DeployTool::Config
  def self.all
    @@configfile.to_h
  end
  def self.[](section)
    @@configfile[section]
  end
  def self.[]=(section, value)
    @@configfile[section] = value
  end
  
  def self.load(filename)
    @@configfile = IniFile.load(filename)
  end
  
  def self.save
    @@configfile.save unless @@configfile.to_h.empty?
  end
end